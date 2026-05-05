package com.ymsport2026.tiyu.kickrise

import android.app.KeyguardManager
import com.ymsport2026.tiyu.OverlayPermissionCompat
import android.app.NotificationChannel
import android.app.NotificationManager
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
import com.ymsport2026.tiyu.R
import java.util.concurrent.Executors

class PopupForegroundService : Service() {

    private var screenReceiver: ScreenEventReceiver? = null
    private val executor = Executors.newSingleThreadExecutor()

    override fun onCreate() {
        super.onCreate()
        startForegroundWithNotification()
        // Reset on service (re)start — if the process was killed, MainActivity lifecycle callbacks
        // may not have run, so clear both flags to allow popup delivery.
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit()
            .putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, false)
            .putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, false)
            .apply()
        CanaryReceiver.schedule(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_LAUNCH_POPUP) {
            val baseUrl = EventReporter.getBaseUrl(this)
            if (baseUrl.isNotBlank()) {
                EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "onStartCommand: ACTION_LAUNCH_POPUP received", tag = "service",
                    context = mapOf("rom" to RomUtils.romLabel()))
            }
            launchPopupWithWakeLock()
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
            .apply()
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
                context = mapOf("rom" to RomUtils.romLabel(), "domestic" to RomUtils.isDomesticRom()))
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
            .setSmallIcon(R.mipmap.ic_launcher)
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
        Log.d(TAG, "Screen receiver registered (ROM: ${RomUtils.romLabel()}, domestic: ${RomUtils.isDomesticRom()})")
    }

    private fun bootstrapInBackground(baseUrl: String) {
        executor.submit {
            val api = KickRiseApiClient(this)
            api.postHeartbeat(baseUrl)

            val reporter = EventReporter(this, baseUrl)
            val repo = PopupConfigRepository(this, baseUrl)
            repo.fetchAndCache { config ->
                if (config != null) {
                    Log.d(TAG, "Config fetched: enabled=${config.enabled}, onLock=${config.triggers.onLock}, onUnlock=${config.triggers.onUnlock}")
                    reporter.reportLog(LogLevel.INFO, "Config fetched successfully", tag = "bootstrap",
                        context = mapOf("enabled" to config.enabled, "plan_id" to config.planId))
                } else {
                    Log.w(TAG, "Failed to fetch popup config, using cached if available")
                    reporter.reportLog(LogLevel.WARN, "Failed to fetch popup config, using cached if available", tag = "bootstrap")
                }
            }
        }
    }

    private fun launchPopupWithWakeLock() {
        val baseUrl = EventReporter.getBaseUrl(this)
        val reporter = if (baseUrl.isNotBlank()) EventReporter(this, baseUrl) else null
        val repo = PopupConfigRepository(this, baseUrl)
        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()

        if (config == null || !config.enabled || creative == null) {
            reporter?.reportLog(LogLevel.WARN, "Popup launch aborted: no valid config or creative", tag = "service")
            return
        }
        if (repo.isDailyLimitReached(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: daily limit reached", tag = "service")
            return
        }
        if (!repo.isMinIntervalPassedSinceLastShown(config)) {
            reporter?.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: min interval not reached", tag = "service",
                context = mapOf("plan_id" to config.planId, "min_interval_min" to config.frequency.minInterval))
            return
        }
        if (!repo.isWithinSchedule(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: outside schedule", tag = "service")
            return
        }
        if (!repo.isInstallDelayPassed(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: install delay not passed", tag = "service",
                context = mapOf("install_delay_min" to config.frequency.installDelayMinutes))
            return
        }

        val hasOverlay = OverlayPermissionCompat.canDrawOverlays(this)
        val isLocked = (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager).isKeyguardLocked
        val isMiui = RomUtils.detect() == RomUtils.RomType.XIAOMI
        val romLabel = RomUtils.romLabel()

        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        @Suppress("DEPRECATION")
        val wakeLock = pm.newWakeLock(
            PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
            "kickrise:popup_launch"
        )
        wakeLock.acquire(10_000L)

        Log.d(TAG, "Wake lock acquired — launching popup (rom=$romLabel, overlay=$hasOverlay, locked=$isLocked)")
        reporter?.reportLog(LogLevel.INFO, "Wake lock acquired, launching popup", tag = "service",
            context = mapOf("rom" to romLabel, "overlay" to hasOverlay, "locked" to isLocked))

        when {
            isLocked -> {
                // Screen is locked. TYPE_APPLICATION_OVERLAY with FLAG_SHOW_WHEN_LOCKED is unreliable
                // on many OEM lock screens (Realme UI, ColorOS). PopupActivity has manifest-level
                // showWhenLocked/turnScreenOn flags plus applyLockScreenFlags() for domestic ROM fallbacks,
                // making it the most reliable path on locked screens across all ROMs.
                PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            }
            hasOverlay -> PopupOverlayManager(this).show(onFailure = {
                PopupDeliveryFallback.showFullScreenNotification(this, creative, reporter, "service")
            })
            else -> {
                // Screen is on (e.g., task removed). Foreground-service BAL exemption allows direct Activity start.
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
        const val EXTRA_BASE_URL = "base_url"
        const val ACTION_LAUNCH_POPUP = "kickrise.action.LAUNCH_POPUP"
        private const val MIUI_LOCK_RELEVANCE_MS = 10 * 60 * 1000L  // lock must have been within 10 min
        private const val MIUI_HOT_WINDOW_DURATION_MS = 5 * 60 * 1000L  // window expires 5 min after kill
    }
}
