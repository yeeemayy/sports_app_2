package com.ymsport2026.tiyu.kickrise

import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
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
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_LAUNCH_POPUP) {
            val baseUrl = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
                .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""
            if (baseUrl.isNotBlank()) {
                EventReporter(this, baseUrl).reportLog(LogLevel.INFO, "onStartCommand: ACTION_LAUNCH_POPUP received", tag = "service",
                    context = mapOf("rom" to RomUtils.romLabel()))
            }
            launchPopupWithWakeLock()
            return START_STICKY
        }

        val baseUrl = intent?.getStringExtra(EXTRA_BASE_URL) ?: return START_STICKY

        saveBaseUrl(baseUrl)
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
        val baseUrl = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""
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
            .setContentTitle("")
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
        val baseUrl = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""
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
        if (!repo.isWithinSchedule(config)) {
            reporter?.reportLog(LogLevel.INFO, "Popup launch skipped: outside schedule", tag = "service")
            return
        }

        val hasOverlay = android.provider.Settings.canDrawOverlays(this)
        val isLocked = (getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager).isKeyguardLocked
        val isMiui = RomUtils.detect() == RomUtils.RomType.XIAOMI
        val romLabel = RomUtils.romLabel()

        // MIUI lockscreen without overlay: nothing can show — don't even wake the screen.
        if (isMiui && isLocked && !hasOverlay) {
            reporter?.reportLog(LogLevel.INFO, "MIUI lockscreen: overlay required, skipping", tag = "service")
            return
        }

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
            hasOverlay -> PopupOverlayManager(this).show()
            isLocked -> {
                // Screen is locked; BAL restrictions block direct Activity starts.
                // Full-screen notification works on non-MIUI ROMs (Realme/ColorOS, standard Android).
                showFullScreenNotification(creative)
            }
            else -> {
                // Screen is on (e.g., task removed). Foreground-service BAL exemption allows direct Activity start.
                val launched = try {
                    startActivity(Intent(this, PopupActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    })
                    true
                } catch (_: Exception) { false }
                if (!launched) showFullScreenNotification(creative)
            }
        }

        Handler(Looper.getMainLooper()).postDelayed({
            if (wakeLock.isHeld) wakeLock.release()
        }, 5_000L)
    }

    private fun showFullScreenNotification(creative: PopupCreative) {
        val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= 34 && !nm.canUseFullScreenIntent()) {
            val baseUrl = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
                .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""
            EventReporter(this, baseUrl).reportLog(
                LogLevel.ERROR, "USE_FULL_SCREEN_INTENT not granted — popup will not appear", tag = "service"
            )
            return
        }

        ensurePopupChannel()

        val activityIntent = Intent(this, PopupActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this, 0, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, PopupAlarmReceiver.POPUP_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(creative.name)
            .setContentText("")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setVibrate(longArrayOf(0, 300))
            .setAutoCancel(true)
            .build()

        nm.notify(PopupAlarmReceiver.POPUP_NOTIFICATION_ID, notification)
    }

    private fun ensurePopupChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                PopupAlarmReceiver.POPUP_CHANNEL_ID, "KickRise Popup", NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setShowBadge(false)
                enableVibration(true)
                enableLights(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun saveBaseUrl(baseUrl: String) {
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putString(ScreenEventReceiver.KEY_BASE_URL, baseUrl).apply()
    }

    companion object {
        private const val TAG = "KickRise"
        private const val SERVICE_CHANNEL_ID = "kickrise_service_channel"
        private const val SERVICE_NOTIFICATION_ID = 9901
        const val EXTRA_BASE_URL = "base_url"
        const val ACTION_LAUNCH_POPUP = "kickrise.action.LAUNCH_POPUP"
    }
}
