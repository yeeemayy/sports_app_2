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
        Log.d(TAG, "Screen event received: ${intent.action}")
        val baseUrl = EventReporter.getBaseUrl(context)
        val repo = PopupConfigRepository(context, baseUrl)
        val config = repo.getCached() ?: run {
            Log.w(TAG, "Screen event received but no cached config — skipping")
            return
        }
        if (!config.enabled) {
            Log.d(TAG, "Screen event received but config.enabled=false — skipping")
            return
        }

        when (intent.action) {
            Intent.ACTION_SCREEN_OFF -> {
                if (RomUtils.detect() == RomUtils.RomType.XIAOMI) recordMiuiLock(context)
                if (config.triggers.onLock) schedulePopup(context, config)
            }
            Intent.ACTION_USER_PRESENT -> {
                if (RomUtils.detect() == RomUtils.RomType.XIAOMI && checkAndConsumeHotWindow(context)) {
                    if (config.triggers.onUnlock) {
                        // MIUI hot window: service was killed during lock, fire immediately on unlock
                        schedulePopupWithDelay(context, config, HOT_WINDOW_FIRE_DELAY_MS)
                    }
                } else if (config.triggers.onUnlock) {
                    schedulePopup(context, config)
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

        if (!repo.isWithinSchedule(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.TIME_WINDOW)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: outside schedule", tag = "bootstrap")
            Log.d(TAG, "Popup blocked: outside schedule")
            return
        }

        if (repo.isDailyLimitReached(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: daily limit reached", tag = "bootstrap",
                context = mapOf("daily_max" to config.frequency.dailyMax))
            Log.d(TAG, "Popup blocked: daily limit reached")
            return
        }

        if (!repo.isMinIntervalPassed(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: min interval not reached", tag = "bootstrap",
                context = mapOf("min_interval_min" to config.frequency.minInterval))
            Log.d(TAG, "Popup blocked: min_interval not reached (${config.frequency.minInterval} min)")
            return
        }

        if (!repo.isInstallDelayPassed(config)) {
            reporter.reportBlock(BlockSource.BOOTSTRAP, BlockReason.POLICY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: install delay not passed", tag = "bootstrap",
                context = mapOf("install_delay_min" to config.frequency.installDelayMinutes))
            Log.d(TAG, "Popup blocked: install_delay_minutes not passed (${config.frequency.installDelayMinutes} min)")
            return
        }

        reporter.incrementTriggerCount()
        val triggerAt = System.currentTimeMillis() + delayMs
        val alarmIntent = Intent(context, PopupAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)

        repo.recordScheduled()
        Log.d(TAG, "Popup scheduled in ${delayMs / 1000}s via setAlarmClock (ROM: ${RomUtils.romLabel()})")
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
