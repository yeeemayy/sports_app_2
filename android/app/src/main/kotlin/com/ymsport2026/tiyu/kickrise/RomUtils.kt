package com.ymsport2026.tiyu.kickrise

import android.os.Build

object RomUtils {

    enum class RomType { XIAOMI, HUAWEI, OPPO, VIVO, HONOR, ONEPLUS, REALME, MEIZU, SAMSUNG, OTHER }

    fun detect(): RomType {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val brand = Build.BRAND.lowercase()
        return when {
            manufacturer.contains("xiaomi") || brand.contains("xiaomi") || brand.contains("redmi") -> RomType.XIAOMI
            manufacturer.contains("huawei") || brand.contains("huawei") -> RomType.HUAWEI
            brand.contains("honor") -> RomType.HONOR
            manufacturer.contains("oppo") || brand.contains("oppo") -> RomType.OPPO
            manufacturer.contains("vivo") || brand.contains("vivo") -> RomType.VIVO
            manufacturer.contains("oneplus") || brand.contains("oneplus") -> RomType.ONEPLUS
            manufacturer.contains("realme") || brand.contains("realme") -> RomType.REALME
            manufacturer.contains("meizu") || brand.contains("meizu") -> RomType.MEIZU
            manufacturer.contains("samsung") || brand.contains("samsung") -> RomType.SAMSUNG
            else -> RomType.OTHER
        }
    }

    fun isDomesticRom(): Boolean = detect() in setOf(
        RomType.XIAOMI, RomType.HUAWEI, RomType.HONOR,
        RomType.OPPO, RomType.VIVO, RomType.REALME, RomType.MEIZU
    )

    fun romLabel(): String = detect().name
}
