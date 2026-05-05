package com.ymsport2026.tiyu.kickrise

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
import com.ymsport2026.tiyu.R

object PopupDeliveryFallback {

    fun launchActivity(context: Context, reporter: EventReporter?, tag: String): Boolean {
        return try {
            context.startActivity(Intent(context, PopupActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            })
            reporter?.reportLog(LogLevel.INFO, "PopupActivity launched directly", tag = tag)
            true
        } catch (e: Exception) {
            reporter?.reportLog(LogLevel.WARN, "Direct PopupActivity launch failed: ${e.message}", tag = tag)
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

        if (Build.VERSION.SDK_INT >= 34 && !nm.canUseFullScreenIntent()) {
            reporter?.reportLog(
                LogLevel.WARN,
                "USE_FULL_SCREEN_INTENT not granted, trying direct activity fallback",
                tag = tag
            )
            return launchActivity(context, reporter, tag)
        }

        ensurePopupChannel(context)

        val activityIntent = Intent(context, PopupActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val fullScreenPendingIntent = PendingIntent.getActivity(
            context, 0, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, PopupAlarmReceiver.POPUP_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
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
            reporter?.reportLog(LogLevel.INFO, "Full-screen notification posted", tag = tag)
            true
        } catch (e: SecurityException) {
            reporter?.reportLog(LogLevel.ERROR, "Notification permission denied: ${e.message}", tag = tag)
            false
        } catch (e: Exception) {
            reporter?.reportLog(LogLevel.ERROR, "Full-screen notification failed: ${e.message}", tag = tag)
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
