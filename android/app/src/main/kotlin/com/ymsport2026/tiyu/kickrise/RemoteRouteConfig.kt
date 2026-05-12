package com.ymsport2026.tiyu.kickrise

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import org.json.JSONObject

/**
 * Fetches and caches a server-provided route table for OEM permission settings screens.
 *
 * OEM component names go stale across ROM versions. This config lets the backend patch broken
 * routes without a new APK. Local [OemPermissionRoutes] remain the fallback when the server
 * is unreachable or has no entry for this device.
 *
 * Expected endpoint: GET <baseUrl>/route-config  (device context sent as headers)
 * Expected response shape:
 * {
 *   "overlay":          [ { "label": "oem", "action": "...", "component": "pkg/cls", "data": "...", "extras": { "key": "value" } }, ... ],
 *   "autostart":        [ ... ],
 *   "battery":          [ ... ],
 *   "fsi":              [ ... ],
 *   "background_popup": [ ... ]
 * }
 *
 * Placeholders in "data", "component", and extra values:
 *   {package} → app package name
 *   {uid}     → app UID (integer string) — required by Xiaomi's AppPermissionsEditorActivity
 */
class RemoteRouteConfig(private val context: Context, private val baseUrl: String) {

    private val prefs = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)

    fun fetchAndCache() {
        if (baseUrl.isBlank()) return
        try {
            val json = KickRiseApiClient(context).fetchRouteConfig(baseUrl) ?: return
            prefs.edit()
                .putString(KEY_REMOTE_ROUTES, json)
                .putLong(KEY_REMOTE_ROUTES_TS, System.currentTimeMillis())
                .apply()
            Log.d(TAG, "Remote route config cached (${json.length} bytes)")
        } catch (e: Exception) {
            Log.w(TAG, "Failed to fetch remote route config: ${e.message}")
        }
    }

    fun isStale(): Boolean {
        val ts = prefs.getLong(KEY_REMOTE_ROUTES_TS, 0L)
        return System.currentTimeMillis() - ts > CACHE_TTL_MS
    }

    /**
     * Returns server-provided routes for [routeType]
     * ("overlay" | "autostart" | "battery" | "fsi" | "background_popup").
     * Returns an empty list if no cache exists or parsing fails.
     */
    fun getRoutesForType(routeType: String): List<Pair<Intent, String>> {
        val raw = prefs.getString(KEY_REMOTE_ROUTES, null) ?: return emptyList()
        return try {
            val arr = JSONObject(raw).optJSONArray(routeType) ?: return emptyList()
            buildList {
                for (i in 0 until arr.length()) {
                    val entry = arr.getJSONObject(i)
                    val intent = buildIntent(entry) ?: continue
                    val label = entry.optString("label", "remote_oem")
                    add(intent to label)
                }
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to parse remote routes for $routeType: ${e.message}")
            emptyList()
        }
    }

    private fun buildIntent(entry: JSONObject): Intent? {
        return try {
            val pkg = context.packageName
            val uid = context.applicationInfo.uid.toString()
            fun String.replacePlaceholders() = replace("{package}", pkg).replace("{uid}", uid)
            val intent = Intent()
            entry.optString("action").takeIf { it.isNotBlank() }?.let { intent.action = it }
            val componentStr = entry.optString("component").replacePlaceholders()
            if (componentStr.contains("/")) {
                ComponentName.unflattenFromString(componentStr)?.let { intent.component = it }
            }
            val dataStr = entry.optString("data").replacePlaceholders()
            if (dataStr.isNotBlank()) intent.data = Uri.parse(dataStr)
            entry.optJSONObject("extras")?.keys()?.forEach { k ->
                intent.putExtra(k, entry.optJSONObject("extras")!!.getString(k).replacePlaceholders())
            }
            if (!isAllowed(intent)) {
                Log.w(TAG, "Remote route rejected by allowlist: action=${intent.action} component=${intent.component}")
                return null
            }
            intent
        } catch (e: Exception) {
            Log.w(TAG, "buildIntent failed: ${e.message}")
            null
        }
    }

    /**
     * Validates that a server-provided intent targets only known settings screens.
     *
     * Rules:
     * - Explicit components (package/class) must belong to a known OEM package prefix.
     *   Standard Android Settings screens are not in this list because they should always be
     *   expressed as implicit actions (covered by ALLOWED_SETTINGS_ACTIONS below), not explicit
     *   component targets that would require adding com.android.settings here.
     * - Implicit intents (action only) must use an action from the settings action allowlist.
     * - Data URIs, if present, must use the "package:" scheme.
     */
    private fun isAllowed(intent: Intent): Boolean {
        val data = intent.data
        if (data != null && data.scheme != null && data.scheme != "package") return false

        val component = intent.component
        if (component != null) {
            return ALLOWED_OEM_PACKAGES.any { component.packageName.startsWith(it) }
        }

        val action = intent.action ?: return false
        return action in ALLOWED_SETTINGS_ACTIONS
    }

    companion object {
        private const val TAG = "KickRise"
        private const val KEY_REMOTE_ROUTES = "kickrise_remote_routes"
        private const val KEY_REMOTE_ROUTES_TS = "kickrise_remote_routes_ts"
        private const val CACHE_TTL_MS = 24 * 60 * 60 * 1000L  // 24 h

        private val ALLOWED_OEM_PACKAGES = listOf(
            "com.miui.", "com.huawei.", "com.hihonor.", "com.coloros.",
            "com.oppo.", "com.oplus.", "com.vivo.", "com.iqoo.", "com.meizu.",
            "com.oneplus.", "com.realme.", "com.samsung."
        )

        private val ALLOWED_SETTINGS_ACTIONS = setOf(
            "android.settings.action.MANAGE_OVERLAY_PERMISSION",
            "android.settings.APPLICATION_DETAILS_SETTINGS",
            "android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS",
            "android.settings.MANAGE_APP_USE_FULL_SCREEN_INTENT",
            "android.settings.APP_NOTIFICATION_SETTINGS",
            "miui.intent.action.APP_PERM_EDITOR",
            "com.meizu.safe.security.SHOW_APPSEC",
            // OEM background-popup / permission-manager actions (implicit-intent path)
            "com.vivo.permissionmanager.action.PERMISSION_TAB",
            "com.coloros.safecenter.action.PERMISSION_MANAGER",
            "com.huawei.systemmanager.action.PERMISSION_MANAGER"
        )
    }
}
