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
        private const val KEY_BATTERY_SETTINGS_OPENED = "kickrise_battery_settings_opened"
        private const val KEY_LAST_OVERLAY_ROUTE = "kickrise_last_overlay_route"
        private const val KEY_LAST_OVERLAY_ACTION = "kickrise_last_overlay_action"
        private const val KEY_LAST_OVERLAY_COMPONENT = "kickrise_last_overlay_component"
        private const val KEY_OVERLAY_SETTINGS_OPENED = "kickrise_overlay_settings_opened"
        private const val KEY_AUTOSTART_SETTINGS_OPENED = "kickrise_autostart_settings_opened"
        private const val KEY_BACKGROUND_POPUP_SHOWN = "kickrise_background_popup_shown"
        private const val KEY_BACKGROUND_POPUP_SETTINGS_OPENED = "kickrise_background_popup_settings_opened"
        // Set before requestPermissions() so onStop() doesn't schedule the fallback alarm while
        // the system notification-permission dialog is showing. Cleared in onRequestPermissionsResult.
        private const val KEY_NOTIFICATION_PERMISSION_IN_FLIGHT = "kickrise_notification_perm_in_flight"
        // vivo/iQOO SDK<33: FuntouchOS blocks notifications by default without a runtime permission API.
        // SHOWN: one-shot guard so returning without enabling doesn't re-open the page (same as autostart).
        // OPENED: in-flight guard for the permission_chain_deferred check.
        private const val KEY_NOTIFICATION_SETTINGS_SHOWN = "kickrise_notification_settings_shown"
        private const val KEY_NOTIFICATION_SETTINGS_OPENED = "kickrise_notification_settings_opened"
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
                    result.success(RomUtils.isAggressiveOemRom())
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
                    // 允许手动重试：先清除“已显示”标记，再打开设置页
                    getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                        .putBoolean(KEY_AUTOSTART_SHOWN, false).apply()
                    result.success(openAutostartSettings())
                }
                "requestNotificationPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                            .putBoolean(KEY_NOTIFICATION_PERMISSION_IN_FLIGHT, true).commit()
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
        prefs.edit()
            .putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, true)
            .putBoolean(KEY_NOTIFICATION_PERMISSION_IN_FLIGHT, false)
            .apply()
        logFunnel("app_lifecycle_state", deviceContext() + mapOf(
            "event" to "resumed",
            "app_alive" to true,
            "in_recents" to true
        ))

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
            // Advance to notification permission now that overlay is granted.
            // Flutter's didChangeAppLifecycleState is unreliable for OEM settings activities
            // that don't always trigger paused→resumed; own the continuation here instead.
            if (granted) {
                logFunnel("permission_chain_resume_continue", deviceContext() + mapOf("from" to "overlay"))
                checkAndRequestNextPermission()
            }
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

        if (prefs.getBoolean(KEY_BATTERY_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_BATTERY_SETTINGS_OPENED, false).apply()
            val batteryOptIgnored = (getSystemService(POWER_SERVICE) as PowerManager).isIgnoringBatteryOptimizations(packageName)
            logFunnel("battery_settings_returned", deviceContext() + mapOf("battery_opt_ignored" to batteryOptIgnored))
            checkAndRequestNextPermission()
        }

        if (prefs.getBoolean(KEY_AUTOSTART_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_AUTOSTART_SETTINGS_OPENED, false).apply()
            logFunnel("autostart_settings_returned", deviceContext())
            checkAndRequestNextPermission()
        }

        if (prefs.getBoolean(KEY_BACKGROUND_POPUP_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_BACKGROUND_POPUP_SETTINGS_OPENED, false).apply()
            logFunnel("background_popup_settings_returned", deviceContext())
            checkAndRequestNextPermission()
        }

        if (prefs.getBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, false).apply()
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            logFunnel("vivo_notification_settings_returned", deviceContext() + mapOf(
                "notifications_enabled" to nm.areNotificationsEnabled()
            ))
            checkAndRequestNextPermission()
        }
    }

    override fun onStop() {
        super.onStop()
        setAppAlive(false)
        logFunnel("app_lifecycle_state", deviceContext() + mapOf(
            "event" to "stopped",
            "app_alive" to false,
            "in_recents" to true
        ))
//        val permissionStopReason = activePermissionFlowReason()
//        if (permissionStopReason != null) {
//            logFunnel("fallback_alarm_not_scheduled_from_activity", deviceContext() + mapOf(
//                "reason" to permissionStopReason
//            ))
//        } else {
//            scheduleFallbackAlarm()
//        }
        // 不检查任何权限页标记，直接调度备用闹钟。
        // 即使权限页正在显示，闹钟也会在锁屏后触发，保证广告必出。
        scheduleFallbackAlarm()
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CODE_NOTIFICATIONS) {
            getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                .putBoolean(KEY_NOTIFICATION_PERMISSION_IN_FLIGHT, false).apply()
            if (grantResults.isEmpty()) {
                logFunnel("notification_permission_result", deviceContext() + mapOf(
                    "granted" to false, "empty_result" to true, "request_code" to requestCode
                ))
            } else {
                val granted = grantResults[0] == android.content.pm.PackageManager.PERMISSION_GRANTED
                logFunnel("notification_permission_result", deviceContext() + mapOf(
                    "granted" to granted, "empty_result" to false, "request_code" to requestCode
                ))
                if (granted) checkAndRequestNextPermission()
            }
        }
    }

    private fun setAppAlive(alive: Boolean) {
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, alive).apply()
    }

    private fun activePermissionFlowReason(): String? {
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        return when {
            prefs.getBoolean(KEY_OVERLAY_SETTINGS_OPENED, false) -> "overlay_settings_opened"
            prefs.getBoolean(KEY_FSI_SETTINGS_OPENED, false) -> "fsi_settings_opened"
            prefs.getBoolean(KEY_BATTERY_SETTINGS_OPENED, false) -> "battery_settings_opened"
            prefs.getBoolean(KEY_AUTOSTART_SETTINGS_OPENED, false) -> "autostart_settings_opened"
            prefs.getBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, false) -> "notification_settings_opened"
            prefs.getBoolean(KEY_NOTIFICATION_PERMISSION_IN_FLIGHT, false) -> "notification_permission_in_flight"
            else -> null
        }
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
        logFunnel("fallback_alarm_cancelled_from_activity", deviceContext() + mapOf(
            "reason" to "activity_resumed"
        ))
    }

    private fun deviceContext(): Map<String, Any> {
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        val romInfo = RomUtils.romInfo()
        val chinaRomInfo = RomUtils.chinaRomInfo()
        return buildMap {
            put("rom", romInfo.romType.name)
            put("os_label", romInfo.osLabel)
            put("os_version", romInfo.osVersion)
            put("detection_source", romInfo.detectionSource)
            put("china_rom", chinaRomInfo.isChina)
            put("china_rom_source", chinaRomInfo.source)
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
     * Order: overlay → notification → OEM background-popup → China ROM battery →
     * Xiaomi autostart → Android 14+ full-screen intent.
     *
     * Overlay uses isAggressiveOemRom() — OEM brand behavior applies regardless of region.
     * Battery remains China-region only. Background-popup and FSI use OEM family because field
     * logs show OPPO/Honor/Huawei devices can require those toggles even when region props are
     * absent or reported as global.
     */
    private fun checkAndRequestNextPermission(): Boolean {
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        if (prefs.getBoolean(KEY_OVERLAY_SETTINGS_OPENED, false) ||
            prefs.getBoolean(KEY_FSI_SETTINGS_OPENED, false) ||
            prefs.getBoolean(KEY_BATTERY_SETTINGS_OPENED, false) ||
            prefs.getBoolean(KEY_AUTOSTART_SETTINGS_OPENED, false) ||
            prefs.getBoolean(KEY_BACKGROUND_POPUP_SETTINGS_OPENED, false) ||
            prefs.getBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, false)) {
            logFunnel("permission_chain_deferred", deviceContext() + mapOf(
                "overlay_opened" to prefs.getBoolean(KEY_OVERLAY_SETTINGS_OPENED, false),
                "fsi_opened" to prefs.getBoolean(KEY_FSI_SETTINGS_OPENED, false),
                "battery_opened" to prefs.getBoolean(KEY_BATTERY_SETTINGS_OPENED, false),
                "autostart_opened" to prefs.getBoolean(KEY_AUTOSTART_SETTINGS_OPENED, false),
                "bg_popup_opened" to prefs.getBoolean(KEY_BACKGROUND_POPUP_SETTINGS_OPENED, false),
                "notification_settings_opened" to prefs.getBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, false)
            ))
            return false
        }

        val isAggressiveOem = RomUtils.isAggressiveOemRom()
        val chinaRom = RomUtils.chinaRomInfo()
        val baseCtx = deviceContext()

        // 1. 悬浮窗（OEM 机型必需，不区分国行/海外）
        if (isAggressiveOem && OverlayPermissionCompat.needsUserGrant(this)) {
            val opened = openOemOverlaySettings()
            if (opened != "failed") {
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "overlay", "route" to opened))
                return true
            }
        }

        // 2. 通知权限（Android 13+）
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val granted = ContextCompat.checkSelfPermission(
                this, android.Manifest.permission.POST_NOTIFICATIONS
            ) == android.content.pm.PackageManager.PERMISSION_GRANTED
            if (!granted) {
                getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                    .putBoolean(KEY_NOTIFICATION_PERMISSION_IN_FLIGHT, true).commit()
                ActivityCompat.requestPermissions(
                    this, arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                    REQUEST_CODE_NOTIFICATIONS
                )
                logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "notification"))
                return true
            }
        }

        val romInfo = RomUtils.romInfo()

        // 2b. vivo/iQOO SDK<33: FuntouchOS blocks notifications by default at the OEM level even
        // though no Android runtime permission is required. The fullscreen-notification delivery
        // route silently drops if notifications are disabled (confirmed: notification_enabled=false
        // in logs for V1813A). Show once (KEY_NOTIFICATION_SETTINGS_SHOWN) so returning without
        // enabling does not re-open the page on every subsequent resume — same pattern as autostart.
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU &&
            romInfo.romType in setOf(RomUtils.RomType.VIVO, RomUtils.RomType.IQOO)) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            if (!nm.areNotificationsEnabled() && !prefs.getBoolean(KEY_NOTIFICATION_SETTINGS_SHOWN, false)) {
                try {
                    startActivity(
                        android.content.Intent(android.provider.Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                            .putExtra(android.provider.Settings.EXTRA_APP_PACKAGE, packageName)
                    )
                    prefs.edit()
                        .putBoolean(KEY_NOTIFICATION_SETTINGS_SHOWN, true)
                        .putBoolean(KEY_NOTIFICATION_SETTINGS_OPENED, true)
                        .apply()
                    logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "notification_vivo_sdk_lt33"))
                    return true
                } catch (_: Exception) {}
            }
        }
        val requiresLockscreenPopupGuide = RomUtils.requiresLockscreenPopupGuide()
        if (requiresLockscreenPopupGuide && chinaRom.isChina && !prefs.getBoolean(KEY_BACKGROUND_POPUP_SHOWN, false)) {
            val opened = openBackgroundPopupSettings()
            if (opened) {
                logFunnel("permission_prompt_opened", baseCtx + mapOf(
                    "type" to "background_popup",
                    "china_rom" to chinaRom.isChina,
                    "china_rom_source" to chinaRom.source,
                    "grant_state" to "shown_not_confirmed"
                ))
                return true
            }
        }

        // 3. China ROM only: battery optimisation. This remains region-specific because the
        // standard battery exemption prompt is noisy and not required by the OPPO/Honor failures
        // unless future device logs prove otherwise.
        if (chinaRom.isChina) {
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            val batteryAlreadyShown = prefs.getBoolean(KEY_BATTERY_SHOWN, false)
            // MIUI + SDK ≤ 31: battery settings step causes popup delivery regression.
            // Log data shows Mi 10 at SDK 29/30/31 (CNXM) all regress with battery; autostart alone
            // is sufficient. Mi 13+ (HyperOS, SDK 33+) are unaffected and still need the battery step.
            val skipBattery = romInfo.romType == RomUtils.RomType.XIAOMI
                && romInfo.osLabel == "MIUI"
                && Build.VERSION.SDK_INT <= Build.VERSION_CODES.S
            if (!skipBattery && !pm.isIgnoringBatteryOptimizations(packageName) && !batteryAlreadyShown) {
                val opened = openBatteryOptimizationSettings()
                if (opened) {
                    logFunnel("permission_prompt_opened", baseCtx + mapOf(
                        "type" to "battery",
                        "china_rom" to true,
                        "china_rom_source" to chinaRom.source
                    ))
                    return true
                }
            }
        }

        // 3b. Autostart — MIUI enforces this on both China and Global builds.
        if (romInfo.romType == RomUtils.RomType.XIAOMI
            && !prefs.getBoolean(KEY_AUTOSTART_SHOWN, false)) {
            val opened = openAutostartSettings()
            if (opened) {
                logFunnel("permission_prompt_opened", baseCtx + mapOf(
                    "type" to "autostart",
                    "china_rom" to chinaRom.isChina,
                    "china_rom_source" to chinaRom.source
                ))
                return true
            }
        }

        // 4. 全屏通知权限（Samsung Android 14+ 及需要锁屏弹窗引导的 OEM 均尝试一次）
        if (Build.VERSION.SDK_INT >= 34 &&
            (RomUtils.detect() == RomUtils.RomType.SAMSUNG || requiresLockscreenPopupGuide || RomUtils.isChinaRom())) {
            val nm = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            if (!nm.canUseFullScreenIntent() && !prefs.getBoolean(KEY_FSI_SHOWN, false)) {
                val opened = openFsiPermissionSettings()
                if (opened) {
                    logFunnel("permission_prompt_opened", baseCtx + mapOf("type" to "fsi"))
                    return true
                }
            }
        }

        logFunnel("permission_chain_complete", baseCtx)
        return false
    }

    private fun shouldPromptFullScreenIntentAutomatically(): Boolean =
        Build.VERSION.SDK_INT >= 34 &&
            (RomUtils.detect() == RomUtils.RomType.SAMSUNG ||
                RomUtils.requiresLockscreenPopupGuide() ||
                RomUtils.isChinaRom())

    // ─── Settings route helpers ────────────────────────────────────────────────────

    /**
     * Opens the most direct overlay permission screen for this ROM.
     * Server-provided routes are tried first; local registry is the fallback.
     * Returns a label: "oem" | "standard" | "fallback" | "remote_oem" | "failed".
     */
    private fun openOemOverlaySettings(): String {
        val romType = RomUtils.detect()
        val localRoutes = OemPermissionRoutes.overlayRoutes(romType)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = localRoutes

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
        val localRoutes = OemPermissionRoutes.autostartRoutes(romType)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = localRoutes

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
                prefs.edit().putBoolean(KEY_AUTOSTART_SHOWN, true).putBoolean(KEY_AUTOSTART_SETTINGS_OPENED, true).apply()
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

    private fun openBatteryOptimizationSettings(): Boolean {
        val appLabel = applicationInfo.loadLabel(packageManager).toString()
        val romType = RomUtils.detect()
        val localRoutes = OemPermissionRoutes.batteryRoutes(romType, appLabel)
            .map { it.intentFactory(packageName) to it.label }
        val candidates = localRoutes

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
                // reflect OEM battery restriction state. Mark in-flight so onResume drives autostart.
                prefs.edit()
                    .putBoolean(KEY_BATTERY_SHOWN, true)
                    .putBoolean(KEY_BATTERY_SETTINGS_OPENED, true)
                    .apply()
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "battery", "label" to label,
                    "component" to component, "grant_state" to grantState,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
                return true
            } catch (e: Exception) {
                Log.d(TAG, "battery intent failed: action=$action component=$component pre_resolved=$preResolved error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "battery", "label" to label,
                    "component" to component, "error" to e.javaClass.simpleName,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val intent = Intent(android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                intent.data = android.net.Uri.parse("package:$packageName")
                startActivity(intent)
                prefs.edit()
                    .putBoolean(KEY_BATTERY_SHOWN, true)
                    .putBoolean(KEY_BATTERY_SETTINGS_OPENED, true)
                    .apply()
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "battery",
                    "label" to "standard_fallback",
                    "grant_state" to "standard_android_confirmable"
                ))
                return true
            } catch (_: Exception) {}
        }

        return false
    }

    private fun openBackgroundPopupSettings(): Boolean {
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        if (prefs.getBoolean(KEY_BACKGROUND_POPUP_SHOWN, false)) return false

        val romType = RomUtils.detect()
        val localRoutes = OemPermissionRoutes.backgroundPopupRoutes(romType, applicationInfo.uid)
        val baseCtx = deviceContext()

        for ((label, intentFactory) in localRoutes) {
            val intent = intentFactory(packageName)
            val component = intent.component?.flattenToShortString() ?: ""
            val action = intent.action ?: ""
            val preResolved = try { packageManager.resolveActivity(intent, 0) != null } catch (_: Exception) { null }
            if (preResolved == false) {
                Log.d(TAG, "background popup pre_resolve=false (visibility restriction?): label=$label component=$component")
            }
            try {
                startActivity(intent)
                prefs.edit()
                    .putBoolean(KEY_BACKGROUND_POPUP_SHOWN, true)
                    .putBoolean(KEY_BACKGROUND_POPUP_SETTINGS_OPENED, true)
                    .apply()
                logFunnel("settings_route_launched", baseCtx + mapOf(
                    "route_type" to "background_popup",
                    "label" to label,
                    "component" to component,
                    "action" to action,
                    "grant_state" to "shown_not_confirmed",
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
                return true
            } catch (e: Exception) {
                Log.d(TAG, "background popup route failed: label=$label action=$action component=$component pre_resolved=$preResolved error=${e.javaClass.simpleName}")
                logFunnel("settings_route_launch_failed", baseCtx + mapOf(
                    "route_type" to "background_popup",
                    "label" to label,
                    "component" to component,
                    "action" to action,
                    "error" to e.javaClass.simpleName,
                    "pre_resolved" to (preResolved ?: "unknown")
                ))
            }
        }
        return false
    }

    /**
     * Opens the USE_FULL_SCREEN_INTENT settings screen (Android 14+).
     * Always marks FSI as shown so the caller does not retry on every resume — if only the
     * app-details fallback is available, the user cannot grant FSI there and would loop forever.
     */
    private fun openFsiPermissionSettings(): Boolean {
        val candidates = OemPermissionRoutes.fsiRoutes().map { it.intentFactory(packageName) to it.label }

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
