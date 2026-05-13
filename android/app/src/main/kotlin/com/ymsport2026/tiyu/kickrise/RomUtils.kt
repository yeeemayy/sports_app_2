package com.ymsport2026.tiyu.kickrise

import android.app.AppOpsManager
import android.content.Context
import android.os.Build

object RomUtils {

    enum class RomType { XIAOMI, HUAWEI, OPPO, VIVO, IQOO, HONOR, ONEPLUS, REALME, MEIZU, SAMSUNG, OTHER }

    data class RomInfo(
        val romType: RomType,
        val osLabel: String,         // e.g. "HyperOS", "MIUI", "EMUI", "MagicOS", "ColorOS", "OriginOS", "Flyme"
        val osVersion: String,
        val detectionSource: String  // "prop" or "brand"
    )

    data class ChinaRomInfo(
        val isChina: Boolean,
        val source: String
    )

    private fun getSystemProp(key: String): String {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val method = clazz.getMethod("get", String::class.java, String::class.java)
            (method.invoke(null, key, "") as? String)?.trim() ?: ""
        } catch (_: Exception) { "" }
    }

    fun detectRomInfo(): RomInfo {
        // HyperOS (Xiaomi, newer)
        val hyperOsVersion = getSystemProp("ro.mi.os.version.name")
        if (hyperOsVersion.isNotBlank()) {
            return RomInfo(RomType.XIAOMI, "HyperOS", hyperOsVersion, "prop")
        }

        // MIUI (Xiaomi, older)
        val miuiVersion = getSystemProp("ro.miui.ui.version.name")
        if (miuiVersion.isNotBlank()) {
            return RomInfo(RomType.XIAOMI, "MIUI", miuiVersion, "prop")
        }

        // EMUI (Huawei)
        val emuiVersion = getSystemProp("ro.build.version.emui")
        if (emuiVersion.isNotBlank()) {
            return RomInfo(RomType.HUAWEI, "EMUI", emuiVersion, "prop")
        }

        // MagicOS (Honor)
        val magicVersion = getSystemProp("ro.build.version.magic")
        if (magicVersion.isNotBlank()) {
            return RomInfo(RomType.HONOR, "MagicOS", magicVersion, "prop")
        }

        // Realme UI (Realme)
        val realmeuiVersion = getSystemProp("ro.build.version.realmeui")
        if (realmeuiVersion.isNotBlank()) {
            return RomInfo(RomType.REALME, "Realme UI", realmeuiVersion, "prop")
        }

        // ColorOS (OPPO / OnePlus China)
        val colorosVersion = getSystemProp("ro.build.version.opporom")
        if (colorosVersion.isNotBlank()) {
            val brand = Build.BRAND.lowercase()
            val manufacturer = Build.MANUFACTURER.lowercase()
            // 修正：OnePlus 国行是 ColorOS，不是 OxygenOS China
            val (romType, osLabel) = when {
                manufacturer.contains("oneplus") || brand.contains("oneplus") -> RomType.ONEPLUS to "ColorOS"
                else -> RomType.OPPO to "ColorOS"
            }
            return RomInfo(romType, osLabel, colorosVersion, "prop")
        }

        // OriginOS / FuntouchOS (Vivo / iQOO)
        val vivoOsName = getSystemProp("ro.vivo.os.name")
        val vivoOsVersion = getSystemProp("ro.vivo.os.version")
        val vivoOriginOsVersion = getSystemProp("ro.vivo.originos.version")
        if (vivoOsVersion.isNotBlank() || vivoOsName.isNotBlank() || vivoOriginOsVersion.isNotBlank()) {
            val brand = Build.BRAND.lowercase()
            val osLabel = when {
                vivoOriginOsVersion.isNotBlank() -> "OriginOS"
                vivoOsName.contains("origin", ignoreCase = true) -> "OriginOS"
                else -> "FuntouchOS"
            }
            val romType = if (brand.contains("iqoo")) RomType.IQOO else RomType.VIVO
            return RomInfo(romType, osLabel, vivoOriginOsVersion.ifBlank { vivoOsVersion.ifBlank { vivoOsName } }, "prop")
        }

        // Flyme (Meizu)
        val flymePublished = getSystemProp("ro.flyme.published")
        if (flymePublished.isNotBlank()) {
            return RomInfo(RomType.MEIZU, "Flyme", Build.DISPLAY, "prop")
        }

        return detectFromBrand()
    }

    private fun detectFromBrand(): RomInfo {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        return when {
            manufacturer.contains("xiaomi") || brand.contains("xiaomi") || brand.contains("redmi") ->
                RomInfo(RomType.XIAOMI, "MIUI", "", "brand")
            manufacturer.contains("huawei") || brand.contains("huawei") ->
                RomInfo(RomType.HUAWEI, "EMUI", "", "brand")
            manufacturer.contains("honor") || brand.contains("honor") ->
                RomInfo(RomType.HONOR, "MagicOS", "", "brand")
            manufacturer.contains("oppo") || brand.contains("oppo") ->
                RomInfo(RomType.OPPO, "ColorOS", "", "brand")
            manufacturer.contains("oneplus") || brand.contains("oneplus") ->
                RomInfo(RomType.ONEPLUS, "ColorOS", "", "brand")      // 同样修正标签
            brand.contains("realme") ->
                RomInfo(RomType.REALME, "Realme UI", "", "brand")
            brand.contains("iqoo") ->
                RomInfo(RomType.IQOO, "OriginOS", "", "brand")
            manufacturer.contains("vivo") || brand.contains("vivo") ->
                RomInfo(RomType.VIVO, "FuntouchOS", "", "brand")
            manufacturer.contains("meizu") || brand.contains("meizu") ->
                RomInfo(RomType.MEIZU, "Flyme", "", "brand")
            manufacturer.contains("samsung") || brand.contains("samsung") ->
                RomInfo(RomType.SAMSUNG, "OneUI", "", "brand")
            else -> RomInfo(RomType.OTHER, "", "", "brand")
        }
    }

    // Cached on first access — RomInfo is immutable and will not change at runtime.
    private val cachedRomInfo: RomInfo by lazy { detectRomInfo() }
    private val cachedChinaRomInfo: ChinaRomInfo by lazy { detectChinaRomInfo() }

    fun detect(): RomType = cachedRomInfo.romType

    fun romInfo(): RomInfo = cachedRomInfo

    /**
     * True for OEM families known to impose aggressive background-launch and auto-start
     * restrictions regardless of region (China or global). Does NOT include Samsung, which
     * uses standard Android BAL rules on global firmware.
     *
     * Use [isChinaRom] when the decision depends on CN vs. global region.
     * Use this when the decision depends on OEM UI customizations (e.g. overlay prompts).
     */
    fun isAggressiveOemRom(): Boolean = detect() in setOf(
        RomType.XIAOMI, RomType.HUAWEI, RomType.HONOR,
        RomType.OPPO, RomType.ONEPLUS, RomType.VIVO, RomType.IQOO, RomType.REALME, RomType.MEIZU
    )

    @Deprecated(
        "Misleading name — use isAggressiveOemRom() for OEM-behavior checks or isChinaRom() for region checks.",
        ReplaceWith("isAggressiveOemRom()")
    )
    fun isDomesticRom(): Boolean = isAggressiveOemRom()

    fun chinaRomInfo(): ChinaRomInfo = cachedChinaRomInfo

    fun isChinaRom(): Boolean = cachedChinaRomInfo.isChina

    private fun detectChinaRomInfo(): ChinaRomInfo {
        val info = cachedRomInfo
        val values = chinaRegionProps()
        val joined = values.entries.joinToString(" ") { "${it.key}=${it.value}" }
        val upper = joined.uppercase()

        // ---- Xiaomi / Redmi / POCO ----
        if (info.romType == RomType.XIAOMI) {
            val globalXiaomiSuffixes = listOf("MIXM", "EUXM", "INXM", "IDXM", "RUXM", "TWXM", "TRXM", "JPXM", "KRXM", "LUXM", "CAXM")
            if ("CNXM" in upper) return ChinaRomInfo(true, "xiaomi_cnxm")
            if (globalXiaomiSuffixes.any { it in upper }) return ChinaRomInfo(false, "xiaomi_global_suffix")
        }

        // ---- Huawei / Honor ----
        if (info.romType == RomType.HUAWEI || info.romType == RomType.HONOR) {
            val hwCountry = values["ro.hw.country"]?.uppercase()
            val hwOptb = values["ro.config.hw_optb"]
            if (hwCountry == "CN") return ChinaRomInfo(true, "ro.hw.country")
            if (hwOptb == "156") return ChinaRomInfo(true, "ro.config.hw_optb")
            // 新增：部分新机型会用 ro.build.hw_region
            val hwRegion = values["ro.build.hw_region"]?.uppercase()
            if (hwRegion == "CN") return ChinaRomInfo(true, "ro.build.hw_region")
        }

        // ---- OPPO / OnePlus / Realme (all share same ColorOS region props) ----
        if (info.romType in setOf(RomType.OPPO, RomType.ONEPLUS, RomType.REALME)) {
            // 新增：直接检查 oppo 系典型中国版标识
            val oppoRegion = values["persist.sys.oppo.region"]?.uppercase()
            if (oppoRegion == "CN" || oppoRegion == "CHINA") return ChinaRomInfo(true, "oppo_region")
            val oplusRegion = values["ro.vendor.oplus.regionmark"]?.uppercase()
                ?: values["ro.oppo.regionmark"]?.uppercase()
            if (oplusRegion == "CN") return ChinaRomInfo(true, "oplus_regionmark")
            // 海外版本明确标记
            if (oppoRegion in listOf("GLOBAL", "EU", "IN", "ID", "MY", "PH", "TH", "VN", "RU", "TW", "HK", "JP")) {
                return ChinaRomInfo(false, "oppo_region")
            }
        }

        // ---- Vivo / iQOO ----
        if (info.romType in setOf(RomType.VIVO, RomType.IQOO)) {
            val overseas = values["ro.vivo.product.overseas"]?.uppercase()
            if (overseas == "NO" || overseas == "0") return ChinaRomInfo(true, "ro.vivo.product.overseas")
            if (overseas == "YES" || overseas == "1") return ChinaRomInfo(false, "ro.vivo.product.overseas")
        }

        // ---- Samsung ----
        if (info.romType == RomType.SAMSUNG) {
            // 国行三星通常有 CSC 为 CHC, CHN, CTC, CHM, CHU 等
            val csc = values["ro.csc.sales_code"]?.uppercase()
                ?: values["ril.sales_code"]?.uppercase()
                ?: values["persist.sys.omc_etcpath"]?.substringAfterLast("/")?.uppercase()
            if (csc in listOf("CHC", "CHN", "CTC", "CHM", "CHU", "CH")) return ChinaRomInfo(true, "samsung_csc")
            // 也有 ro.build.china.version 属性
            if (getSystemProp("ro.build.china.version").isNotBlank()) return ChinaRomInfo(true, "samsung_china_version")
        }

        // ---- 通用区域键兜底 ----
        val regionKeys = listOf(
            "ro.product.locale.region",
            "ro.product.country.region",
            "ro.miui.region",
            "persist.sys.miui.region",
            "ro.mi.os.region",
            "persist.sys.oppo.region",
            "ro.oppo.regionmark",
            "ro.vendor.oplus.regionmark",
            "ro.vivo.product.overseas",
            "ro.build.hw_region",
            "ro.config.ce_platform"       // 新增，部分机型用这个标识中国区
        )
        for (key in regionKeys) {
            val value = values[key]?.uppercase() ?: continue
            if (value == "CN" || value == "CHINA" || value == "156") return ChinaRomInfo(true, key)
            if (value in setOf("GLOBAL", "EU", "EEA", "IN", "ID", "MY", "PH", "TH", "VN", "RU", "TW", "HK", "JP")) {
                return ChinaRomInfo(false, key)
            }
            if (key == "ro.vivo.product.overseas") {
                if (value == "NO" || value == "0") return ChinaRomInfo(true, key)
                if (value == "YES" || value == "1") return ChinaRomInfo(false, key)
            }
        }

        // 最终未识别
        return ChinaRomInfo(false, "unknown_or_global")
    }

    private fun chinaRegionProps(): Map<String, String> = buildMap {
        // 尽可能多地收集区域相关属性
        val keys = listOf(
            "ro.product.mod_device",
            "ro.build.version.incremental",
            "ro.miui.region",
            "persist.sys.miui.region",
            "ro.mi.os.region",
            "ro.product.locale.region",
            "persist.sys.oppo.region",
            "ro.oppo.regionmark",
            "ro.vendor.oplus.regionmark",
            "ro.vivo.product.overseas",
            "ro.product.country.region",
            "ro.hw.country",
            "ro.config.hw_optb",
            "ro.build.hw_region",
            "ro.config.ce_platform",
            "ro.csc.sales_code",
            "ril.sales_code",
            "persist.sys.omc_etcpath"
        )
        keys.forEach { key ->
            val value = getSystemProp(key)
            if (value.isNotBlank()) put(key, value)
        }
        if (Build.DISPLAY.isNotBlank()) put("Build.DISPLAY", Build.DISPLAY)
    }

    fun romLabel(): String {
        val info = cachedRomInfo
        return when {
            info.osVersion.isNotBlank() -> "${info.osLabel}/${info.osVersion}"
            info.osLabel.isNotBlank() -> info.osLabel
            else -> info.romType.name
        }
    }

    data class BgPopupPermissionInfo(
        val allowed: String,  // "true" | "false" | "unknown"
        val check: String     // describes the method used, e.g. "oem_appops_10021" or "not_supported"
    )

    /**
     * Best-effort check for OEM "background pop-up" permission.
     *
     * Xiaomi MIUI/HyperOS enforces a separate AppOps gate (op 10021) for background Activity
     * launches that is distinct from SYSTEM_ALERT_WINDOW. A device with overlay=true but this op
     * denied will silently block background popups. Other OEMs have equivalent restrictions but
     * no well-documented AppOps code — they return "unknown" until device-verified codes are found.
     */
    fun checkBgPopupPermission(context: Context): BgPopupPermissionInfo = when (detect()) {
        RomType.XIAOMI -> checkMiuiBackgroundPopup(context)
        RomType.HUAWEI, RomType.HONOR -> BgPopupPermissionInfo("unknown", "not_supported")
        RomType.VIVO, RomType.IQOO -> BgPopupPermissionInfo("unknown", "not_supported")
        else -> BgPopupPermissionInfo("unknown", "not_applicable")
    }

    private fun checkMiuiBackgroundPopup(context: Context): BgPopupPermissionInfo {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val uid = context.applicationInfo.uid
            val mode = appOps.javaClass.getMethod(
                "checkOpNoThrow",
                Int::class.javaPrimitiveType,
                Int::class.javaPrimitiveType,
                String::class.java
            ).invoke(appOps, 10021, uid, context.packageName) as Int
            BgPopupPermissionInfo(
                allowed = if (mode == AppOpsManager.MODE_ALLOWED) "true" else "false",
                check = "oem_appops_10021"
            )
        } catch (_: Exception) {
            BgPopupPermissionInfo("unknown", "oem_appops_10021")
        }
    }

    /** Key system properties for field diagnostics — only non-blank values are included. */
    fun diagnosticProps(): Map<String, String> = buildMap {
        listOf(
            "ro.miui.ui.version.name",
            "ro.mi.os.version.name",
            "ro.build.version.emui",
            "ro.build.version.magic",
            "ro.build.version.opporom",
            "ro.build.version.realmeui",
            "ro.vivo.os.version",
            "ro.vivo.os.name",
            "ro.flyme.published",
            "ro.product.mod_device",
            "ro.build.version.incremental",
            "ro.miui.region",
            "persist.sys.miui.region",
            "ro.mi.os.region",
            "ro.product.locale.region",
            "persist.sys.oppo.region",
            "ro.oppo.regionmark",
            "ro.vendor.oplus.regionmark",
            "ro.vivo.product.overseas",
            "ro.product.country.region",
            "ro.hw.country",
            "ro.config.hw_optb",
            "ro.build.hw_region",
            "ro.config.ce_platform",
            "ro.csc.sales_code",
            "ro.build.china.version",
            "ro.build.display.id"
        ).forEach { key ->
            val value = getSystemProp(key)
            if (value.isNotBlank()) put(key, value)
        }
    }
}