package com.ymsport2026.tiyu

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import com.ymsport2026.tiyu.kickrise.EventReporter
import com.ymsport2026.tiyu.kickrise.PopupAlarmReceiver
import com.ymsport2026.tiyu.kickrise.PopupForegroundService
import com.ymsport2026.tiyu.kickrise.RomUtils
import com.ymsport2026.tiyu.kickrise.ScreenEventReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "kickrise/popup"

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
                    val intent = Intent(
                        Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName")
                    )
                    startActivity(intent)
                    result.success(null)
                }
                "isXiaomiDevice" -> {
                    result.success(RomUtils.detect() == RomUtils.RomType.XIAOMI)
                }
                "checkBatteryOptimization" -> {
                    val pm = getSystemService(POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestBatteryOptimization" -> {
                    // Try MIUI-specific "No restrictions" page first, fall back to standard Android dialog
                    val label = applicationInfo.loadLabel(packageManager).toString()
                    val miuiIntent = Intent().apply {
                        component = ComponentName(
                            "com.miui.powerkeeper",
                            "com.miui.powerkeeper.ui.HiddenAppsContainerManagementActivity"
                        )
                        putExtra("package_name", packageName)
                        putExtra("package_label", label)
                    }
                    try {
                        startActivity(miuiIntent)
                    } catch (e: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                            })
                        } catch (e2: Exception) {
                            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                            })
                        }
                    }
                    result.success(null)
                }
                "requestMiuiAutostart" -> {
                    val intent = Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                        setClassName(
                            "com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity"
                        )
                        putExtra("extra_pkgname", packageName)
                    }
                    try {
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
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
        // Persist baseUrl so BootReceiver and ScreenEventReceiver can read it
        getSharedPreferences(EventReporter.PREFS_NAME, MODE_PRIVATE)
            .edit().putString(ScreenEventReceiver.KEY_BASE_URL, baseUrl).apply()

        val serviceIntent = Intent(this, PopupForegroundService::class.java).apply {
            putExtra(PopupForegroundService.EXTRA_BASE_URL, baseUrl)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }
}
