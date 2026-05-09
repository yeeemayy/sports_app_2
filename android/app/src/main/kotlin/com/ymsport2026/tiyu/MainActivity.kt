package com.ymsport2026.tiyu

import android.app.ActivityManager
import android.app.AlarmManager
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ymsport2026.tiyu.kickrise.AlarmSource
import com.ymsport2026.tiyu.kickrise.EventReporter
import com.ymsport2026.tiyu.kickrise.LogLevel
import com.ymsport2026.tiyu.kickrise.OemPermissionRoutes
import com.ymsport2026.tiyu.kickrise.PopupAlarmReceiver
import com.ymsport2026.tiyu.kickrise.PopupConfigRepository
import com.ymsport2026.tiyu.kickrise.PopupForegroundService
import com.ymsport2026.tiyu.kickrise.RemoteRouteConfig
import com.ymsport2026.tiyu.kickrise.RomUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "kickrise/popup"

    companion object {
        private const val TAG = "KickRise/main"
        private const val REQUEST_CODE_NOTIFICATIONS = 1001
        private const val REQUEST_CODE_FALLBACK_ALARM = 9904
        private const val KEY_AUTOSTART_SHOWN = "kickrise_autostart_shown"
        private const val KEY_BATTERY_SHOWN = "kickrise_battery_shown"
        private const val KEY_FSI_SHOWN = "kickrise_fsi_shown"
        private const val KEY_FSI_SETTINGS_OPENED = "kickrise_fsi_settings_opened"
        private const val KEY_LAST_OVERLAY_ROUTE = "kickrise_last_overlay_route"
        private const val KEY_LAST_OVERLAY_ACTION = "kickrise_last_overlay_action"
        private const val KEY_LAST_OVERLAY_COMPONENT = "kickrise_last_overlay_component"
        private const val KEY_OVERLAY_SETTINGS_OPENED = "kickrise_overlay_settings_opened"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val baseUrl = call.argument<String>("baseUrl") ?: ""
                    if (baseUrl.isBlank()) {
                        result.error("INVALID_ARGS", "baseUrl is required", null)
                        return@setMethodCallHandler
                    }
                    startPopupService(baseUrl)
                    result.success(null)
                }
                "stopService" -> {
                    stopService(Intent(this, PopupForegroundService::class.java))
                    result.success(null)
                }
                "checkOverlayPermission" -> {
                    result.success(OverlayPermissionCompat.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    if (!OverlayPermissionCompat.needsUserGrant(this)) {
                        result.success("already_granted_or_not_required")
                        return@setMethodCallHandler
                    }
                    result.success(openOemOverlaySettings())
                }
                "isXiaomiDevice" -> {
                    result.success(RomUtils.detect() == RomUtils.RomType.XIAOMI)
                }
                "isDomesticDevice" -> {
                    result.success(RomUtils.isDomesticRom())
                }
                "checkBatteryOptimization" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestBatteryOptimization" -> {
                    openBatteryOptimizationSettings()
                    result.success(null)
                }
                "checkAndRequestNextPermission" -> {
                    result.success(checkAndRequestNextPermission())
                }
                "requestMiuiAutostart" -> {
                    result.success(openAutostartSettings())
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        ActivityCompat.requestPermissions(
                            this,
                            arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                            REQUEST_CODE_NOTIFICATIONS
                        )
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        setAppAlive(true)
        cancelFallbackAlarm()
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        prefs.edit().putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, true).apply()

        if (prefs.getBoolean(KEY_OVERLAY_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_OVERLAY_SETTINGS_OPENED, false).apply()
            val granted = OverlayPermissionCompat.canDrawOverlays(this)
            val lastRoute = prefs.getString(KEY_LAST_OVERLAY_ROUTE, "unknown") ?: "unknown"
            val lastAction = prefs.getString(KEY_LAST_OVERLAY_ACTION, "") ?: ""
            val lastComponent = prefs.getString(KEY_LAST_OVERLAY_COMPONENT, "") ?: ""
            val ctx = deviceContext() + mapOf(
                "last_overlay_route" to lastRoute,
                "last_overlay_action" to lastAction,
                "last_overlay_component" to lastComponent,
                "overlay_granted_after_resume" to granted
            )
            logOverlay("overlay_resume_check", ctx)
            logFunnel("overlay_granted_after_resume", mapOf(
                "granted" to granted,
                "last_route" to lastRoute,
                "last_component" to lastComponent
            ) + deviceContext())
        }

        if (Build.VERSION.SDK_INT >= 34 && prefs.getBoolean(KEY_FSI_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_FSI_SETTINGS_OPENED, false).apply()
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            val fsiGranted = nm.canUseFullScreenIntent()
            logFunnel("fsi_granted_after_resume", deviceContext() + mapOf(
                "fsi_granted_after_resume" to fsiGranted
            ))
            if (!fsiGranted) {
                logFunnel("lockscreen_popup_capability", deviceContext() + mapOf(
                    "status" to "blocked_by_missing_fsi",
                    "sdk" to Build.VERSION.SDK_INT
                ))
            }
        }
    }

    override fun onStop() {
        super.onStop()
        setAppAlive(false)
        scheduleFallbackAlarm()
    }

    private fun setAppAlive(alive: Boolean) {
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, alive).apply()
    }

    // Schedules a fallback alarm from the activity so that popup delivery can proceed even if
    // the foreground service is killed before ACTION_SCREEN_OFF fires. Uses a separate request
    // code from the screen_off alarm so the two don't overwrite each other. Cancelled in
    // onResume(); policy checks in PopupAlarmReceiver prevent double-delivery.
    private fun scheduleFallbackAlarm() {
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isBlank()) return
        val config = PopupConfigRepository(this, baseUrl).getCached()
        if (config == null || !config.enabled) return
        val delayMs = config.frequency.defaultDelayMs.coerceAtLeast(5_000L)
        val triggerAt = System.currentTimeMillis() + delayMs
        val alarmIntent = Intent(this, PopupAlarmReceiver::class.java).apply {
            putExtra(PopupAlarmReceiver.EXTRA_ALARM_SOURCE, AlarmSource.FALLBACK_ACTIVITY)
        }
        val pendingIntent = PendingIntent.getBroadcast(
            this, REQUEST_CODE_FALLBACK_ALARM, alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        (getSystemService(ALARM_SERVICE) as AlarmManager)
            .setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, pendingIntent), pendingIntent)
        logFunnel("fallback_alarm_scheduled_from_activity", deviceContext() + mapOf(
            "delay_ms" to delayMs, "trigger_at_ms" to triggerAt
        ))
    }

    private fun cancelFallbackAlarm() {
        val alarmIntent = Intent(this, PopupAlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this, REQUEST_CODE_FALLBACK_ALARM, alarmIntent,
            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
        ) ?: return
        (getSystemService(ALARM_SERVICE) as AlarmManager).cancel(pendingIntent)
        pendingIntent.cancel()
    }

    private fun deviceContext(): Map<String, Any> {
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val romInfo = RomUtils.romInfo()
        return buildMap {
            put("rom", romInfo.romType.name)
            put("os_label", romInfo.osLabel)
            put("os_version", romInfo.osVersion)
            put("detection_source", romInfo.detectionSource)
            put("brand", Build.BRAND)
            put("model", Build.MODEL)
            put("display", Build.DISPLAY)
            put("sdk", Build.VERSION.SDK_INT)
            put("is_low_ram", am.isLowRamDevice)
        }
    }

    private fun logOverlay(message: String, ctx: Map<String, Any>) {
        Log.i("KickRise/overlay", "$message $ctx")
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, message, "overlay", ctx)
        }
    }

    private fun logFunnel(event: String, ctx: Map<String, Any>) {
        Log.i("KickRise/funnel", "$event $ctx")
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, event, "funnel", ctx)
        }
    }

    private fun startPopupService(baseUrl: String) {
        EventReporter.saveBaseUrl(this, baseUrl)

        // Emit ROM diagnostics once so field logs contain full prop context.
        val romInfo = RomUtils.romInfo()
        val props = RomUtils.diagnosticProps()
        Log.i(TAG, "ROM diagnostics: romType=${romInfo.romType} osLabel=${romInfo.osLabel} " +
            "osVersion=${romInfo.osVersion} detectionSource=${romInfo.detectionSource} " +
            "brand=${Build.BRAND} model=${Build.MODEL} display=${Build.DISPLAY} sdk=${Build.VERSION.SDK_INT} " +
            "props=$props")
        EventReporter(this, baseUrl).reportLog(
            LogLevel.INFO, "ROM diagnostics", "funnel",
            deviceContext() + mapOf("rom_props" to props.toString())
        )

        val serviceIntent = Intent(this, PopupForegroundService::class.java).apply {
            putExtra(PopupForegroundService.EXTRA_BASE_URL, baseUrl)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    // ─── Permission flow ──────────────────────────────────────────────────────────

    /**
     * Checks each permission in priority order and opens the first missing one.
     * Returns true if a prompt was shown (caller should stop and retry on next resume).
     *
     * Order: overlay → notification → FSI (Android 14+) → battery → autostart
     */
    private fun checkAndRequestNextPermission(): Boolean {
        val isDomestic = RomUtils.isDomesticRom()
        val baseCtx = deviceContext()

        if (isDomestic && OverlayPermissionCompat.needsUserGrant(this)) {
            val opened = openOemOverlaySettings()
            if (opened != "failed") {
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "overlay", "route" to opened))
                return true
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this, android.Manifest.permission.POST_NOTIFICATIONS
            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
            if (!granted) {
                ActivityCompat.requestPermissions(
                    this,
                    arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_CODE_NOTIFICATIONS
                )
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "notification"))
                return true
            }
        }

        // Android 14+: full-screen-intent requires an explicit user grant.
        // Fallback popup delivery is unreliable without it.
        // Shown at most once: if the user cannot grant it from the settings screen (e.g., only
        // app-details is available), we should not loop back on every resume.
        if (Build.VERSION.SDK_INT >= 34) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            val fsiShown = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
                .getBoolean(KEY_FSI_SHOWN, false)
            if (!nm.canUseFullScreenIntent() && !fsiShown) {
                val opened = openFsiPermissionSettings()
                if (opened) {
                    logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "fsi"))
                    return true
                }
            }
        }

        if (isDomestic) {
            val romType = RomUtils.detect()
            // isIgnoringBatteryOptimizations() does not reflect MIUI/ColorOS "No Restriction" state;
            // use a shown-flag as a best-effort signal for those OEMs.
            val oemBatteryRoms = setOf(
                RomUtils.RomType.XIAOMI, RomUtils.RomType.OPPO, RomUtils.RomType.REALME,
                RomUtils.RomType.ONEPLUS, RomUtils.RomType.VIVO, RomUtils.RomType.IQOO,
                RomUtils.RomType.HONOR, RomUtils.RomType.HUAWEI
            )
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            val confirmedByApi = pm.isIgnoringBatteryOptimizations(packageName)
            val shownBefore = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
                .getBoolean(KEY_BATTERY_SHOWN, false)
            val batteryDone = confirmedByApi || (romType in oemBatteryRoms && shownBefore)
            if (!batteryDone) {
                openBatteryOptimizationSettings()
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "battery"))
                return true
            }
        }

        if (isDomestic) {
            val opened = openAutostartSettings()
            if (opened) {
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "autostart"))
                return true
            }
        }

        return false
    }

    // ─── Settings route helpers ────────────────────────────────────────────────────

    /**
     * Opens the most direct overlay permission screen for this ROM.
     * Server-provided routes are tried first; local registry is the fallback.
     * Returns a label: "oem" | "standard" | "fallback" | "remote_oem" | "failed".
     */
    private fun openOemOverlaySettings(): String {
        val romType = RomUtils.detect()
        val baseUrl = EventReporter.getBaseUrl(this)
        val remoteRoutes = RemoteRouteConfig(this, baseUrl).getRoutesForType("overlay")
        val localRoutes = OemPermissionRoutes.overlayRoutes(romType)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = remoteRoutes + localRoutes

        val baseCtx = deviceContext()
        for ((intent, label) in candidates) {
            val action = intent.action ?: ""
            val component = intent.component?.flattenToShortString() ?: ""

            // resolveActivity() may return null on Android 11+ for explicit OEM components due to
            // package visibility, even when the target is present. Use it for diagnostic logging
            // only — always attempt startActivity() regardless of the result.
            val preResolved = try { packageManager.resolveActivity(intent, 0) != null } catch (_: Exception) { null }
            if (preResolved == false) {
                Log.d(TAG, "overlay pre_resolve=false (visibility restriction?): label=$label component=$component")
            }

            try {
                startActivity(intent)
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "overlay", "label" to label,
                    "component" to component, "pre_resolved" to (preResolved ?: "unknown")
                ))
                logOverlay("overlay_settings_opened", baseCtx + mapOf(
                    "intent_label" to label, "intent_action" to action,
                    "intent_component" to component, "start_success" to true
                ))
                getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                    .putString(KEY_LAST_OVERLAY_ROUTE, label)
                    .putString(KEY_LAST_OVERLAY_ACTION, action)
                    .putString(KEY_LAST_OVERLAY_COMPONENT, component)
                    .putBoolean(KEY_OVERLAY_SETTINGS_OPENED, true)
                    .apply()
                return label
            } catch (e: Exception) {
                Log.d(TAG, "overlay intent failed: label=$label action=$action component=$component error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "overlay", "label" to label,
                    "component" to component, "error" to e.javaClass.simpleName
                ))
            }
        }
        logOverlay("overlay_settings_failed", baseCtx + mapOf("start_success" to false))
        return "failed"
    }

    /**
     * Opens the autostart/background-launch settings for this ROM.
     * Returns true if any screen was opened. Shows at most once per install since there is
     * no API to confirm grant state — result is logged as "shown_not_confirmed".
     */
    private fun openAutostartSettings(): Boolean {
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        if (prefs.getBoolean(KEY_AUTOSTART_SHOWN, false)) return false

        val romType = RomUtils.detect()
        val baseUrl = EventReporter.getBaseUrl(this)
        val remoteRoutes = RemoteRouteConfig(this, baseUrl).getRoutesForType("autostart")
        val localRoutes = OemPermissionRoutes.autostartRoutes(romType)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = remoteRoutes + localRoutes

        val baseCtx = deviceContext()
        for ((intent, label) in candidates) {
            val component = intent.component?.flattenToShortString() ?: ""
            val preResolved = try { packageManager.resolveActivity(intent, 0) != null } catch (_: Exception) { null }
            if (preResolved == false) {
                Log.d(TAG, "autostart pre_resolve=false (visibility restriction?): component=$component")
            }
            try {
                startActivity(intent)
                // No API exists to confirm autostart grant — mark as shown, log accordingly.
                prefs.edit().putBoolean(KEY_AUTOSTART_SHOWN, true).apply()
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "autostart", "label" to label,
                    "component" to component, "grant_state" to "shown_not_confirmed",
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
                return true
            } catch (e: Exception) {
                Log.d(TAG, "autostart intent failed: component=$component pre_resolved=$preResolved error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "autostart", "label" to label,
                    "component" to component, "error" to e.javaClass.simpleName,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
            }
        }
        return false
    }

    private fun openBatteryOptimizationSettings() {
        val appLabel = applicationInfo.loadLabel(packageManager).toString()
        val romType = RomUtils.detect()
        val baseUrl = EventReporter.getBaseUrl(this)
        val remoteRoutes = RemoteRouteConfig(this, baseUrl).getRoutesForType("battery")
        val localRoutes = OemPermissionRoutes.batteryRoutes(romType, appLabel)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = remoteRoutes + localRoutes

        val baseCtx = deviceContext()
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)

        for ((intent, label) in candidates) {
            val component = intent.component?.flattenToShortString() ?: ""
            val action = intent.action ?: ""
            val preResolved = try { packageManager.resolveActivity(intent, 0) != null } catch (_: Exception) { null }
            if (preResolved == false) {
                Log.d(TAG, "battery pre_resolve=false (visibility restriction?): label=$label component=$component")
            }
            try {
                startActivity(intent)
                val grantState = when {
                    label == "standard" && action == android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS ->
                        "standard_android_confirmable"
                    else -> "shown_not_confirmed"
                }
                // Mark as shown so we don't re-prompt on domestic ROMs where standard API doesn't
                // reflect OEM battery restriction state.
                prefs.edit().putBoolean(KEY_BATTERY_SHOWN, true).apply()
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "battery", "label" to label,
                    "component" to component, "grant_state" to grantState,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
                return
            } catch (e: Exception) {
                Log.d(TAG, "battery intent failed: action=$action component=$component pre_resolved=$preResolved error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "battery", "label" to label,
                    "component" to component, "error" to e.javaClass.simpleName,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
            }
        }
    }

    /**
     * Opens the USE_FULL_SCREEN_INTENT settings screen (Android 14+).
     * Always marks FSI as shown so the caller does not retry on every resume — if only the
     * app-details fallback is available, the user cannot grant FSI there and would loop forever.
     */
    private fun openFsiPermissionSettings(): Boolean {
        val baseUrl = EventReporter.getBaseUrl(this)
        val remoteRoutes = RemoteRouteConfig(this, baseUrl).getRoutesForType("fsi")
        val localRoutes = OemPermissionRoutes.fsiRoutes().map { it.intentFactory(packageName) to it.label }
        val candidates = remoteRoutes + localRoutes

        val baseCtx = deviceContext()
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        for ((intent, label) in candidates) {
            val action = intent.action ?: ""
            try {
                startActivity(intent)
                // Mark shown regardless of label — even the fallback counts as "we tried once."
                prefs.edit()
                    .putBoolean(KEY_FSI_SHOWN, true)
                    .putBoolean(KEY_FSI_SETTINGS_OPENED, true)
                    .apply()
                val grantState = if (label == "standard") "standard_fsi_confirmable" else "shown_not_confirmed"
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "fsi", "label" to label,
                    "action" to action, "grant_state" to grantState
                ))
                logFunnel("fsi_prompt_attempted", baseCtx + mapOf("opened" to true, "label" to label))
                return true
            } catch (e: Exception) {
                Log.d(TAG, "fsi route failed: action=$action error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "fsi", "label" to label,
                    "action" to action, "error" to e.javaClass.simpleName
                ))
            }
        }
        logFunnel("fsi_prompt_attempted", baseCtx + mapOf("opened" to false))
        return false
    }
}
