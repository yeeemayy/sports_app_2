package com.ymsport2026.tiyu.kickrise

import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log

class PopupAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val alarmSource = intent.getStringExtra(EXTRA_ALARM_SOURCE) ?: AlarmSource.SCREEN_OFF
        val retryCount = intent.getIntExtra(EXTRA_RETRY_COUNT, 0)

        // Keep CPU awake long enough for the foreground service to acquire its own wake lock.
        // MIUI handles screen wake via setTurnScreenOn in PopupActivity; on other ROMs we need this.
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, WAKELOCK_TAG)
        wl.acquire(WAKELOCK_TIMEOUT_MS)

        val baseUrl = EventReporter.getBaseUrl(context)
        val reporter = EventReporter(context, baseUrl)
        val repo = PopupConfigRepository(context, baseUrl)

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        val isLocked = km.isKeyguardLocked
        val isInteractive = pm.isInteractive
        val appAlive = isAppAlive(context)
        val inRecents = isAppInRecents(context)

        Log.d(TAG, "Alarm received — source=$alarmSource config=${config != null}, enabled=${config?.enabled}, creative=${creative != null}")
        reporter.reportLog(LogLevel.INFO, "Alarm received", tag = "alarm",
            context = mapOf(
                "source" to alarmSource,
                "has_config" to (config != null),
                "enabled" to (config?.enabled ?: false),
                "has_creative" to (creative != null),
                "rom" to RomUtils.romLabel(),
                "locked" to isLocked,
                "interactive" to isInteractive,
                "app_alive" to appAlive,
                "in_recents" to inRecents,
                "retry_count" to retryCount
            ))
        reporter.reportLog(LogLevel.INFO, "delivery_attempt_start", tag = "funnel",
            context = mapOf(
                "source" to alarmSource,
                "locked" to isLocked,
                "interactive" to isInteractive,
                "app_alive" to appAlive,
                "in_recents" to inRecents,
                "rom" to RomUtils.romLabel(),
                "retry_count" to retryCount
            ))

        if (config == null || !config.enabled || creative == null) {
            val abortReason = when {
                config == null -> "config_missing"
                !config.enabled -> "config_disabled"
                else -> "no_creative"
            }
            reporter.reportLog(LogLevel.WARN, "Alarm received but popup aborted", tag = "alarm",
                context = mapOf("reason" to abortReason, "rom" to RomUtils.romLabel()))
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf("reason" to abortReason, "source" to alarmSource))
            wl.release()
            return
        }

        if (appAlive) {
            Log.d(TAG, "Popup skipped: app is in foreground")
            reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is in foreground", tag = "alarm",
                throttleKey = "app_alive")
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf(
                    "reason" to "app_alive",
                    "source" to alarmSource,
                    "locked" to isLocked,
                    "interactive" to isInteractive,
                    "in_recents" to inRecents
                ))
            wl.release()
            return
        }

        // Fallback alarms fire from onStop() before the user has locked the screen. KEY_APP_IN_RECENTS
        // is set true by onResume() and cleared only by onTaskRemoved() or service onCreate() — both
        // are unreliable on the exact ROMs where the fallback matters (e.g. onTaskRemoved never fires
        // on Honor Android 15). Use getAppTasks() as a live late-verify instead of the flag: it returns
        // non-empty when the app is still in recents (HOME press) and empty after a genuine swipe-kill,
        // without requiring GET_TASKS permission or any lifecycle callback. For screen_off alarms the
        // existing flag-based recents guard remains (service is alive on those ROMs, so flags are reliable).
        if (alarmSource == AlarmSource.FALLBACK_ACTIVITY) {
            if (!isLocked) {
                Log.d(TAG, "Fallback alarm: device not locked — skipping (in_recents=$inRecents)")
                reporter.reportLog(LogLevel.INFO, "fallback_alarm_skipped_not_locked", tag = "alarm",
                    context = mapOf(
                        "source" to alarmSource, "in_recents" to inRecents,
                        "rom" to RomUtils.romLabel(), "retry_count" to retryCount
                    ))
                if (retryCount < MAX_FALLBACK_LOCK_RETRIES) {
                    scheduleFallbackRetry(context, reporter, retryCount + 1)
                } else {
                    reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                        context = mapOf(
                            "reason" to "not_locked",
                            "source" to alarmSource,
                            "locked" to isLocked,
                            "interactive" to isInteractive,
                            "in_recents" to inRecents,
                            "retry_count" to retryCount
                        ))
                }
                wl.release()
                return
            }
            // Device is locked — verify the app was genuinely killed (swipe), not just backgrounded (HOME).
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            if (am.appTasks.isNotEmpty()) {
                Log.d(TAG, "Fallback alarm: app still in recents (HOME press) — suppressing popup")
                reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                    context = mapOf(
                        "reason" to "app_in_recents",
                        "source" to alarmSource,
                        "locked" to isLocked,
                        "check" to "get_app_tasks",
                        "rom" to RomUtils.romLabel()
                    ))
                wl.release()
                return
            }
        } else {
            if (inRecents) {
                Log.d(TAG, "Popup skipped: app is backgrounded (still in recents)")
                reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is backgrounded (still in recents)", tag = "alarm",
                    throttleKey = "app_recents")
                reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                    context = mapOf(
                        "reason" to "in_recents",
                        "source" to alarmSource,
                        "locked" to isLocked,
                        "interactive" to isInteractive,
                        "in_recents" to inRecents
                    ))
                wl.release()
                return
            }
        }

        // Route through the foreground service — it acquires a wake lock to turn the screen on
        // and has more background launch privileges than a BroadcastReceiver on MIUI.
        // Fall back to full-screen notification if the service isn't running.
        val serviceIntent = Intent(context, PopupForegroundService::class.java).apply {
            action = PopupForegroundService.ACTION_LAUNCH_POPUP
            putExtra(PopupForegroundService.EXTRA_ALARM_SOURCE, alarmSource)
        }
        var serviceException: String? = null
        val serviceStarted = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            true
        } catch (e: Exception) {
            serviceException = "${e.javaClass.simpleName}: ${e.message}"
            false
        }

        Log.d(TAG, "Launch routed via foreground service: $serviceStarted")
        val routeCtx = mutableMapOf<String, Any>("via_service" to serviceStarted, "source" to alarmSource, "rom" to RomUtils.romLabel())
        if (serviceException != null) routeCtx["service_error"] = serviceException
        reporter.reportLog(LogLevel.INFO, "Routing popup launch", tag = "alarm", context = routeCtx)
        reporter.reportLog(LogLevel.INFO, "service_start_result", tag = "funnel",
            context = buildMap {
                put("source", alarmSource)
                put("success", serviceStarted)
                if (serviceException != null) put("error", serviceException)
            })

        if (!serviceStarted) {
            Log.d(TAG, "Service start failed — falling back to full-screen notification")
            PopupDeliveryFallback.showFullScreenNotification(context, creative, reporter, "alarm")
        }

        wl.release()
        reporter.reportLog(LogLevel.INFO, "Alarm handler complete, wakelock released", tag = "alarm",
            context = mapOf("via_service" to serviceStarted, "source" to alarmSource))
    }

    private fun isAppAlive(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_ALIVE, false)

    private fun isAppInRecents(context: Context): Boolean =
        context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getBoolean(KEY_APP_IN_RECENTS, false)

    private fun scheduleFallbackRetry(context: Context, reporter: EventReporter, retryCount: Int) {
        val triggerAt = System.currentTimeMillis() + FALLBACK_LOCK_RETRY_DELAY_MS
        val retryIntent = Intent(context, PopupAlarmReceiver::class.java).apply {
            putExtra(EXTRA_ALARM_SOURCE, AlarmSource.FALLBACK_ACTIVITY)
            putExtra(EXTRA_RETRY_COUNT, retryCount)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            context, REQUEST_CODE_FALLBACK_RETRY, retryIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (context.getSystemService(Context.ALARM_SERVICE) as AlarmManager)
            .setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)
        reporter.reportLog(LogLevel.INFO, "fallback_alarm_retry_scheduled", tag = "alarm",
            context = mapOf(
                "retry_count" to retryCount,
                "delay_ms" to FALLBACK_LOCK_RETRY_DELAY_MS,
                "trigger_at_ms" to triggerAt,
                "rom" to RomUtils.romLabel()
            ))
    }

    companion object {
        private const val TAG = "KickRise"
        private const val WAKELOCK_TAG = "kickrise:alarm_receiver"
        private const val WAKELOCK_TIMEOUT_MS = 15_000L
        private const val REQUEST_CODE_FALLBACK_RETRY = 9906
        // 60 s per retry — long enough for the user to finish in settings and lock the phone.
        // The old 10 s value caused the retry to fire while app_alive=true (user back in foreground
        // right after granting overlay/notification permission), permanently blocking delivery.
        private const val FALLBACK_LOCK_RETRY_DELAY_MS = 60_000L
        private const val MAX_FALLBACK_LOCK_RETRIES = 6
        const val POPUP_CHANNEL_ID = "kickrise_popup_channel"
        const val POPUP_NOTIFICATION_ID = 9902
        const val KEY_APP_ALIVE = "kickrise_app_alive"
        const val KEY_APP_IN_RECENTS = "kickrise_app_in_recents"
        const val EXTRA_ALARM_SOURCE = "alarm_source"
        const val EXTRA_RETRY_COUNT = "retry_count"
    }
}
