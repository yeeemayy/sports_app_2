package com.tiyu2.tiyu.kickrise

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class CanaryReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .edit().putLong(KEY_CANARY_LAST_FIRED_MS, System.currentTimeMillis()).apply()

        val baseUrl = EventReporter.getBaseUrl(context)
        Log.d(TAG, "Canary alarm fired — alarm delivery confirmed (ROM: ${RomUtils.romLabel()})")
        if (baseUrl.isNotBlank()) {
            EventReporter(context, baseUrl).reportLog(
                LogLevel.INFO, "Canary alarm fired — alarm delivery confirmed",
                tag = "canary",
                context = mapOf("rom" to RomUtils.romLabel(), "domestic" to RomUtils.isAggressiveOemRom())
            )
        }
    }

    companion object {
        private const val TAG = "KickRise"
        const val KEY_CANARY_LAST_FIRED_MS = "kickrise_canary_last_fired_ms"
        private const val REQUEST_CODE = 9904
        private const val CANARY_DELAY_MS = 60_000L

        fun schedule(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val intent = Intent(context, CanaryReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context, REQUEST_CODE, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val triggerAt = System.currentTimeMillis() + CANARY_DELAY_MS
            alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)
            Log.d(TAG, "Canary alarm scheduled in ${CANARY_DELAY_MS / 1000}s")
        }
    }
}
