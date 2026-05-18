package com.tiyu2.tiyu.kickrise

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
        val keyguardShowing = km.isKeyguardLocked
        val deviceLocked = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) km.isDeviceLocked else keyguardShowing
        val isInteractive = pm.isInteractive
        val prefs = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
        val screenOffAt = prefs.getLong(ScreenEventReceiver.KEY_SCREEN_OFF_AT, 0L)
        val screenOffObserved = screenOffAt > 0L && (System.currentTimeMillis() - screenOffAt) < SCREEN_OFF_STALE_MS
        val effectiveLocked = keyguardShowing || deviceLocked || !isInteractive || screenOffObserved
        val appAlive = isAppAlive(context)
        val inRecents = isAppInRecents(context)
        val appAliveAgeMs = if (appAlive) appAliveAgeMs(context) else -1L
        val appAliveStale = appAlive && appAliveAgeMs >= APP_ALIVE_STALE_MS
        val lastLifecycleEvent = prefs.getString(KEY_LAST_LIFECYCLE_EVENT, "unknown") ?: "unknown"

        Log.d(TAG, "Alarm received — source=$alarmSource config=${config != null}, enabled=${config?.enabled}, creative=${creative != null}")
        reporter.reportLog(LogLevel.INFO, "Alarm received", tag = "alarm",
            context = mapOf(
                "source" to alarmSource,
                "has_config" to (config != null),
                "enabled" to (config?.enabled ?: false),
                "has_creative" to (creative != null),
                "rom" to RomUtils.romLabel(),
                "locked" to effectiveLocked,
                "keyguard_showing" to keyguardShowing,
                "device_locked" to deviceLocked,
                "interactive" to isInteractive,
                "screen_off_observed" to screenOffObserved,
                "lock_source" to when {
                    keyguardShowing -> "keyguard"
                    deviceLocked -> "device_locked"
                    !isInteractive -> "not_interactive"
                    screenOffObserved -> "screen_off_flag"
                    else -> "none"
                },
                "app_alive" to appAlive,
                "app_alive_age_ms" to appAliveAgeMs,
                "app_alive_stale" to appAliveStale,
                "last_lifecycle_event" to lastLifecycleEvent,
                "in_recents" to inRecents,
                "retry_count" to retryCount
            ))
        reporter.reportLog(LogLevel.INFO, "delivery_attempt_start", tag = "funnel",
            context = mapOf(
                "source" to alarmSource,
                "locked" to effectiveLocked,
                "interactive" to isInteractive,
                "app_alive" to appAlive,
                "app_alive_age_ms" to appAliveAgeMs,
                "app_alive_stale" to appAliveStale,
                "last_lifecycle_event" to lastLifecycleEvent,
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

        // Only skip when the user is actively using the app (alive + screen on).
        // If the screen is locked, appAlive may be stale (flag not yet cleared by onStop on some
        // OEMs, e.g. Huawei/HarmonyOS) — don't let it suppress a legitimate lock-screen popup.
        // appAliveStale covers the case where onTaskRemoved() never fired (Honor/OPPO): if the
        // flag is older than APP_ALIVE_STALE_MS we treat it as unreliable and proceed with delivery.
        // The primary guard against stale-flag false-positives is cancelling the retry alarm in
        // MainActivity.onResume(); the staleness window is a secondary defence.
        val effectiveAppAlive = appAlive && !appAliveStale
        if (effectiveAppAlive && !effectiveLocked) {
            Log.d(TAG, "Popup skipped: app is in foreground")
            reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is in foreground", tag = "alarm",
                throttleKey = "app_alive")
            reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                context = mapOf(
                    "reason" to "app_alive",
                    "source" to alarmSource,
                    "locked" to effectiveLocked,
                    "interactive" to isInteractive,
                    "app_alive_age_ms" to appAliveAgeMs,
                    "app_alive_stale" to appAliveStale,
                    "last_lifecycle_event" to lastLifecycleEvent,
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
            if (!effectiveLocked) {
                Log.d(TAG, "Fallback alarm: device not locked — skipping (in_recents=$inRecents)")
                reporter.reportLog(LogLevel.INFO, "fallback_alarm_skipped_not_locked", tag = "alarm",
                    context = mapOf(
                        "source" to alarmSource, "in_recents" to inRecents,
                        "rom" to RomUtils.romLabel(), "retry_count" to retryCount,
                        "keyguard_showing" to keyguardShowing,
                        "device_locked" to deviceLocked,
                        "interactive" to isInteractive,
                        "screen_off_observed" to screenOffObserved
                    ))
                if (retryCount < MAX_FALLBACK_LOCK_RETRIES) {
                    scheduleFallbackRetry(context, reporter, retryCount + 1)
                } else {
                    reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                        context = mapOf(
                            "reason" to "not_locked",
                            "source" to alarmSource,
                            "locked" to effectiveLocked,
                            "interactive" to isInteractive,
                            "in_recents" to inRecents,
                            "retry_count" to retryCount
                        ))
                }
                wl.release()
                return
            }
            // Device is locked — verify the app was genuinely killed (swipe), not just backgrounded (HOME).
            // MIUI: onTaskRemoved fires after swipe-kill so the flag is accurate; appTasks stays
            //   non-empty on MIUI even after a kill, so we must use the flag there.
            // HUAWEI/HarmonyOS: onTaskRemoved never fires AND appTasks stays non-empty after a swipe-kill,
            //   so both methods always return "still in recents" and the popup is permanently suppressed.
            //   Trade-off accepted: skip the recents gate for HUAWEI. This means a HOME-then-lock flow
            //   can also deliver the popup, not just a swipe-then-lock flow. That is acceptable because
            //   the device is locked in both cases — the user is not actively using the app — and there
            //   is no reliable mechanism on HarmonyOS to distinguish the two paths.
            // Other ROMs: use getAppTasks() as a live check (non-empty = HOME press, empty = swipe-kill).
            val rom = RomUtils.detect()
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
            val (stillInRecents, recentsCheck) = when (rom) {
                RomUtils.RomType.XIAOMI -> inRecents to "flag"
                RomUtils.RomType.HUAWEI -> false to "skipped_huawei"
                else -> am.appTasks.isNotEmpty() to "get_app_tasks"
            }
            if (stillInRecents) {
                Log.d(TAG, "Fallback alarm: app still in recents (HOME press) — suppressing popup")
                reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                    context = mapOf(
                        "reason" to "app_in_recents",
                        "source" to alarmSource,
                        "locked" to effectiveLocked,
                        "check" to recentsCheck,
                        "rom" to RomUtils.romLabel()
                    ))
                wl.release()
                return
            }
        } else {
            // Huawei/HarmonyOS: onTaskRemoved() is unreliable so in_recents can stay true
            // indefinitely after a swipe-kill. When the device is locked, skip the in_recents
            // gate on Huawei — the popup would not interrupt an active user in that state.
            val skipRecentsOnHuawei = effectiveLocked && RomUtils.detect() == RomUtils.RomType.HUAWEI
            if (inRecents && !skipRecentsOnHuawei) {
                Log.d(TAG, "Popup skipped: app is backgrounded (still in recents)")
                reporter.reportLogThrottled(LogLevel.INFO, "Popup skipped: app is backgrounded (still in recents)", tag = "alarm",
                    throttleKey = "app_recents")
                reporter.reportLog(LogLevel.INFO, "delivery_attempt_blocked", tag = "funnel",
                    context = mapOf(
                        "reason" to "in_recents",
                        "source" to alarmSource,
                        "locked" to effectiveLocked,
                        "interactive" to isInteractive,
                        "in_recents" to inRecents
                    ))
                wl.release()
                return
            } else if (inRecents) {
                reporter.reportLog(LogLevel.INFO, "in_recents_skipped_huawei_locked", tag = "funnel",
                    context = mapOf(
                        "in_recents" to inRecents,
                        "locked" to effectiveLocked,
                        "rom" to RomUtils.romLabel()
                    ))
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

    /** Returns ms since app_alive was last set true, or Long.MAX_VALUE if never recorded. */
    private fun appAliveAgeMs(context: Context): Long {
        val setAt = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getLong(KEY_APP_ALIVE_SET_AT, 0L)
        return if (setAt > 0L) System.currentTimeMillis() - setAt else Long.MAX_VALUE
    }

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
        private const val SCREEN_OFF_STALE_MS = 30 * 60 * 1_000L
        // Public so MainActivity.onResume() can cancel the retry alarm without needing a
        // separate request code constant. Keep in sync with scheduleFallbackRetry().
        const val REQUEST_CODE_FALLBACK_RETRY = 9906
        // 60 s per retry — long enough for the user to finish in settings and lock the phone.
        // The old 10 s value caused the retry to fire while app_alive=true (user back in foreground
        // right after granting overlay/notification permission), permanently blocking delivery.
        private const val FALLBACK_LOCK_RETRY_DELAY_MS = 60_000L
        private const val MAX_FALLBACK_LOCK_RETRIES = 6
        // app_alive is considered stale if it was written more than this long ago. Covers the case
        // where onTaskRemoved() did not fire (Huawei/OPPO OEMs) so the true→false transition was
        // never persisted. Primary guard is cancelling the retry in onResume(); this is secondary.
        private const val APP_ALIVE_STALE_MS = 30_000L
        const val POPUP_CHANNEL_ID = "kickrise_popup_channel"
        const val POPUP_NOTIFICATION_ID = 9902
        const val KEY_APP_ALIVE = "kickrise_app_alive"
        const val KEY_APP_ALIVE_SET_AT = "kickrise_app_alive_set_at"
        const val KEY_LAST_LIFECYCLE_EVENT = "kickrise_last_lifecycle_event"
        const val KEY_APP_IN_RECENTS = "kickrise_app_in_recents"
        const val EXTRA_ALARM_SOURCE = "alarm_source"
        const val EXTRA_RETRY_COUNT = "retry_count"
    }
}
