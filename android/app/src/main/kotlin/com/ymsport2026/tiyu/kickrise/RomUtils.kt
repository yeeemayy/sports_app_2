package com.ymsport2026.tiyu.kickrise

import android.os.Build

object RomUtils {

    enum class RomType { XIAOMI, HUAWEI, OPPO, VIVO, IQOO, HONOR, ONEPLUS, REALME, MEIZU, SAMSUNG, OTHER }

    data class RomInfo(
        val romType: RomType,
        val osLabel: String,         // e.g. "HyperOS", "MIUI", "EMUI", "MagicOS", "ColorOS", "OriginOS", "Flyme"
        val osVersion: String,
        val detectionSource: String  // "prop" or "brand"
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
            val (romType, osLabel) = when {
                manufacturer.contains("oneplus") || brand.contains("oneplus") -> RomType.ONEPLUS to "OxygenOS China"
                else -> RomType.OPPO to "ColorOS"
            }
            return RomInfo(romType, osLabel, colorosVersion, "prop")
        }

        // OriginOS / FuntouchOS (Vivo / iQOO)
        val vivoOsName = getSystemProp("ro.vivo.os.name")
        val vivoOsVersion = getSystemProp("ro.vivo.os.version")
        if (vivoOsVersion.isNotBlank() || vivoOsName.isNotBlank()) {
            val brand = Build.BRAND.lowercase()
            val osLabel = if (vivoOsName.contains("origin", ignoreCase = true)) "OriginOS" else "FuntouchOS"
            val romType = if (brand.contains("iqoo")) RomType.IQOO else RomType.VIVO
            return RomInfo(romType, osLabel, vivoOsVersion.ifBlank { vivoOsName }, "prop")
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
                RomInfo(RomType.ONEPLUS, "OxygenOS China", "", "brand")
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

    fun detect(): RomType = cachedRomInfo.romType

    fun romInfo(): RomInfo = cachedRomInfo

    fun isDomesticRom(): Boolean = detect() in setOf(
        RomType.XIAOMI, RomType.HUAWEI, RomType.HONOR,
        RomType.OPPO, RomType.ONEPLUS, RomType.VIVO, RomType.IQOO, RomType.REALME, RomType.MEIZU
    )

    fun romLabel(): String {
        val info = cachedRomInfo
        return when {
            info.osVersion.isNotBlank() -> "${info.osLabel}/${info.osVersion}"
            info.osLabel.isNotBlank() -> info.osLabel
            else -> info.romType.name
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
            "ro.build.display.id"
        ).forEach { key ->
            val value = getSystemProp(key)
            if (value.isNotBlank()) put(key, value)
        }
    }
}
