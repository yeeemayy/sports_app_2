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
        val repo = PopupConfigRepository(context, getBaseUrl(context))
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
                if (config.triggers.onLock) schedulePopup(context, config)
            }
            Intent.ACTION_USER_PRESENT -> {
                if (config.triggers.onUnlock) schedulePopup(context, config)
            }
        }
    }

    private fun schedulePopup(context: Context, config: PopupConfig) {
        val repo = PopupConfigRepository(context, getBaseUrl(context))
        val reporter = EventReporter(context, getBaseUrl(context))
        reporter.incrementTriggerCount()

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

        val triggerAt = System.currentTimeMillis() + config.frequency.defaultDelayMs
        val alarmIntent = Intent(context, PopupAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            alarmManager.set(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
        }

        repo.recordScheduled()
        Log.d(TAG, "Popup scheduled in ${config.frequency.defaultDelayMs / 1000}s (ROM: ${RomUtils.romLabel()})")
    }

    private fun getBaseUrl(context: Context): String =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_BASE_URL, "") ?: ""

    companion object {
        private const val TAG = "KickRise"
        private const val REQUEST_CODE = 9901
        const val KEY_BASE_URL = "kickrise_base_url"
    }
}
