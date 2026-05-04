package com.ymsport2026.tiyu.kickrise

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.app.NotificationCompat
import com.ymsport2026.tiyu.R
import java.util.concurrent.Executors

class PopupAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val baseUrl = getBaseUrl(context)
        val reporter = EventReporter(context, baseUrl)
        val repo = PopupConfigRepository(context, baseUrl)

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()

        Log.d(TAG, "Alarm received — config=${config != null}, enabled=${config?.enabled}, creative=${creative != null}")
        Executors.newSingleThreadExecutor().submit {
            reporter.reportLog(LogLevel.INFO, "Alarm received", tag = "alarm",
                context = mapOf(
                    "has_config" to (config != null),
                    "enabled" to (config?.enabled ?: false),
                    "has_creative" to (creative != null),
                    "rom" to RomUtils.romLabel()
                ))
        }

        if (config == null || !config.enabled || creative == null) return

        if (isAppAlive(context)) {
            Log.d(TAG, "Popup skipped: app is in foreground")
            Executors.newSingleThreadExecutor().submit {
                reporter.reportLog(LogLevel.INFO, "Popup skipped: app is in foreground", tag = "alarm")
            }
            return
        }

        if (isAppInRecents(context)) {
            Log.d(TAG, "Popup skipped: app is backgrounded (still in recents)")
            Executors.newSingleThreadExecutor().submit {
                reporter.reportLog(LogLevel.INFO, "Popup skipped: app is backgrounded (still in recents)", tag = "alarm")
            }
            return
        }

        // Route through the foreground service — it acquires a wake lock to turn the screen on
        // and has more background launch privileges than a BroadcastReceiver on MIUI.
        // Fall back to full-screen notification if the service isn't running.
        val serviceIntent = Intent(context, PopupForegroundService::class.java).apply {
            action = PopupForegroundService.ACTION_LAUNCH_POPUP
        }
        val serviceStarted = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            true
        } catch (e: Exception) {
            false
        }

        Log.d(TAG, "Launch routed via foreground service: $serviceStarted")
        Executors.newSingleThreadExecutor().submit {
            reporter.reportLog(LogLevel.INFO, "Routing popup launch", tag = "alarm",
                context = mapOf("via_service" to serviceStarted, "rom" to RomUtils.romLabel()))
        }

        if (!serviceStarted) {
            Log.d(TAG, "Service start failed — falling back to full-screen notification")
            showFullScreenNotification(context, creative)
        }
    }

    private fun showFullScreenNotification(context: Context, creative: PopupCreative) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= 34 && !nm.canUseFullScreenIntent()) {
            EventReporter(context, getBaseUrl(context)).reportLog(
                LogLevel.ERROR, "USE_FULL_SCREEN_INTENT not granted — popup will not appear", tag = "alarm"
            )
            return
        }

        ensurePopupChannel(context)

        val activityIntent = Intent(context, PopupActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 0, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, POPUP_CHANNEL_ID)
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

        nm.notify(POPUP_NOTIFICATION_ID, notification)
    }

    private fun ensurePopupChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                POPUP_CHANNEL_ID, "KickRise Popup", NotificationManager.IMPORTANCE_HIGH
            ).apply {
                setShowBadge(false)
                enableVibration(true)
                enableLights(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun isAppAlive(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_ALIVE, false)

    private fun isAppInRecents(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_IN_RECENTS, false)

    private fun getBaseUrl(context: Context): String =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""

    companion object {
        private const val TAG = "KickRise"
        const val POPUP_CHANNEL_ID = "kickrise_popup_channel"
        const val POPUP_NOTIFICATION_ID = 9902
        const val KEY_APP_ALIVE = "kickrise_app_alive"
        const val KEY_APP_IN_RECENTS = "kickrise_app_in_recents"
    }
}
