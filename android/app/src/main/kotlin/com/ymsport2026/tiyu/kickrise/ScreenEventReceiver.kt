package com.ymsport2026.tiyu.kickrise

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class ScreenEventReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val baseUrl = EventReporter.getBaseUrl(context)
        val reporter = EventReporter(context, baseUrl)
        val repo = PopupConfigRepository(context, baseUrl)
        val action = intent.action ?: "unknown"
        val rom = RomUtils.romLabel()

        val config = repo.getCached()
        reporter.reportLog(LogLevel.INFO, "Screen event received", tag = "unlock",
            context = mapOf(
                "action" to action, "rom" to rom,
                "has_config" to (config != null),
                "enabled" to (config?.enabled ?: false),
                "plan_id" to (config?.planId ?: -1)
            ))
        Log.d(TAG, "Screen event received: $action")

        if (config == null) {
            reporter.reportLogThrottled(LogLevel.WARN, "Screen event: no cached config, skipping", tag = "unlock",
                context = mapOf("action" to action, "rom" to rom), throttleKey = "no_config")
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "config_missing", "source" to "screen_event", "action" to action))
            Log.w(TAG, "Screen event received but no cached config — skipping")
            return
        }
        if (!config.enabled) {
            reporter.reportLogThrottled(LogLevel.WARN, "Screen event: config.enabled=false, skipping", tag = "unlock",
                context = mapOf("action" to action, "rom" to rom, "plan_id" to config.planId),
                throttleKey = "cfg_disabled_${config.planId}")
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "config_disabled", "source" to "screen_event", "action" to action,
                    "plan_id" to config.planId))
            Log.d(TAG, "Screen event received but config.enabled=false — skipping")
            return
        }

        when (intent.action) {
            Intent.ACTION_SCREEN_OFF -> {
                if (RomUtils.detect() == RomUtils.RomType.XIAOMI) recordMiuiLock(context)
                if (config.triggers.onLock) {
                    schedulePopup(context, config)
                } else {
                    reporter.reportLogThrottled(LogLevel.INFO, "Screen event: on_lock=false, skipping", tag = "unlock",
                        context = mapOf("action" to action, "plan_id" to config.planId),
                        throttleKey = "lock_off_${config.planId}")
                    reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                        context = mapOf("reason" to "trigger_disabled", "source" to "screen_event",
                            "action" to action, "trigger" to "on_lock", "plan_id" to config.planId))
                }
            }
            Intent.ACTION_USER_PRESENT -> {
                if (RomUtils.detect() == RomUtils.RomType.XIAOMI && checkAndConsumeHotWindow(context)) {
                    if (config.triggers.onUnlock) {
                        // MIUI hot window: service was killed during lock, fire immediately on unlock
                        schedulePopupWithDelay(context, config, HOT_WINDOW_FIRE_DELAY_MS)
                    } else {
                        reporter.reportLogThrottled(LogLevel.INFO, "Screen event: MIUI hot window active but on_unlock=false", tag = "unlock",
                            context = mapOf("plan_id" to config.planId),
                            throttleKey = "unlock_off_${config.planId}")
                        reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                            context = mapOf("reason" to "trigger_disabled", "source" to "screen_event",
                                "action" to action, "trigger" to "on_unlock", "plan_id" to config.planId,
                                "miui_hot_window" to true))
                    }
                } else if (config.triggers.onUnlock) {
                    schedulePopup(context, config)
                } else {
                    reporter.reportLogThrottled(LogLevel.INFO, "Screen event: on_unlock=false, skipping", tag = "unlock",
                        context = mapOf("action" to action, "plan_id" to config.planId),
                        throttleKey = "unlock_off_${config.planId}")
                    reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                        context = mapOf("reason" to "trigger_disabled", "source" to "screen_event",
                            "action" to action, "trigger" to "on_unlock", "plan_id" to config.planId))
                }
            }
        }
    }

    private fun recordMiuiLock(context: Context) {
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putLong(KEY_MIUI_LOCK_OBSERVED_AT, System.currentTimeMillis()).apply()
    }

    private fun checkAndConsumeHotWindow(context: Context): Boolean {
        val prefs = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
        val active = prefs.getBoolean(KEY_MIUI_HOT_WINDOW_ACTIVE, false)
        val deadline = prefs.getLong(KEY_MIUI_HOT_WINDOW_DEADLINE, 0L)
        if (!active || System.currentTimeMillis() > deadline) {
            if (active) clearHotWindow(prefs)
            return false
        }
        clearHotWindow(prefs)
        Log.d(TAG, "MIUI hot window consumed — scheduling immediate popup on unlock")
        return true
    }

    private fun clearHotWindow(prefs: android.content.SharedPreferences) {
        prefs.edit()
            .putBoolean(KEY_MIUI_HOT_WINDOW_ACTIVE, false)
            .putLong(KEY_MIUI_HOT_WINDOW_DEADLINE, 0L)
            .putLong(KEY_MIUI_LOCK_OBSERVED_AT, 0L)
            .apply()
    }

    private fun schedulePopup(context: Context, config: PopupConfig) {
        schedulePopupWithDelay(context, config, config.frequency.defaultDelayMs)
    }

    private fun schedulePopupWithDelay(context: Context, config: PopupConfig, delayMs: Long) {
        val baseUrl = EventReporter.getBaseUrl(context)
        val repo = PopupConfigRepository(context, baseUrl)
        val reporter = EventReporter(context, baseUrl)
        val rom = RomUtils.romLabel()

        if (!repo.isWithinSchedule(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.TIME_WINDOW)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: outside schedule", tag = "bootstrap",
                context = mapOf("plan_id" to config.planId, "rom" to rom,
                    "schedule_start" to (config.schedule?.startTime ?: "none"),
                    "schedule_end" to (config.schedule?.endTime ?: "none")))
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "outside_schedule", "source" to "screen_event",
                    "plan_id" to config.planId, "rom" to rom))
            Log.d(TAG, "Popup blocked: outside schedule")
            return
        }

        if (repo.isDailyLimitReached(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: daily limit reached", tag = "bootstrap",
                context = mapOf("plan_id" to config.planId, "rom" to rom,
                    "daily_max" to config.frequency.dailyMax))
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "daily_limit", "source" to "screen_event",
                    "plan_id" to config.planId, "rom" to rom))
            Log.d(TAG, "Popup blocked: daily limit reached")
            return
        }

        if (!repo.isMinIntervalPassed(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: min interval not reached", tag = "bootstrap",
                context = mapOf("plan_id" to config.planId, "rom" to rom,
                    "min_interval_min" to config.frequency.minInterval))
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "min_interval", "source" to "screen_event",
                    "plan_id" to config.planId, "rom" to rom))
            Log.d(TAG, "Popup blocked: min_interval not reached (${config.frequency.minInterval} min)")
            return
        }

        if (!repo.isInstallDelayPassed(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.POLICY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: install delay not passed", tag = "bootstrap",
                context = mapOf("plan_id" to config.planId, "rom" to rom,
                    "install_delay_min" to config.frequency.installDelayMinutes))
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to "install_delay", "source" to "screen_event",
                    "plan_id" to config.planId, "rom" to rom))
            Log.d(TAG, "Popup blocked: install_delay_minutes not passed (${config.frequency.installDelayMinutes} min)")
            return
        }

        reporter.incrementTriggerCount()
        val triggerAt = System.currentTimeMillis() + delayMs
        val alarmIntent = Intent(context, PopupAlarmReceiver::class.java).apply {
            putExtra(PopupAlarmReceiver.EXTRA_ALARM_SOURCE, AlarmSource.SCREEN_OFF)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)

        repo.recordScheduled()
        reporter.reportLog(LogLevel.INFO, "Popup scheduled", tag = "bootstrap",
            context = mapOf("plan_id" to config.planId, "rom" to rom,
                "delay_ms" to delayMs, "trigger_at_ms" to triggerAt))
        Log.d(TAG, "Popup scheduled in ${delayMs / 1000}s via setAlarmClock (ROM: $rom)")
    }

    companion object {
        private const val TAG = "KickRise"
        private const val REQUEST_CODE = 9901
        private const val HOT_WINDOW_FIRE_DELAY_MS = 2_000L
        const val KEY_MIUI_LOCK_OBSERVED_AT = "kickrise_miui_lock_at"
        const val KEY_MIUI_HOT_WINDOW_ACTIVE = "kickrise_miui_hot_window"
        const val KEY_MIUI_HOT_WINDOW_DEADLINE = "kickrise_miui_hw_deadline"
    }
}
