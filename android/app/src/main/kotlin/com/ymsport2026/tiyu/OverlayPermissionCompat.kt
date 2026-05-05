package com.ymsport2026.tiyu

import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.provider.Settings

object OverlayPermissionCompat {

    fun canDrawOverlays(context: Context): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
            Settings.canDrawOverlays(context)
    }

    fun needsUserGrant(context: Context): Boolean {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !Settings.canDrawOverlays(context)
    }

    // Android 10 Go edition restricts "Display over other apps"; older low-RAM devices do not.
    fun isOverlayUnsupported(context: Context): Boolean {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && am.isLowRamDevice
    }
}
