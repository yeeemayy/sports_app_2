package com.ymsport2026.tiyu.kickrise

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import java.util.UUID
import java.util.concurrent.Executors

class EventReporter(context: Context, private val baseUrl: String) {

    private val api = KickRiseApiClient(context)
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val executor = Executors.newSingleThreadExecutor()

    fun reportEvent(eventType: String, planId: Int? = null, creativeId: Int? = null) {
        val event = EventData(
            traceId = UUID.randomUUID().toString(),
            eventType = eventType,
            planId = planId,
            creativeId = creativeId
        )
        executor.submit { api.postEvents(baseUrl, listOf(event)) }
    }

    fun reportLog(level: String, message: String, tag: String? = null, context: Map<String, Any>? = null) {
        val logTag = "KickRise${if (tag != null) "/$tag" else ""}"
        val fullMessage = if (context != null) "$message $context" else message
        when (level) {
            LogLevel.ERROR -> Log.e(logTag, fullMessage)
            LogLevel.WARN -> Log.w(logTag, fullMessage)
            LogLevel.DEBUG -> Log.d(logTag, fullMessage)
            else -> Log.i(logTag, fullMessage)
        }
        if (level == LogLevel.ERROR) {
            val log = LogData(level = level, message = message, tag = tag, context = context)
            executor.submit { api.postLogs(baseUrl, listOf(log)) }
        }
    }

    fun reportBlock(source: String, reason: String) {
        incrementTriggerCount()
        executor.submit { api.postBlocks(baseUrl, source, reason) }
    }

    fun reportAudit() {
        val triggerCount = prefs.getInt(KEY_TRIGGER_COUNT, 0)
        val showCount = prefs.getInt(KEY_SHOW_COUNT, 0)
        executor.submit { api.postAudits(baseUrl, triggerCount, showCount) }
    }

    fun incrementTriggerCount() {
        val current = prefs.getInt(KEY_TRIGGER_COUNT, 0)
        prefs.edit().putInt(KEY_TRIGGER_COUNT, current + 1).apply()
    }

    fun incrementShowCount() {
        val current = prefs.getInt(KEY_SHOW_COUNT, 0)
        prefs.edit().putInt(KEY_SHOW_COUNT, current + 1).apply()
    }

    fun resetCounts() {
        prefs.edit()
            .putInt(KEY_TRIGGER_COUNT, 0)
            .putInt(KEY_SHOW_COUNT, 0)
            .apply()
    }

    companion object {
        const val PREFS_NAME = "kickrise_prefs"
        private const val KEY_TRIGGER_COUNT = "kickrise_trigger_count"
        private const val KEY_SHOW_COUNT = "kickrise_show_count"
    }
}
