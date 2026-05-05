package com.ymsport2026.tiyu

import android.app.ActivityManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.ymsport2026.tiyu.kickrise.EventReporter
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
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
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
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putBoolean(PopupAlarmReceiver.KEY_APP_IN_RECENTS, true).apply()
    }

    override fun onStop() {
        super.onStop()
        setAppAlive(false)
    }

    private fun setAppAlive(alive: Boolean) {
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putBoolean(PopupAlarmReceiver.KEY_APP_ALIVE, alive).apply()
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

        if (isDomestic && !Settings.canDrawOverlays(this)) {
            val opened = openOemOverlaySettings()
            // "not_supported" = Android Go (no overlay feature); "failed" = no intent resolved.
            // In both cases fall through so downstream permissions can still be requested.
            if (opened != "not_supported" && opened != "failed") return true
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
            val pm = getSystemService(POWER_SERVICE) as PowerManager
            if (!pm.isIgnoringBatteryOptimizations(packageName)) {
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
        if (!started) {
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
    }

    // Opens the most direct overlay permission settings screen available for this ROM.
    // Returns a label indicating which path succeeded, for analytics ("oem" | "standard" | "fallback" | "failed" | "not_supported").
    private fun openOemOverlaySettings(): String {
        // Android Go edition (low RAM) does not have the "Display over other apps" feature.
        val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
        if (am.isLowRamDevice) return "not_supported"

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
                // Standalone Honor devices (MagicUI 7+) use com.hihonor.systemmanager
                candidates += Intent().apply {
                    component = ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.addviewmonitor.AddViewMonitorActivity")
                } to "oem"
                // Older Honor / Huawei EMUI path
                candidates += Intent().apply {
                    component = ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.addviewmonitor.AddViewMonitorActivity")
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

        if (romType != RomUtils.RomType.XIAOMI) {
            candidates += Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")) to "standard"
        }
        candidates += Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")) to "fallback"

        for ((intent, label) in candidates) {
            try {
                startActivity(intent)
                return label
            } catch (_: Exception) {
                // Intent not resolvable on this device — try the next candidate.
            }
        }
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
