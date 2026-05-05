package com.ymsport2026.tiyu.kickrise

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

class PopupAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // Keep CPU awake long enough for the foreground service to acquire its own wake lock.
        // MIUI handles screen wake via setTurnScreenOn in PopupActivity; on other ROMs we need this.
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG)
        wl.acquire(WAKELOCK_TIMEOUT_MS)

        val baseUrl = EventReporter.getBaseUrl(context)
        val reporter = EventReporter(context, baseUrl)
        val repo = PopupConfigRepository(context, baseUrl)

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()

        Log.d(TAG, "Alarm received — config=${config != null}, enabled=${config?.enabled}, creative=${creative != null}")
        reporter.reportLog(LogLevel.INFO, "Alarm received", tag = "alarm",
            context = mapOf(
                "has_config" to (config != null),
                "enabled" to (config?.enabled ?: false),
                "has_creative" to (creative != null),
                "rom" to RomUtils.romLabel()
            ))

        if (config == null || !config.enabled || creative == null) {
            val abortReason = when {
                config == null -> "config_missing"
                !config.enabled -> "config_disabled"
                else -> "creative_missing"
            }
            reporter.reportLog(LogLevel.WARN, "Alarm received but popup aborted", tag = "alarm",
                context = mapOf("reason" to abortReason, "rom" to RomUtils.romLabel()))
            wl.release()
            return
        }

        if (isAppAlive(context)) {
            Log.d(TAG, "Popup skipped: app is in foreground")
            reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is in foreground", tag = "alarm",
                throttleKey = "app_alive")
            wl.release()
            return
        }

        if (isAppInRecents(context)) {
            Log.d(TAG, "Popup skipped: app is backgrounded (still in recents)")
            reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is backgrounded (still in recents)", tag = "alarm",
                throttleKey = "app_recents")
            wl.release()
            return
        }

        // Route through the foreground service — it acquires a wake lock to turn the screen on
        // and has more background launch privileges than a BroadcastReceiver on MIUI.
        // Fall back to full-screen notification if the service isn't running.
        val serviceIntent = Intent(context, PopupForegroundService::class.java).apply {
            action = PopupForegroundService.ACTION_LAUNCH_POPUP
        }
        var serviceException: String? = null
        val serviceStarted = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            true
        } catch (e: Exception) {
            serviceException = "${e.javaClass.simpleName}: ${e.message}"
            false
        }

        Log.d(TAG, "Launch routed via foreground service: $serviceStarted")
        val routeCtx = mutableMapOf<String, Any>("via_service" to serviceStarted, "rom" to RomUtils.romLabel())
        if (serviceException != null) routeCtx["service_error"] = serviceException
        reporter.reportLog(LogLevel.INFO, "Routing popup launch", tag = "alarm", context = routeCtx)

        if (!serviceStarted) {
            Log.d(TAG, "Service start failed — falling back to full-screen notification")
            PopupDeliveryFallback.showFullScreenNotification(context, creative, reporter, "alarm")
        }

        wl.release()
        reporter.reportLog(LogLevel.INFO, "Alarm handler complete, wakelock released", tag = "alarm",
            context = mapOf("via_service" to serviceStarted))
    }

    private fun isAppAlive(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_ALIVE, false)

    private fun isAppInRecents(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_IN_RECENTS, false)

    companion object {
        private const val TAG = "KickRise"
        private const val WAKELOCK_TAG = "kickrise:alarm_receiver"
        private const val WAKELOCK_TIMEOUT_MS = 15_000L
        const val POPUP_CHANNEL_ID = "kickrise_popup_channel"
        const val POPUP_NOTIFICATION_ID = 9902
        const val KEY_APP_ALIVE = "kickrise_app_alive"
        const val KEY_APP_IN_RECENTS = "kickrise_app_in_recents"
    }
}
