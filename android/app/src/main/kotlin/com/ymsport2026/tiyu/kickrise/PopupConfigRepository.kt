package com.ymsport2026.tiyu.kickrise

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.concurrent.Executors

class PopupConfigRepository(private val context: Context, private val baseUrl: String) {

    private val api = KickRiseApiClient(context)
    private val prefs: SharedPreferences = context.getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
    private val executor = Executors.newSingleThreadExecutor()

    fun fetchAndCache(onResult: (PopupConfig?) -> Unit) {
        executor.submit {
            val config = api.fetchPopupConfig(baseUrl)
            if (config != null) saveToPrefs(config)
            onResult(config)
        }
    }

    fun getCached(): PopupConfig? {
        val json = prefs.getString(KEY_CONFIG_JSON, null) ?: return null
        return try {
            parseFromJson(JSONObject(json))
        } catch (e: Exception) {
            null
        }
    }

    fun isWithinSchedule(config: PopupConfig): Boolean {
        val schedule = config.schedule ?: return true
        return try {
            val fmt = SimpleDateFormat("HH:mm", Locale.US)
            val now = fmt.format(Date())
            if (schedule.startTime <= schedule.endTime) {
                now >= schedule.startTime && now <= schedule.endTime
            } else {
                // overnight window e.g. 22:00–09:00
                now >= schedule.startTime || now <= schedule.endTime
            }
        } catch (e: Exception) {
            true
        }
    }

    fun isInstallDelayPassed(config: PopupConfig): Boolean {
        if (config.frequency.installDelayMinutes <= 0) return true
        val firstInstallTime = try {
            context.packageManager.getPackageInfo(context.packageName, 0).firstInstallTime
        } catch (e: Exception) {
            return true  // can't determine install time — allow through
        }
        val elapsedMinutes = (System.currentTimeMillis() - firstInstallTime) / 60_000L
        return elapsedMinutes >= config.frequency.installDelayMinutes
    }

    fun isDailyLimitReached(config: PopupConfig): Boolean {
        val todayKey = SimpleDateFormat("yyyyMMdd", Locale.US).format(Date())
        val storedDate = prefs.getString(KEY_DAILY_DATE, null)
        if (storedDate != todayKey) {
            prefs.edit().putString(KEY_DAILY_DATE, todayKey).putInt(KEY_DAILY_COUNT, 0).apply()
            return false
        }
        return prefs.getInt(KEY_DAILY_COUNT, 0) >= config.frequency.dailyMax
    }

    fun isMinIntervalPassed(config: PopupConfig): Boolean {
        val lastShownMs = prefs.getLong(KEY_LAST_SHOWN_MS, 0L)
        if (lastShownMs == 0L) return true
        val elapsedMinutes = (System.currentTimeMillis() - lastShownMs) / 60_000L
        return elapsedMinutes >= config.frequency.minInterval
    }

    fun isMinIntervalPassedSinceLastShown(config: PopupConfig): Boolean {
        val lastShownMs = prefs.getLong(KEY_LAST_SHOWN_MS, 0L)
        val lastDismissedMs = prefs.getLong(KEY_LAST_DISMISSED_MS, 0L)
        val lastMs = maxOf(lastShownMs, lastDismissedMs)
        if (lastMs == 0L) return true
        val elapsedMinutes = (System.currentTimeMillis() - lastMs) / 60_000L
        return elapsedMinutes >= config.frequency.minInterval
    }

    fun recordDismissed() {
        prefs.edit().putLong(KEY_LAST_DISMISSED_MS, System.currentTimeMillis()).apply()
    }

    fun recordScheduled() {
        prefs.edit().putLong(KEY_LAST_SCHEDULED_MS, System.currentTimeMillis()).apply()
    }

    fun incrementDailyCount() {
        val current = prefs.getInt(KEY_DAILY_COUNT, 0)
        prefs.edit()
            .putInt(KEY_DAILY_COUNT, current + 1)
            .putLong(KEY_LAST_SHOWN_MS, System.currentTimeMillis())
            .apply()
    }

    private fun saveToPrefs(config: PopupConfig) {
        val json = JSONObject().apply {
            put("plan_id", config.planId)
            put("display_id", config.displayId)
            put("name", config.name)
            put("enabled", config.enabled)
            put("triggers", JSONObject().put("on_lock", config.triggers.onLock).put("on_unlock", config.triggers.onUnlock))
            config.schedule?.let {
                put("schedule", JSONObject().put("start_time", it.startTime).put("end_time", it.endTime))
            }
            put("frequency", JSONObject()
                .put("min_interval", config.frequency.minInterval)
                .put("daily_max", config.frequency.dailyMax)
                .put("default_delay_ms", config.frequency.defaultDelayMs)
                .put("install_delay_minutes", config.frequency.installDelayMinutes))
            config.landingPageUrl?.let { put("landing_page_url", it) }
            put("open_host_app", config.openHostApp)
            config.hostAppPackage?.let { put("host_app_package", it) }
            val creativesArr = JSONArray()
            config.creatives.forEach { c ->
                creativesArr.put(JSONObject()
                    .put("id", c.id)
                    .put("display_id", c.displayId)
                    .put("name", c.name)
                    .put("popup_html", c.popupHtml))
            }
            put("creatives", creativesArr)
        }
        prefs.edit().putString(KEY_CONFIG_JSON, json.toString()).apply()
    }

    private fun parseFromJson(json: JSONObject): PopupConfig {
        val triggers = json.optJSONObject("triggers").let {
            PopupTriggers(
                onLock = it?.optBoolean("on_lock") ?: false,
                onUnlock = it?.optBoolean("on_unlock") ?: true
            )
        }
        val schedule = json.optJSONObject("schedule")?.let {
            PopupSchedule(startTime = it.optString("start_time", "00:00"), endTime = it.optString("end_time", "23:59"))
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

    companion object {
        private const val KEY_CONFIG_JSON = "kickrise_popup_config_json"
        private const val KEY_DAILY_DATE = "kickrise_daily_date"
        private const val KEY_DAILY_COUNT = "kickrise_daily_count"
        private const val KEY_LAST_SHOWN_MS = "kickrise_last_shown_ms"
        private const val KEY_LAST_DISMISSED_MS = "kickrise_last_dismissed_ms"
        private const val KEY_LAST_SCHEDULED_MS = "kickrise_last_scheduled_ms"
    }
}
