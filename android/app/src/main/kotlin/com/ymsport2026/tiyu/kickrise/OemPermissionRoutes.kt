package com.tiyu2.tiyu.kickrise

import android.content.ComponentName
import android.content.Context
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

    enum class RouteType { OVERLAY, AUTOSTART, BATTERY, NOTIFICATION_FSI, BACKGROUND_POPUP }

    data class OemRoute(
        val label: String,                       // "oem" | "standard" | "fallback"
        val intentFactory: (pkg: String) -> Intent
    )

    private fun oemAppLaunchRoutes(context: Context, vararg packageNames: String, label: String = "oem"): List<OemRoute> =
        packageNames.mapNotNull { oemPkg ->
            context.packageManager.getLaunchIntentForPackage(oemPkg)?.let { launchIntent ->
                OemRoute(label) { _ -> launchIntent }
            }
        }

    private fun colorOsAutostartRoutes(): List<OemRoute> = listOf(
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.coloros.safecenter",
                    "com.coloros.safecenter.permission.startup.StartupAppListActivity")
            }
        },
        // Unverified community path kept as a low-cost fallback; common ColorOS builds use permission.startup.
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.coloros.safecenter",
                    "com.coloros.safecenter.startupapp.StartupAppListActivity")
            }
        },
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.coloros.safe",
                    "com.coloros.safe.permission.startup.StartupAppListActivity")
            }
        }
    )

    private fun colorOsBatteryRoutes(): List<OemRoute> = listOf(
        // Newer OPlus package candidate; keep under field validation and fall through if unresolved.
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.oplus.oppoguardelf",
                    "com.oplus.powermanager.fuelgaue.PowerConsumptionActivity")
            }
        },
        // 旧 ColorOS
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.coloros.oppoguardelf",
                    "com.coloros.powermanager.fuelgaue.PowerConsumptionActivity")
            }
        },
        OemRoute("oem") { _ ->
            Intent().apply {
                component = ComponentName("com.coloros.oppoguardelf",
                    "com.coloros.powermanager.fuelgaue.PowerUsageModelActivity")
            }
        }
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
                // Class namespace is permissionmanager, but the owning package remains hihonor.systemmanager.
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.permissionmanager.ui.MainActivity")
                        putExtra("packageName", pkg)
                    }
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
        // ColorOS: pass isGetPermission + permissionList so the page scrolls to and highlights
        // the overlay toggle. Documented at open.oppomobile.com/new/developmentDoc/info?id=12983.
        // Other OEMs: standard app details fallback.
        if (romType in setOf(RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS)) {
            add(OemRoute("fallback") { pkg ->
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg")).apply {
                    putExtra("isGetPermission", true)
                    putStringArrayListExtra("permissionList", arrayListOf("android.permission.SYSTEM_ALERT_WINDOW"))
                }
            })
        } else {
            add(OemRoute("fallback") { pkg ->
                Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$pkg"))
            })
        }
    }

    // ─── Autostart (background launch) ───────────────────────────────────────────

    fun autostartRoutes(context: Context, romType: RomUtils.RomType): List<OemRoute> = buildList {
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
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // Phase 1: all-in-one page (autostart + background popup + lock screen display).
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionAppDetailActivity")
                        putExtra("package_name", pkg)
                    }
                })
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionTopActivity")
                        putExtra("package_name", pkg)
                    }
                })
                // Phase 2: safecenter app main page — opens whichever safecenter package is
                // installed. Labelled oem_top so all three OEM steps are marked done at once;
                // the page covers autostart + background popup + lockscreen display together.
                addAll(oemAppLaunchRoutes(context, "com.coloros.safecenter", "com.oplus.safecenter", "com.color.safecenter", "com.oppo.safe", label = "oem_top"))
                // Phase 3: app details page fallback.
                add(OemRoute("fallback") { pkg ->
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.parse("package:$pkg"))
                })
                // Phase 3: autostart-only list pages — last resort.
                addAll(colorOsAutostartRoutes())
                if (romType == RomUtils.RomType.ONEPLUS) {
                    add(OemRoute("oem") { _ ->
                        Intent().apply {
                            component = ComponentName("com.oneplus.security",
                                "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity")
                        }
                    })
                }
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
                // MagicOS 10 per-app permission page — also covers autostart on this version.
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.permission.ui.PermissionAppDetailActivity")
                        putExtra("packageName", pkg)
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                    }
                })
                add(OemRoute("oem") { _ ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.appcontrol.activity.StartupAppControlActivity")
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
                            "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")
                    }
                })
                // XXPermissions fallback: open system manager app main page
                addAll(oemAppLaunchRoutes(context, "com.hihonor.systemmanager", "com.huawei.systemmanager"))
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
                // XXPermissions fallback: open system manager app main page
                addAll(oemAppLaunchRoutes(context, "com.huawei.systemmanager"))
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
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS ->
                addAll(colorOsBatteryRoutes())
            RomUtils.RomType.VIVO, RomUtils.RomType.IQOO -> Unit
            RomUtils.RomType.HONOR -> Unit
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
                            "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")
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

    // ————— Background Pop up Routes ────────────────────────────────────────

    fun backgroundPopupRoutes(context: Context, romType: RomUtils.RomType, appUid: Int? = null): List<OemRoute> = buildList {
        when (romType) {
            RomUtils.RomType.XIAOMI -> {
                // 授权管理 → 权限管理
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.miui.securitycenter",
                            "com.miui.permcenter.permissions.AppPermissionsEditorActivity")
                        // 部分老 MIUI 版本需要 UID，尝试双传
                        putExtra("extra_pkgname", pkg)
                        appUid?.let { putExtra("extra_package_uid", it) }
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.miui.securitycenter",
                            "com.miui.permcenter.permissions.PermissionsEditorActivity")
                        putExtra("extra_pkgname", pkg)
                        appUid?.let { putExtra("extra_package_uid", it) }
                    }
                })
            }
            RomUtils.RomType.HONOR -> {
                // MagicOS 10 per-app permission detail page (covers background launch + lock screen display).
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.systemmanager.permission.ui.PermissionAppDetailActivity")
                        putExtra("packageName", pkg)
                    }
                })
                // Older MagicUI / pre-MagicOS paths.
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.hihonor.systemmanager",
                            "com.hihonor.permissionmanager.ui.MainActivity")
                        putExtra("packageName", pkg)
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.permissionmanager.ui.MainActivity")
                        putExtra("packageName", pkg)
                    }
                })
            }
            RomUtils.RomType.HUAWEI -> {
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.huawei.systemmanager",
                            "com.huawei.permissionmanager.ui.MainActivity")
                        putExtra("packageName", pkg)
                    }
                })
            }
            RomUtils.RomType.VIVO, RomUtils.RomType.IQOO -> {
                // PurviewTabActivity without a tabId opens the general per-app permissions page.
                // Labelled oem (not oem_top) so the lockscreen_display step runs as a separate visit
                // — field testing showed the page does not reliably expose the lock screen display toggle.
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.vivo.permissionmanager",
                            "com.vivo.permissionmanager.activity.PurviewTabActivity")
                        putExtra("packagename", pkg)
                    }
                })
            }
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // PermissionTopActivity / PermissionAppDetailActivity show autostart + background
                // popup + lock screen display all on one page. ColorOS 16 uses the features.permission
                // package; older ColorOS uses permission.startup.
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionAppDetailActivity")
                        putExtra("package_name", pkg)
                    }
                })
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionTopActivity")
                        putExtra("package_name", pkg)
                    }
                })
                // Per-permission fallbacks for older ColorOS where PermissionTopActivity does not
                // exist. These only show the background popup toggle, not the other two.
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.permission.PermissionManagerActivity")
                        putExtra("package_name", pkg)
                    }
                })
                add(OemRoute("oem") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.coloros.safecenter",
                            "com.coloros.safecenter.permission.PermissionManagerActivity")
                        putExtra("package_name", pkg)
                    }
                })
                // Safecenter app main page — labelled oem_top so all three OEM steps are
                // marked done at once; the page covers all three toggles together.
                addAll(oemAppLaunchRoutes(context, "com.coloros.safecenter", "com.oplus.safecenter", "com.color.safecenter", "com.oppo.safe", label = "oem_top"))
            }
            else -> Unit
        }
        // 最终回退：应用详情
        add(OemRoute("fallback") { pkg ->
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
            }
        })
    }

    // ─── Lock screen display ──────────────────────────────────────────────────────

    fun lockscreenDisplayRoutes(context: Context, romType: RomUtils.RomType): List<OemRoute> = buildList {
        when (romType) {
            RomUtils.RomType.OPPO, RomUtils.RomType.REALME, RomUtils.RomType.ONEPLUS -> {
                // Same all-in-one page — user confirms the lock screen display toggle.
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionAppDetailActivity")
                        putExtra("package_name", pkg)
                    }
                })
                add(OemRoute("oem_top") { pkg ->
                    Intent().apply {
                        component = ComponentName("com.oplus.safecenter",
                            "com.oplus.safecenter.features.permission.PermissionTopActivity")
                        putExtra("package_name", pkg)
                    }
                })
                // Safecenter app main page — labelled oem_top so all three OEM steps are
                // marked done at once; the page covers all three toggles together.
                addAll(oemAppLaunchRoutes(context, "com.coloros.safecenter", "com.oplus.safecenter", "com.color.safecenter", "com.oppo.safe", label = "oem_top"))
            }
            RomUtils.RomType.VIVO, RomUtils.RomType.IQOO -> {
                // PurviewTabActivity without a tabId does not reliably expose the lock screen
                // display toggle. Following XXPermissions: open the permission manager app main
                // page so the user can find and enable it manually.
                addAll(oemAppLaunchRoutes(context, "com.vivo.permissionmanager", "com.bairenkeji.icaller", "com.iqoo.secure"))
            }
            else -> Unit
        }
        add(OemRoute("fallback") { pkg ->
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$pkg")
            }
        })
    }
}
