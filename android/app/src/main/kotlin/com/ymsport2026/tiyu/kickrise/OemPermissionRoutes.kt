package com.ymsport2026.tiyu.kickrise

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.provider.Settings

/**
 * Registry of OEM-specific and standard permission-settings routes, separated by route type.
 *
 * Routes are ordered: OEM-specific screens first (most direct), standard Android fallback last.
 * Callers should iterate and use the first route that resolves / starts successfully.
 *
 * Keeping component names here (rather than inline in MainActivity) makes it easy to add,
 * remove, or reorder routes without touching permission-flow logic.
 */
object OemPermissionRoutes {

    enum class RouteType { OVERLAY, AUTOSTART, BATTERY, NOTIFICATION_FSI }

    data class OemRoute(
        val label: String,                       // "oem" | "standard" | "fallback"
        val intentFactory: (pkg: String) -> Intent
    )

    // ─── Overlay (draw over other apps) ──────────────────────────────────────────

    fun overlayRoutes(romType: RomUtils.RomType): List<OemRoute> = buildList {
        when (romType) {
            RomUtils.RomType.XIAOMI -> {
                // MIUI/HyperOS: two class names in circulation across versions
                add(OemRoute("oem") { pkg ->
                    Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                        setClassName("com.miui.securitycenter",
                            "com.miui.permcenter.permissions.PermissionsEditorActivity")
                        putExtra("extra_pkgname", pkg)
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                        setClassName("com.miui.securitycenter",
                            "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
                        putExtra("extra_pkgname", pkg)
                    }
                })
                // Standard ACTION_MANAGE_OVERLAY_PERMISSION works on MIUI too
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
            }
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // ColorOS/OxygenOS: standard route works reliably across versions.
                // The legacy com.coloros.safecenter and com.oppo.safe FloatWindowListActivity
                // components no longer exist on ColorOS 11+ and throw ActivityNotFoundException.
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
            }
            RomUtils.RomType.VIVO, RomUtils.RomType.IQOO -> {
                // OriginOS 4+ added a per-permission tab; older OriginOS uses SoftPermissionDetailActivity
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.PurviewTabActivity")
                        putExtra("packagename", pkg)
                        putExtra("tabId", "float_window")
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.SoftPermissionDetailActivity")
                        putExtra("packagename", pkg)
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.iqoo.secure",
                            "com.iqoo.secure.safeguard.SoftPermissionDetailActivity")
                    }
                })
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
            }
            RomUtils.RomType.HONOR -> {
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
                // MagicUI 7+ uses com.hihonor.systemmanager
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.addviewmonitor.AddViewMonitorActivity")
                    }
                })
                // Older Honor / EMUI path
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.addviewmonitor.AddViewMonitorActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.permissionmanager",
                            "com.huawei.permissionmanager.ui.MainActivity")
                    }
                })
            }
            RomUtils.RomType.HUAWEI -> {
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.addviewmonitor.AddViewMonitorActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.permissionmanager",
                            "com.huawei.permissionmanager.ui.MainActivity")
                    }
                })
            }
            RomUtils.RomType.MEIZU -> {
                add(OemRoute("oem") { pkg ->
                    Intent("com.meizu.safe.security.SHOW_APPSEC").apply {
                        putExtra("packageName", pkg)
                        component = ComponentName("com.meizu.safe", "com.meizu.safe.security.AppSecActivity")
                    }
                })
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
            }
            else -> {
                add(OemRoute("standard") { pkg ->
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$pkg"))
                })
            }
        }
        add(OemRoute("fallback") { pkg ->
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg"))
        })
    }

    // ─── Autostart (background launch) ───────────────────────────────────────────

    fun autostartRoutes(romType: RomUtils.RomType): List<OemRoute> = buildList {
        when (romType) {
            RomUtils.RomType.XIAOMI -> {
                // Direct component (no action) — works when AutoStartManagementActivity exists
                // but doesn't handle miui.intent.action.APP_PERM_EDITOR (MIUI 12/13)
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity")
                        putExtra("extra_pkgname", pkg)
                    }
                })
                // Action-qualified variant kept as second try for older MIUI builds
                add(OemRoute("oem") { pkg ->
                    Intent("miui.intent.action.APP_PERM_EDITOR").apply {
                        setClassName("com.miui.securitycenter",
                            "com.miui.permcenter.autostart.AutoStartManagementActivity")
                        putExtra("extra_pkgname", pkg)
                    }
                })
            }
            RomUtils.RomType.OPPO -> {
                // com.oplus.safecenter — package name used on ColorOS 12+ / newer OPPO models
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.permission.startup.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.startupapp.StartupAppListActivity")
                    }
                })
                // com.coloros.safecenter — older ColorOS path
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.startupapp.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oppo.safe",
                            "com.oppo.safe.permission.startup.StartupAppListActivity")
                    }
                })
            }
            RomUtils.RomType.REALME -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.permission.startup.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.startupapp.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.startupapp.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oppo.safe",
                            "com.oppo.safe.permission.startup.StartupAppListActivity")
                    }
                })
            }
            RomUtils.RomType.ONEPLUS -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oneplus.security",
                            "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.startupapp.StartupAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.startupapp.StartupAppListActivity")
                    }
                })
            }
            RomUtils.RomType.VIVO -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")
                    }
                })
            }
            RomUtils.RomType.IQOO -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.iqoo.secure",
                            "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")
                    }
                })
            }
            RomUtils.RomType.HONOR -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.optimize.process.ProtectActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.optimize.process.ProtectActivity")
                    }
                })
            }
            RomUtils.RomType.HUAWEI -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.optimize.process.ProtectActivity")
                    }
                })
            }
            else -> Unit
        }
        // Universal fallback: app info page shows autostart toggle on most China ROMs
        add(OemRoute("fallback") { pkg ->
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
            }
        })
    }

    // ─── Battery / background restriction ────────────────────────────────────────

    /**
     * [appLabel] is needed by MIUI's powerkeeper screen — pass `applicationInfo.loadLabel(pm).toString()`.
     */
    fun batteryRoutes(romType: RomUtils.RomType, appLabel: String): List<OemRoute> = buildList {
        when (romType) {
            RomUtils.RomType.XIAOMI -> {
                // HiddenAppsConfigActivity is the newer MIUI path; fall back to the older one
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.miui.powerkeeper",
                            "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")
                        putExtra("package_name", pkg)
                        putExtra("package_label", appLabel)
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.miui.powerkeeper",
                            "com.miui.powerkeeper.ui.HiddenAppsContainerManagementActivity")
                        putExtra("package_name", pkg)
                        putExtra("package_label", appLabel)
                    }
                })
            }
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // com.oplus.safecenter — package name used on ColorOS 12+ / newer OPPO models
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.powermonitor.appmonitor.AppMonitorActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.powermonitor.PowerManagerActivity")
                    }
                })
                // com.coloros.safecenter — older ColorOS path
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.powermonitor.appmonitor.AppMonitorActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.powermonitor.PowerManagerActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.oppo.safe",
                            "com.oppo.safe.permission.startup.StartupAppListActivity")
                    }
                })
            }
            RomUtils.RomType.VIVO, RomUtils.RomType.IQOO -> {
                // ExcessivePowerManagerActivity removed — requires system permission (SecurityException)
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                    }
                })
            }
            RomUtils.RomType.HONOR -> {
                // MagicOS 10+ candidates — ProtectActivity removed in newer hihonor builds
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.appmanage.bg.ui.BgManageActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.power.appmanage.BgManageActivity")
                    }
                })
                // Older hihonor / huawei paths
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.optimize.process.ProtectActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.optimize.process.ProtectActivity")
                    }
                })
            }
            RomUtils.RomType.HUAWEI -> {
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.systemmanager.optimize.process.ProtectActivity")
                    }
                })
            }
            else -> Unit
        }
        add(OemRoute("standard") { pkg ->
            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                data = Uri.parse("package:$pkg")
            }
        })
        add(OemRoute("fallback") { pkg ->
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
            }
        })
    }

    // ─── Full-screen intent (Android 14+) ────────────────────────────────────────

    fun fsiRoutes(): List<OemRoute> = listOf(
        // Standard Android 14+ action — works on all ROMs that implement API 34+.
        // Do not add OEM-specific routes here unless you have device-verified evidence
        // that the OEM screen consistently exposes the FSI toggle: KEY_FSI_SHOWN is set
        // true after any successful launch, so a wrong screen permanently suppresses the prompt.
        OemRoute("standard") { pkg ->
            Intent("android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT").apply {
                data = Uri.parse("package:$pkg")
            }
        }
    )
}
