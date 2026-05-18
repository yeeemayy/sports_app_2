package com.tiyu2.tiyu.kickrise

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

// Static receiver for ACTION_USER_PRESENT (exempt from Android 8 implicit-broadcast restriction).
// Delivers popups when the OEM has killed PopupForegroundService and cancelled pending alarms —
// the dynamic ScreenEventReceiver is dead in that case and never sees USER_PRESENT.
// When the service is alive, ScreenEventReceiver handles USER_PRESENT first and calls
// recordScheduled(), so isMinIntervalPassed() returns false here and this path is skipped.
class UnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_USER_PRESENT) return

        val baseUrl = EventReporter.getBaseUrl(context).takeIf { it.isNotBlank() } ?: return
        val reporter = EventReporter(context, baseUrl)
        val rom = RomUtils.romLabel()

        Log.d(TAG, "UnlockReceiver fired (ROM: $rom)")
        reporter.reportLog(LogLevel.INFO, "UnlockReceiver fired", tag = "unlock",
            context = mapOf("rom" to rom))

        // MIUI: hot window takes priority — fire immediately via service.
        if (RomUtils.detect() == RomUtils.RomType.XIAOMI) {
            val prefs = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            val hotWindowActive = prefs.getBoolean(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_ACTIVE, false)
            val deadline = prefs.getLong(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_DEADLINE, 0L)

            if (hotWindowActive && System.currentTimeMillis() <= deadline) {
                val config = PopupConfigRepository(context, baseUrl).getCached()
                if (config?.triggers?.onUnlock == true) {
                    Log.d(TAG, "MIUI hot window active — launching popup from UnlockReceiver")
                    reporter.reportLog(LogLevel.INFO, "UnlockReceiver: MIUI hot window triggering popup",
                        tag = "unlock", context = mapOf("rom" to rom))
                    startService(context, Intent(context, PopupForegroundService::class.java).apply {
                        action = PopupForegroundService.ACTION_LAUNCH_POPUP
                    })
                    restartService(context, baseUrl)
                    return
                }
            }
        }

        // All ROMs: attempt popup delivery via alarm (handles OEM-killed service case).
        schedulePopupIfEligible(context, baseUrl, reporter, rom)

        // Restart service so dynamic ScreenEventReceiver is re-registered for future screen events.
        restartService(context, baseUrl)
    }

    private fun schedulePopupIfEligible(context: Context, baseUrl: String, reporter: EventReporter, rom: String) {
        val repo = PopupConfigRepository(context, baseUrl)
        val config = repo.getCached()

        if (config == null || !config.enabled || !config.triggers.onUnlock) {
            val reason = when {
                config == null -> "no_config"
                !config.enabled -> "config_disabled"
                else -> "on_unlock_false"
            }
            reporter.reportLog(LogLevel.INFO, "UnlockReceiver: popup skipped", tag = "unlock",
                context = mapOf("reason" to reason, "rom" to rom))
            return
        }

        if (!repo.isWithinSchedule(config)) {
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "outside_schedule", "source" to AlarmSource.UNLOCK_RECEIVER,
                    "plan_id" to config.planId, "rom" to rom))
            return
        }
        if (repo.isDailyLimitReached(config)) {
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "daily_limit", "source" to AlarmSource.UNLOCK_RECEIVER,
                    "plan_id" to config.planId, "rom" to rom))
            return
        }
        if (!repo.isMinIntervalPassed(config)) {
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "min_interval", "source" to AlarmSource.UNLOCK_RECEIVER,
                    "plan_id" to config.planId, "rom" to rom))
            return
        }
        if (!repo.isInstallDelayPassed(config)) {
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "install_delay", "source" to AlarmSource.UNLOCK_RECEIVER,
                    "plan_id" to config.planId, "rom" to rom))
            return
        }

        reporter.incrementTriggerCount()
        repo.recordScheduled()
        val triggerAt = System.currentTimeMillis() + UNLOCK_FIRE_DELAY_MS
        val alarmIntent = Intent(context, PopupAlarmReceiver::class.java).apply {
            putExtra(PopupAlarmReceiver.EXTRA_ALARM_SOURCE, AlarmSource.UNLOCK_RECEIVER)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
            .setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)

        reporter.reportLog(LogLevel.INFO, "UnlockReceiver: popup scheduled", tag = "unlock",
            context = mapOf("rom" to rom, "delay_ms" to UNLOCK_FIRE_DELAY_MS,
                "plan_id" to config.planId, "trigger_at_ms" to triggerAt))
        reporter.reportLog(LogLevel.INFO, "delivery_attempt_start", tag = "funnel",
            context = mapOf("source" to AlarmSource.UNLOCK_RECEIVER, "rom" to rom,
                "plan_id" to config.planId))
        Log.d(TAG, "UnlockReceiver: popup scheduled in ${UNLOCK_FIRE_DELAY_MS}ms (ROM: $rom)")
    }

    private fun restartService(context: Context, baseUrl: String) {
        startService(context, Intent(context, PopupForegroundService::class.java).apply {
            putExtra(PopupForegroundService.EXTRA_BASE_URL, baseUrl)
        })
    }

    private fun startService(context: Context, intent: Intent) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        } catch (e: Exception) {
            Log.w(TAG, "UnlockReceiver: service start failed: ${e.message}")
        }
    }

    companion object {
        private const val TAG = "KickRise"
        private const val REQUEST_CODE = 9907
        private const val UNLOCK_FIRE_DELAY_MS = 2_000L
    }
}
