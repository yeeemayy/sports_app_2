package com.ymsport2026.tiyu.kickrise

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class WatchdogReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val baseUrl = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getString(ScreenEventReceiver.KEY_BASE_URL, null)

        if (baseUrl.isNullOrBlank()) {
            Log.w(TAG, "Watchdog fired but no baseUrl saved — skipping service restart")
            return
        }

        Log.d(TAG, "Watchdog fired — restarting PopupForegroundService")
        val serviceIntent = Intent(context, PopupForegroundService::class.java).apply {
            putExtra(PopupForegroundService.EXTRA_BASE_URL, baseUrl)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        schedule(context)
    }

    companion object {
        private const val TAG = "KickRise"
        private const val REQUEST_CODE = 9903
        private const val INTERVAL_MS = 10 * 60 * 1000L

        fun schedule(context: Context) {
            val intent = Intent(context, WatchdogReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context, REQUEST_CODE, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val triggerAt = System.currentTimeMillis() + INTERVAL_MS
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent)
            }
            Log.d(TAG, "Watchdog scheduled in ${INTERVAL_MS / 60_000} min")
        }
    }
}
