package com.tiyu2.tiyu.kickrise

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.tiyu2.tiyu.R

object PopupDeliveryFallback {

    fun launchActivity(context: Context, reporter: EventReporter?, tag: String): Boolean {
        return try {
            context.startActivity(Intent(context, PopupActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra(PopupActivity.EXTRA_LAUNCH_ROUTE, "activity_direct")
                putExtra(PopupActivity.EXTRA_LAUNCH_SOURCE, tag)
            })
            reporter?.reportLog(LogLevel.INFO, "PopupActivity launched directly", tag = tag)
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "activity_direct", "source" to tag, "success" to true))
            true
        } catch (e: Exception) {
            reporter?.reportLog(LogLevel.WARN, "Direct PopupActivity launch failed: ${e.message}", tag = tag)
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "activity_direct", "source" to tag, "success" to false,
                    "error" to e.javaClass.simpleName))
            false
        }
    }

    fun showFullScreenNotification(
        context: Context,
        creative: PopupCreative,
        reporter: EventReporter?,
        tag: String
    ): Boolean {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        val notificationEnabled = NotificationManagerCompat.from(context).areNotificationsEnabled()
        val canUseFsi = Build.VERSION.SDK_INT < 34 || nm.canUseFullScreenIntent()
        val channelImportance = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.getNotificationChannel(PopupAlarmReceiver.POPUP_CHANNEL_ID)?.importance ?: -1
        } else -1

        reporter?.reportLog(LogLevel.INFO, "Full-screen notification attempt", tag = tag,
            context = mapOf(
                "sdk" to Build.VERSION.SDK_INT, "notification_enabled" to notificationEnabled,
                "can_use_fsi" to canUseFsi, "channel_importance" to channelImportance
            ))

        if (!canUseFsi) {
            reporter?.reportLog(
                LogLevel.WARN,
                "USE_FULL_SCREEN_INTENT not granted, trying direct activity fallback",
                tag = tag,
                context = mapOf("sdk" to Build.VERSION.SDK_INT, "notification_enabled" to notificationEnabled)
            )
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "fullscreen_notification", "source" to tag,
                    "success" to false, "error" to "fsi_unavailable"))
            return launchActivity(context, reporter, tag)
        }

        ensurePopupChannel(context)

        val activityIntent = Intent(context, PopupActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra(PopupActivity.EXTRA_LAUNCH_ROUTE, "fullscreen_notification")
            putExtra(PopupActivity.EXTRA_LAUNCH_SOURCE, tag)
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 0, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, PopupAlarmReceiver.POPUP_CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle("赛事监控中")
            .setContentText("")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setVibrate(longArrayOf(0, 300))
            .setAutoCancel(true)
            .build()

        return try {
            nm.notify(PopupAlarmReceiver.POPUP_NOTIFICATION_ID, notification)
            reporter?.reportLog(LogLevel.INFO, "Full-screen notification posted", tag = tag,
                context = mapOf("notification_enabled" to notificationEnabled, "channel_importance" to channelImportance))
            reporter?.reportLog(LogLevel.INFO, "fsi_posted", tag = "funnel",
                context = mapOf(
                    "sdk" to Build.VERSION.SDK_INT,
                    "notification_enabled" to notificationEnabled,
                    "can_use_fsi" to canUseFsi,
                    "channel_importance" to channelImportance
                ))
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "fullscreen_notification", "source" to tag,
                    "success" to true, "posted" to true))
            true
        } catch (e: SecurityException) {
            reporter?.reportLog(LogLevel.ERROR, "Notification permission denied", tag = tag,
                context = mapOf("exception" to e.javaClass.simpleName, "message" to (e.message ?: "")))
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "fullscreen_notification", "source" to tag,
                    "success" to false, "error" to e.javaClass.simpleName))
            false
        } catch (e: Exception) {
            reporter?.reportLog(LogLevel.ERROR, "Full-screen notification failed", tag = tag,
                context = mapOf("exception" to e.javaClass.simpleName, "message" to (e.message ?: "")))
            reporter?.reportLog(LogLevel.INFO, "popup_activity_launch_attempt", tag = "funnel",
                context = mapOf("route" to "fullscreen_notification", "source" to tag,
                    "success" to false, "error" to e.javaClass.simpleName))
            false
        }
    }

    fun vibrateWakeFailure(context: Context, reporter: EventReporter?, tag: String) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                manager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            val pattern = longArrayOf(0, 300, 200, 300, 200, 500)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
            } else {
                @Suppress("DEPRECATION")
                vibrator.vibrate(pattern, -1)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Vibration fallback failed: ${e.message}")
            reporter?.reportLog(LogLevel.WARN, "Vibration fallback failed: ${e.message}", tag = tag)
        }
    }

    private fun ensurePopupChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                PopupAlarmReceiver.POPUP_CHANNEL_ID, "KickRise Popup", NotificationManager.IMPORTANCE_HIGH
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

    private const val TAG = "KickRise"
}
