package com.ymsport2026.tiyu

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ymsport2026.tiyu.kickrise.EventReporter
import com.ymsport2026.tiyu.kickrise.LogLevel
import com.ymsport2026.tiyu.kickrise.PopupAlarmReceiver
import com.ymsport2026.tiyu.kickrise.PopupForegroundService
import com.ymsport2026.tiyu.kickrise.RomUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "kickrise/popup"

    companion object {
        private const val REQUEST_CODE_NOTIFICATIONS = 1001
        private const val KEY_AUTOSTART_SHOWN = "kickrise_autostart_shown"
        private const val KEY_BATTERY_SHOWN = "kickrise_battery_shown"
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
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        prefs.edit().putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, true).apply()

        if (prefs.getBoolean(KEY_OVERLAY_SETTINGS_OPENED, false)) {
            prefs.edit().putBoolean(KEY_OVERLAY_SETTINGS_OPENED, false).apply()
            val granted = OverlayPermissionCompat.canDrawOverlays(this)
            val lastRoute = prefs.getString(KEY_LAST_OVERLAY_ROUTE, "unknown") ?: "unknown"
            val lastAction = prefs.getString(KEY_LAST_OVERLAY_ACTION, "") ?: ""
            val lastComponent = prefs.getString(KEY_LAST_OVERLAY_COMPONENT, "") ?: ""
            logOverlay("overlay_resume_check", deviceContext() + mapOf(
                "last_overlay_route" to lastRoute,
                "last_overlay_action" to lastAction,
                "last_overlay_component" to lastComponent,
                "overlay_granted_after_resume" to granted
            ))
        }
    }

    override fun onStop() {
        super.onStop()
        setAppAlive(false)
    }

    private fun setAppAlive(alive: Boolean) {
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, alive).apply()
    }

    private fun deviceContext(): Map<String, Any> {
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        return mapOf(
            "rom" to RomUtils.romLabel(),
            "brand" to Build.BRAND,
            "model" to Build.MODEL,
            "sdk" to Build.VERSION.SDK_INT,
            "is_low_ram" to am.isLowRamDevice
        )
    }

    private fun logOverlay(message: String, ctx: Map<String, Any>) {
        Log.i("KickRise/overlay", "$message $ctx")
        val baseUrl = EventReporter.getBaseUrl(this)
        if (baseUrl.isNotBlank()) {
            EventReporter(this, baseUrl).reportLog(LogLevel.INFO, message, "overlay", ctx)
        }
    }

    private fun startPopupService(baseUrl: String) {
        EventReporter.saveBaseUrl(this, baseUrl)

        val serviceIntent = Intent(this, PopupForegroundService::class.java).apply {
            putExtra(PopupForegroundService.EXTRA_BASE_URL, baseUrl)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    // Checks each permission in priority order and opens the first missing one.
    // Returns true if a prompt was shown (caller should stop and retry on next resume).
    private fun checkAndRequestNextPermission(): Boolean {
        val isDomestic = RomUtils.isDomesticRom()

        if (isDomestic && OverlayPermissionCompat.needsUserGrant(this)) {
            val opened = openOemOverlaySettings()
            if (opened != "failed") return true
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
                return true
            }
        }

        if (isDomestic) {
            val isXiaomi = RomUtils.detect() == RomUtils.RomType.XIAOMI
            // MIUI's "No Restriction" does not update isIgnoringBatteryOptimizations(); use a shown-flag instead.
            val batteryDone = if (isXiaomi)
                getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).getBoolean(KEY_BATTERY_SHOWN, false)
            else
                (getSystemService(POWER_SERVICE) as PowerManager).isIgnoringBatteryOptimizations(packageName)
            if (!batteryDone) {
                openBatteryOptimizationSettings()
                return true
            }
        }

        if (isDomestic && openAutostartSettings()) {
            return true
        }

        return false
    }

    private fun openBatteryOptimizationSettings() {
        val label = applicationInfo.loadLabel(packageManager).toString()
        // HiddenAppsConfigActivity targets newer MIUI; HiddenAppsContainerManagementActivity is the older path.
        val miuiCandidates = listOf(
            Intent().apply {
                component = ComponentName("com.miui.powerkeeper",
                    "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")
                putExtra("package_name", packageName)
                putExtra("package_label", label)
            },
            Intent().apply {
                component = ComponentName("com.miui.powerkeeper",
                    "com.miui.powerkeeper.ui.HiddenAppsContainerManagementActivity")
                putExtra("package_name", packageName)
                putExtra("package_label", label)
            }
        )
        val started = miuiCandidates.any { intent ->
            try { startActivity(intent); true } catch (_: Exception) { false }
        }
        if (started) {
            getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
                .edit().putBoolean(KEY_BATTERY_SHOWN, true).apply()
            return
        }
        try {
            startActivity(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$packageName")
            })
        } catch (_: Exception) {
            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            })
        }
    }

    // Opens the most direct overlay permission settings screen available for this ROM.
    // Returns a label indicating which path succeeded, for analytics ("oem" | "standard" | "fallback" | "failed").
    private fun openOemOverlaySettings(): String {
        // Each candidate is paired with the label returned if it succeeds.
        // OEM-specific screens are tried first; they surface the exact toggle without extra navigation.
        val candidates = mutableListOf<Pair<Intent, String>>()

        val romType = RomUtils.detect()

        when (romType) {
            RomUtils.RomType.XIAOMI -> {
                candidates += Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")) to "standard"
                // Two class names in circulation across MIUI versions
                candidates += Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                    setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity")
                    putExtra("extra_pkgname", packageName)
                } to "oem"
                candidates += Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                    setClassName("com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
                    putExtra("extra_pkgname", packageName)
                } to "oem"
            }
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // sysfloatwindow is the older ColorOS path; permission.floatwindow is the newer one
                candidates += Intent().apply {
                    component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.sysfloatwindow.FloatWindowListActivity")
                } to "oem"
                candidates += Intent().apply {
                    component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.floatwindow.FloatWindowListActivity")
                } to "oem"
                candidates += Intent().apply {
                    component = ComponentName("com.oppo.safe", "com.oppo.safe.permission.floatwindow.FloatWindowListActivity")
                } to "oem"
            }
            RomUtils.RomType.VIVO -> {
                candidates += Intent().apply {
                    component = ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity")
                } to "oem"
            }
            RomUtils.RomType.IQOO -> {
                candidates += Intent().apply {
                    component = ComponentName("com.iqoo.secure", "com.iqoo.secure.safeguard.SoftPermissionDetailActivity")
                } to "oem"
            }
            RomUtils.RomType.HUAWEI, RomUtils.RomType.HONOR -> {
                candidates += Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")) to "standard"
                // Standalone Honor devices (MagicUI 7+) use com.hihonor.systemmanager
                candidates += Intent().apply {
                    component = ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.addviewmonitor.AddViewMonitorActivity")
                } to "oem"
                // Older Honor / Huawei EMUI path
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.addviewmonitor.AddViewMonitorActivity")
                } to "oem"
                // Huawei permission manager (some EMUI versions surface overlay toggle here)
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.permissionmanager", "com.huawei.permissionmanager.ui.MainActivity")
                } to "oem"
            }
            RomUtils.RomType.MEIZU -> {
                candidates += Intent("com.meizu.safe.security.SHOW_APPSEC").apply {
                    putExtra("packageName", packageName)
                    component = ComponentName("com.meizu.safe", "com.meizu.safe.security.AppSecActivity")
                } to "oem"
            }
            else -> Unit
        }

        if (romType != RomUtils.RomType.XIAOMI &&
            romType != RomUtils.RomType.HUAWEI &&
            romType != RomUtils.RomType.HONOR) {
            candidates += Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")) to "standard"
        }
        candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")) to "fallback"

        val baseCtx = deviceContext()

        for ((intent, label) in candidates) {
            val action = intent.action ?: ""
            val component = intent.component?.flattenToShortString() ?: ""
            try {
                startActivity(intent)
                logOverlay("overlay_settings_opened", baseCtx + mapOf(
                    "intent_label" to label,
                    "intent_action" to action,
                    "intent_component" to component,
                    "start_success" to true
                ))
                getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE).edit()
                    .putString(KEY_LAST_OVERLAY_ROUTE, label)
                    .putString(KEY_LAST_OVERLAY_ACTION, action)
                    .putString(KEY_LAST_OVERLAY_COMPONENT, component)
                    .putBoolean(KEY_OVERLAY_SETTINGS_OPENED, true)
                    .apply()
                return label
            } catch (_: Exception) {
                Log.d("KickRise/overlay", "overlay_intent_failed label=$label action=$action component=$component brand=${Build.BRAND} model=${Build.MODEL}")
            }
        }
        logOverlay("overlay_settings_failed", baseCtx + mapOf("start_success" to false))
        return "failed"
    }

    // Opens the most direct autostart/background-launch settings screen for this ROM.
    // Returns true if any screen was opened successfully. Shows at most once per install.
    private fun openAutostartSettings(): Boolean {
        val prefs = getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
        if (prefs.getBoolean(KEY_AUTOSTART_SHOWN, false)) return false

        val candidates = mutableListOf<Intent>()

        when (RomUtils.detect()) {
            RomUtils.RomType.XIAOMI -> {
                candidates += Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                    setClassName("com.miui.securitycenter",
                        "com.miui.permcenter.autostart.AutoStartManagementActivity")
                    putExtra("extra_pkgname", packageName)
                }
            }
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME -> {
                candidates += Intent().apply {
                    component = ComponentName("com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.coloros.safecenter",
                        "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.oppo.safe",
                        "com.oppo.safe.permission.startup.StartupAppListActivity")
                }
            }
            RomUtils.RomType.ONEPLUS -> {
                candidates += Intent().apply {
                    component = ComponentName("com.oneplus.security",
                        "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.coloros.safecenter",
                        "com.coloros.safecenter.startupapp.StartupAppListActivity")
                }
            }
            RomUtils.RomType.VIVO -> {
                candidates += Intent().apply {
                    component = ComponentName("com.vivo.permissionmanager",
                        "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")
                }
            }
            RomUtils.RomType.IQOO -> {
                candidates += Intent().apply {
                    component = ComponentName("com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.iqoo.secure",
                        "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")
                }
            }
            RomUtils.RomType.HONOR -> {
                // Standalone Honor (MagicUI 7+) ships com.hihonor.systemmanager
                candidates += Intent().apply {
                    component = ComponentName("com.hihonor.systemmanager",
                        "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.hihonor.systemmanager",
                        "com.hihonor.systemmanager.optimize.process.ProtectActivity")
                }
                // Older Honor / EMUI fallback
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager",
                        "com.huawei.systemmanager.optimize.process.ProtectActivity")
                }
            }
            RomUtils.RomType.HUAWEI -> {
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                }
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager",
                        "com.huawei.systemmanager.optimize.process.ProtectActivity")
                }
            }
            else -> Unit
        }

        val opened = candidates.any { intent ->
            try { startActivity(intent); true } catch (_: Exception) { false }
        }
        if (opened) prefs.edit().putBoolean(KEY_AUTOSTART_SHOWN, true).apply()
        return opened
    }
}
