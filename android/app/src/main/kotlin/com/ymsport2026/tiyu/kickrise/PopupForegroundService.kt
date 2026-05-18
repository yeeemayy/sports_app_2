package com.tiyu2.tiyu.kickrise

import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import androidx.core.app.NotificationManagerCompat
import com.tiyu2.tiyu.OverlayPermissionCompat
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import com.tiyu2.tiyu.R
import java.util.concurrent.Executors

class PopupForegroundService : Service() {

    private var screenReceiver: ScreenEventReceiver? = null
    private val executor = Executors.newSingleThreadExecutor()

    override fun onCreate() {
        super.onCreate()
        startForegroundWithNotification()

        // ✅ 新增：创建弹窗专用的高优先级通知渠道
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val popupChannel = NotificationChannel(
                PopupAlarmReceiver.POPUP_CHANNEL_ID,
                "赛事监控中",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setShowBadge(false)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC  // 锁屏显示
                enableLights(false)
                enableVibration(false)
            }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(popupChannel)
        }

        // Reset on service (re)start — if the process was killed, MainActivity lifecycle callbacks
        // may not have run, so clear both flags to allow popup delivery.
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit()
            .putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, false)
            .putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, false)
            .putString(PopupAlarmReceiver.KEY_LAST_LIFECYCLE_EVENT, "service_created")
            .apply()
        CanaryReceiver.schedule(this)
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "service_created", tag = "service",
                context = mapOf("rom" to RomUtils.romLabel(), "domestic" to RomUtils.isAggressiveOemRom()))
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_LAUNCH_POPUP) {
            val alarmSource = intent.getStringExtra(EXTRA_ALARM_SOURCE) ?: AlarmSource.SCREEN_OFF
            val baseUrl = EventReporter.getBaseUrl(this)
            if (baseUrl.isNotBlank()) {
                EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "onStartCommand: ACTION_LAUNCH_POPUP received", tag = "service",
                    context = mapOf("rom" to RomUtils.romLabel(), "alarm_source" to alarmSource))
            }
            launchPopupWithWakeLock(alarmSource)
            return START_STICKY
        }

        val baseUrl = intent?.getStringExtra(EXTRA_BASE_URL) ?: return START_STICKY

        EventReporter.saveBaseUrl(this, baseUrl)
        registerScreenReceiver()
        bootstrapInBackground(baseUrl)
        WatchdogReceiver.schedule(this)

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        // App fully removed from recents — mark so the next alarm can show the popup.
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit()
            .putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, false)
            .putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, false)
            .putString(PopupAlarmReceiver.KEY_LAST_LIFECYCLE_EVENT, "task_removed")
            .apply()
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "app_lifecycle_state", tag = "funnel",
                context = mapOf(
                    "event" to "task_removed",
                    "app_alive" to false,
                    "in_recents" to false,
                    "rom" to RomUtils.romLabel()
                ))
        }
        // Schedule a fallback alarm specifically for the card-swiped case. The activity's onStop()
        // alarm covers the permission-flow path; this one covers process death after swipe.
        scheduleFallbackAlarmFromService()
    }

    private fun scheduleFallbackAlarmFromService() {
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isBlank()) return
        val config = PopupConfigRepository(this, baseUrl).getCached()
        if (config == null || !config.enabled) return
        val delayMs = config.frequency.defaultDelayMs.coerceAtLeast(5_000L)
        val triggerAt = System.currentTimeMillis() + delayMs
        val alarmIntent = Intent(this, PopupAlarmReceiver::class.java).apply {
            putExtra(PopupAlarmReceiver.EXTRA_ALARM_SOURCE, AlarmSource.FALLBACK_ACTIVITY)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, REQUEST_CODE_FALLBACK_SERVICE, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (getSystemService(ALARM_SERVICE) as AlarmManager)
            .setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)
        EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "fallback_alarm_scheduled_from_service", tag = "funnel",
            context = mapOf("delay_ms" to delayMs, "trigger_at_ms" to triggerAt, "rom" to RomUtils.romLabel()))
    }

    override fun onDestroy() {
        super.onDestroy()
        screenReceiver?.let { unregisterReceiver(it) }
        screenReceiver = null

        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)

        // On MIUI, if the service is killed while the screen is locked, activate the hot window
        // so the next unlock fires the popup immediately instead of waiting for the normal alarm.
        if (RomUtils.detect() == RomUtils.RomType.XIAOMI) {
            val lockObservedAt = prefs.getLong(ScreenEventReceiver.KEY_MIUI_LOCK_OBSERVED_AT, 0L)
            val sinceLock = System.currentTimeMillis() - lockObservedAt
            if (lockObservedAt > 0L && sinceLock < MIUI_LOCK_RELEVANCE_MS) {
                prefs.edit()
                    .putBoolean(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_ACTIVE, true)
                    .putLong(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_DEADLINE,
                        System.currentTimeMillis() + MIUI_HOT_WINDOW_DURATION_MS)
                    .commit()
                Log.d(TAG, "MIUI hot window activated (killed ${sinceLock / 1000}s after lock)")
            }
        }

        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.WARN, "PopupForegroundService destroyed", tag = "service",
                context = mapOf("rom" to RomUtils.romLabel(), "domestic" to RomUtils.isAggressiveOemRom()))
        }
        Log.w(TAG, "PopupForegroundService destroyed (ROM: ${RomUtils.romLabel()})")
    }

    private fun startForegroundWithNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                SERVICE_CHANNEL_ID, "Background Service", NotificationManager.IMPORTANCE_MIN
            ).apply { setShowBadge(false) }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, SERVICE_CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("赛事监控中")
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .build()

        startForeground(SERVICE_NOTIFICATION_ID, notification)
    }

    private fun registerScreenReceiver() {
        if (screenReceiver != null) return
        screenReceiver = ScreenEventReceiver()
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_OFF)
            addAction(Intent.ACTION_USER_PRESENT)
        }
        registerReceiver(screenReceiver, filter)
        Log.d(TAG, "Screen receiver registered (ROM: ${RomUtils.romLabel()}, domestic: ${RomUtils.isAggressiveOemRom()})")
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "screen_receiver_registered", tag = "service",
                context = mapOf("rom" to RomUtils.romLabel(), "domestic" to RomUtils.isAggressiveOemRom()))
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "screen_receiver_state", tag = "funnel",
                context = mapOf(
                    "registered" to true,
                    "service_alive" to true,
                    "rom" to RomUtils.romLabel(),
                    "domestic" to RomUtils.isAggressiveOemRom()
                ))
        }
    }

    private fun bootstrapInBackground(baseUrl: String) {
        executor.submit {
            val api = KickRiseApiClient(this)
            api.postHeartbeat(baseUrl)

            // Popup config is on the critical path — fetch it first so delivery is not delayed.
            val reporter = EventReporter(this, baseUrl)
            val repo = PopupConfigRepository(this, baseUrl)
            repo.fetchAndCache { config ->
                if (config != null) {
                    Log.d(TAG, "Config fetched: enabled=${config.enabled}, onLock=${config.triggers.onLock}, onUnlock=${config.triggers.onUnlock}")
                    reporter.reportLog(LogLevel.INFO, "Config fetched successfully", tag = "bootstrap",
                        context = mapOf("enabled" to config.enabled, "plan_id" to config.planId))
                    reporter.pruneThrottleKeys(config.planId)
                } else {
                    Log.w(TAG, "Failed to fetch popup config, using cached if available")
                    reporter.reportLog(LogLevel.WARN, "Failed to fetch popup config, using cached if available", tag = "bootstrap")
                }
            }

        }
    }

    private fun launchPopupWithWakeLock(alarmSource: String = AlarmSource.SCREEN_OFF) {
        val baseUrl = EventReporter.getBaseUrl(this)
        val reporter = if (baseUrl.isNotBlank()) EventReporter(this, baseUrl) else null
        val repo = PopupConfigRepository(this, baseUrl)
        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()

        if (config == null || !config.enabled || creative == null) {
            val blockReason = when {
                config == null -> "config_missing"
                !config.enabled -> "config_disabled"
                else -> "no_creative"
            }
            reporter?.reportLog(LogLevel.WARN, "Popup launch aborted: no valid config or creative", tag = "service")
            reporter?.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to blockReason, "alarm_source" to alarmSource))
            return
        }
        if (repo.isDailyLimitReached(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: daily limit reached", tag = "service")
            reporter?.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "daily_limit", "alarm_source" to alarmSource))
            return
        }
        if (!repo.isMinIntervalPassedSinceLastShown(config)) {
            reporter?.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: min interval not reached", tag = "service",
                context = mapOf("plan_id" to config.planId, "min_interval_min" to config.frequency.minInterval))
            reporter?.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "min_interval", "alarm_source" to alarmSource))
            return
        }
        if (!repo.isWithinSchedule(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: outside schedule", tag = "service")
            reporter?.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "outside_schedule", "alarm_source" to alarmSource))
            return
        }
        if (!repo.isInstallDelayPassed(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: install delay not passed", tag = "service",
                context = mapOf("install_delay_min" to config.frequency.installDelayMinutes))
            reporter?.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "install_delay", "alarm_source" to alarmSource))
            return
        }

        val hasOverlay = OverlayPermissionCompat.canDrawOverlays(this)
        val km = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val keyguardShowing = km.isKeyguardLocked
        val deviceLocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) km.isDeviceLocked else keyguardShowing
        val isMiui = RomUtils.detect() == RomUtils.RomType.XIAOMI
        val romLabel = RomUtils.romLabel()
        val bgPopup = RomUtils.checkBgPopupPermission(this)

        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        val isLocked = keyguardShowing || deviceLocked || !pm.isInteractive
        @Suppress("DEPRECATION")
        val wakeLock = pm.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
            "kickrise:popup_launch"
        )
        wakeLock.acquire(10_000L)

        val isInteractive = pm.isInteractive
        val batteryOptIgnored = pm.isIgnoringBatteryOptimizations(packageName)
        val notificationEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
        val canUseFullScreenIntent = if (Build.VERSION.SDK_INT >= 34) {
            (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).canUseFullScreenIntent()
        } else true

        val isChinaRom = RomUtils.isChinaRom()
        val route = when {
            isLocked -> "fullscreen_notification"
            hasOverlay -> "overlay"
            // China-region ROMs suppress background activity launches after USER_PRESENT —
            // startActivity returns silently without showing anything. Fall back to FSI.
            isChinaRom -> "fullscreen_notification"
            else -> "activity_direct"
        }
        Log.d(TAG, "Wake lock acquired — launching popup (rom=$romLabel, overlay=$hasOverlay, locked=$isLocked)")
        reporter?.reportLog(LogLevel.INFO, "Launch route selected", tag = "service",
            context = mapOf(
                "route" to route, "rom" to romLabel, "sdk" to Build.VERSION.SDK_INT,
                "china_rom" to isChinaRom,
                "domestic" to isChinaRom,
                "locked" to isLocked,
                "interactive" to isInteractive, "overlay" to hasOverlay,
                "battery_opt_ignored" to batteryOptIgnored,
                "notification_enabled" to notificationEnabled,
                "can_use_fsi" to canUseFullScreenIntent,
                "background_popup_allowed" to bgPopup.allowed,
                "background_popup_check" to bgPopup.check,
                "alarm_source" to alarmSource
            ))
        reporter?.reportLog(LogLevel.INFO, "popup_route_selected", tag = "funnel",
            context = mapOf(
                "route" to route, "rom" to romLabel, "sdk" to Build.VERSION.SDK_INT,
                "locked" to isLocked,
                "overlay" to hasOverlay,
                "china_rom" to isChinaRom,
                "domestic" to isChinaRom,
                "can_use_fsi" to canUseFullScreenIntent,
                "background_popup_allowed" to bgPopup.allowed,
                "background_popup_check" to bgPopup.check,
                "alarm_source" to alarmSource
            ))

        when {
            isLocked -> {
                PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            }
            hasOverlay -> PopupOverlayManager(this).show(onFailure = {
                PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            })
            isChinaRom -> {
                PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            }
            else -> {
                // Screen is on, non-domestic ROM. Foreground-service BAL exemption allows direct Activity start.
                val launched = PopupDeliveryFallback.launchActivity(this, reporter, "service")
                if (!launched) PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            }
        }

        Handler(Looper.getMainLooper()).postDelayed({
            if (wakeLock.isHeld) wakeLock.release()
        }, 5_000L)
    }

    companion object {
        private const val TAG = "KickRise"
        private const val SERVICE_CHANNEL_ID = "kickrise_service_channel"
        private const val SERVICE_NOTIFICATION_ID = 9901
        private const val REQUEST_CODE_FALLBACK_SERVICE = 9905
        const val EXTRA_BASE_URL = "base_url"
        const val ACTION_LAUNCH_POPUP = "kickrise.action.LAUNCH_POPUP"
        const val EXTRA_ALARM_SOURCE = "alarm_source"
        private const val MIUI_LOCK_RELEVANCE_MS = 10 * 60 * 1000L  // lock must have been within 10 min
        private const val MIUI_HOT_WINDOW_DURATION_MS = 5 * 60 * 1000L  // window expires 5 min after kill
    }
}
