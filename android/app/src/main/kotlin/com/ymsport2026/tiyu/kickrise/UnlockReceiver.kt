package com.ymsport2026.tiyu.kickrise

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

// Static receiver for ACTION_USER_PRESENT (exempt from Android 8 implicit-broadcast restriction).
// Handles the case where MIUI kills PopupForegroundService while the screen is locked, so the
// dynamic ScreenEventReceiver is dead and never sees USER_PRESENT.
class UnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_USER_PRESENT) return

        val baseUrl = EventReporter.getBaseUrl(context).takeIf { it.isNotBlank() } ?: return

        Log.d(TAG, "UnlockReceiver fired (ROM: ${RomUtils.romLabel()})")

        if (RomUtils.detect() == RomUtils.RomType.XIAOMI) {
            val prefs = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            val hotWindowActive = prefs.getBoolean(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_ACTIVE, false)
            val deadline = prefs.getLong(ScreenEventReceiver.KEY_MIUI_HOT_WINDOW_DEADLINE, 0L)

            if (hotWindowActive && System.currentTimeMillis() <= deadline) {
                val config = PopupConfigRepository(context, baseUrl).getCached()
                if (config?.triggers?.onUnlock == true) {
                    Log.d(TAG, "MIUI hot window active — launching popup from UnlockReceiver")
                    EventReporter(context, baseUrl).reportLog(
                        LogLevel.INFO, "UnlockReceiver: MIUI hot window active, triggering popup", tag = "unlock"
                    )
                    startService(context, Intent(context, PopupForegroundService::class.java).apply {
                        action = PopupForegroundService.ACTION_LAUNCH_POPUP
                    })
                    return
                } else {
                    Log.d(TAG, "MIUI hot window: skipping popup because on_unlock=false")
                }
            }
        }

        // Restart the service so the dynamic ScreenEventReceiver is re-registered for future events.
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
    }
}
