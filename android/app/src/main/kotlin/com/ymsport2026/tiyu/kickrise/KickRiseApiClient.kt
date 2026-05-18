package com.tiyu2.tiyu.kickrise

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.provider.Settings
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale

class KickRiseApiClient(private val context: Context) {

    private val packageName: String = context.packageName
    private val deviceId: String by lazy {
        Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown"
    }
    private val appVersion: String by lazy {
        try {
            context.packageManager.getPackageInfo(packageName, 0).versionName ?: "1.0"
        } catch (e: Exception) {
            "1.0"
        }
    }

    fun fetchPopupConfig(baseUrl: String): PopupConfig? {
        val urlStr = "$baseUrl/plan"
        return try {
            Log.d(TAG, "[API] → GET $urlStr")
            val url = URL(urlStr)
            val conn = (url.openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                connectTimeout = 10_000
                readTimeout = 10_000
                applyDeviceContextHeaders(this)
            }
            val code = conn.responseCode
            if (code != 200) {
                val err = conn.errorStream?.bufferedReader()?.readText() ?: ""
                Log.e(TAG, "[API] ✕ $urlStr — HTTP $code $err")
                conn.disconnect()
                return null
            }
            val body = conn.inputStream.bufferedReader().readText()
            conn.disconnect()
            Log.d(TAG, "[API] ← $code $urlStr")
            Log.d(TAG, "[Raw Response - /config] ← $body")
            parsePopupConfig(JSONObject(body))
        } catch (e: Exception) {
            Log.e(TAG, "[API] ✕ $urlStr — ${e.javaClass.simpleName}: ${e.message}")
            null
        }
    }

    fun postEvents(baseUrl: String, events: List<EventData>): Boolean {
        return try {
            val arr = JSONArray()
            events.forEach { e ->
                arr.put(JSONObject().apply {
                    put("trace_id", e.traceId)
                    put("event_type", e.eventType)
                    e.planId?.let { put("plan_id", it) }
                    e.creativeId?.let { put("creative_id", it) }
                    put("created_at", currentTimestamp())
                })
            }
            val body = JSONObject().put("events", arr).toString()
            post("$baseUrl/events", body, withDeviceContext = true)
        } catch (e: Exception) {
            false
        }
    }

    fun postAudits(baseUrl: String, triggerCount: Int, showCount: Int): Boolean {
        return try {
            val body = JSONObject()
                .put("audits", JSONArray().put(
                    JSONObject().put("trigger_count", triggerCount).put("show_count", showCount)
                )).toString()
            post("$baseUrl/audits", body, withDeviceContext = true)
        } catch (e: Exception) {
            false
        }
    }

    fun postBlocks(baseUrl: String, source: String, reason: String): Boolean {
        return try {
            val body = JSONObject()
                .put("blocks", JSONArray().put(
                    JSONObject().put("source", source).put("reason", reason)
                )).toString()
            post("$baseUrl/blocks", body, withDeviceContext = true)
        } catch (e: Exception) {
            false
        }
    }

    fun postLogs(baseUrl: String, logs: List<LogData>): Boolean {
        return try {
            val arr = JSONArray()
            logs.forEach { l ->
                arr.put(JSONObject().apply {
                    put("level", l.level)
                    put("message", l.message)
                    l.tag?.let { put("tag", it) }
                    l.context?.let { ctx ->
                        put("context", JSONObject().apply { ctx.forEach { (k, v) -> put(k, v) } })
                    }
                    put("created_at", currentTimestamp())
                })
            }
            val body = JSONObject().put("logs", arr).toString()
            post("$baseUrl/logs", body, withDeviceContext = true)
        } catch (e: Exception) {
            false
        }
    }

    fun postHeartbeat(baseUrl: String): Boolean {
        return try {
            post("$baseUrl/devices/heartbeat", "{}", withDeviceContext = true)
        } catch (e: Exception) {
            false
        }
    }

    private fun post(urlStr: String, body: String, withDeviceContext: Boolean): Boolean {
        Log.d(TAG, "[API] → POST $urlStr")
        Log.d(TAG, "[API] → data: $body")
        val url = URL(urlStr)
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            connectTimeout = 10_000
            readTimeout = 10_000
            doOutput = true
            setRequestProperty("Content-Type", "application/json")
            if (withDeviceContext) applyDeviceContextHeaders(this)
        }
        OutputStreamWriter(conn.outputStream).use { it.write(body) }
        val code = conn.responseCode
        conn.disconnect()
        if (code in 200..299) {
            Log.d(TAG, "[API] ← $code $urlStr")
        } else {
            Log.e(TAG, "[API] ✕ $urlStr — HTTP $code")
        }
        return code in 200..299
    }

    private fun applyDeviceContextHeaders(conn: HttpURLConnection) {
        val network = getNetworkType()
        val lang = Locale.getDefault().language
        val region = Locale.getDefault().country
        val romLabel = RomUtils.romLabel()
        Log.d(TAG, "request headers: X-Package-Name=$packageName X-Device-Id=$deviceId X-Device-Brand=${Build.BRAND} X-Device-Model=${Build.MODEL} X-Android-Version=${Build.VERSION.RELEASE} X-Build-Display=${Build.DISPLAY} X-Rom-Label=$romLabel X-Android-Sdk=${Build.VERSION.SDK_INT} X-Network=$network X-Language=$lang X-Region=$region")
        conn.setRequestProperty("X-Package-Name", packageName)
        conn.setRequestProperty("X-Device-Id", deviceId)
        conn.setRequestProperty("X-Device-Brand", Build.BRAND)
        conn.setRequestProperty("X-Device-Model", Build.MODEL)
        conn.setRequestProperty("X-Android-Version", Build.VERSION.RELEASE)
        conn.setRequestProperty("X-Build-Display", Build.DISPLAY)
        conn.setRequestProperty("X-Rom-Label", romLabel)
        conn.setRequestProperty("X-Android-Sdk", Build.VERSION.SDK_INT.toString())
        conn.setRequestProperty("X-Network", network)
        conn.setRequestProperty("X-Language", lang)
        conn.setRequestProperty("X-Region", region)
    }

    private fun getNetworkType(): String {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val caps = cm.getNetworkCapabilities(cm.activeNetwork) ?: return "unknown"
            when {
                caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> "wifi"
                caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> "4g"
                else -> "unknown"
            }
        } else {
            @Suppress("DEPRECATION")
            when (cm.activeNetworkInfo?.type) {
                ConnectivityManager.TYPE_WIFI -> "wifi"
                ConnectivityManager.TYPE_MOBILE -> "4g"
                else -> "unknown"
            }
        }
    }

    private fun parsePopupConfig(json: JSONObject): PopupConfig {
        val triggers = json.optJSONObject("triggers").let {
            PopupTriggers(
                onLock = it?.optBoolean("on_lock", true) ?: true,
                onUnlock = it?.optBoolean("on_unlock", true) ?: true
            )
        }
        val schedule = json.optJSONObject("schedule")?.let {
            PopupSchedule(
                startTime = it.optString("start_time", "00:00"),
                endTime = it.optString("end_time", "23:59")
            )
        }
        val freq = json.optJSONObject("frequency").let {
            PopupFrequency(
                minInterval = it?.optInt("min_interval", 1) ?: 1,
                dailyMax = it?.optInt("daily_max", 5) ?: 5,
                defaultDelayMs = it?.optLong("default_delay_ms", 3000L) ?: 3000L,
                installDelayMinutes = it?.optInt("install_delay_minutes", 0) ?: 0
            )
        }
        val creatives = mutableListOf<PopupCreative>()
        json.optJSONArray("creatives")?.let { arr ->
            for (i in 0 until arr.length()) {
                val c = arr.getJSONObject(i)
                creatives.add(PopupCreative(
                    id = c.optInt("id"),
                    displayId = c.optString("display_id"),
                    name = c.optString("name"),
                    popupHtml = c.optString("popup_html")
                ))
            }
        }
        return PopupConfig(
            planId = json.optInt("plan_id"),
            displayId = json.optString("display_id"),
            name = json.optString("name"),
            enabled = json.optBoolean("enabled", false),
            triggers = triggers,
            schedule = schedule,
            frequency = freq,
            landingPageUrl = json.optString("landing_page_url").takeIf { it.isNotBlank() },
            openHostApp = json.optBoolean("open_host_app", false),
            hostAppPackage = json.optString("host_app_package").takeIf { it.isNotBlank() },
            creatives = creatives
        )
    }

    private fun currentTimestamp(): String {
        val sdf = java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US)
        return sdf.format(java.util.Date())
    }

    companion object {
        private const val TAG = "KickRise"
    }
}
