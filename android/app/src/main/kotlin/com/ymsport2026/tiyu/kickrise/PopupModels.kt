package com.ymsport2026.tiyu.kickrise

data class PopupConfig(
    val planId: Int,
    val displayId: String,
    val name: String,
    val enabled: Boolean,
    val triggers: PopupTriggers,
    val schedule: PopupSchedule?,
    val frequency: PopupFrequency,
    val landingPageUrl: String?,
    val openHostApp: Boolean,
    val hostAppPackage: String?,
    val creatives: List<PopupCreative>
)

data class PopupTriggers(val onLock: Boolean, val onUnlock: Boolean)

data class PopupSchedule(val startTime: String, val endTime: String)

data class PopupFrequency(val minInterval: Int, val dailyMax: Int, val defaultDelayMs: Long, val installDelayMinutes: Int = 0)

data class PopupCreative(val id: Int, val displayId: String, val name: String, val popupHtml: String)

data class EventData(
    val traceId: String,
    val eventType: String,
    val planId: Int? = null,
    val creativeId: Int? = null
)

object EventType {
    const val POPUP_OPEN = "popup_open"
    const val VALID_EXPOSURE = "valid_exposure"
    const val DETAIL_OPEN = "detail_open"
    const val TRIAL_CLICK = "trial_click"
    const val CLOSE_CLICK = "close_click"
}

object BlockSource {
    const val BOOTSTRAP = "bootstrap"
    const val GOD = "god"
}

object BlockReason {
    const val FREQUENCY = "频控触发"
    const val POLICY = "基础策略拦截"
    const val TIME_WINDOW = "时间窗不命中"
}

data class LogData(
    val level: String,
    val message: String,
    val tag: String? = null,
    val context: Map<String, Any>? = null
)

object LogLevel {
    const val DEBUG = "debug"
    const val INFO = "info"
    const val WARN = "warn"
    const val ERROR = "error"
}

object AlarmSource {
    const val SCREEN_OFF = "screen_off"
    const val FALLBACK_ACTIVITY = "fallback_activity"
    const val UNLOCK_RECEIVER = "unlock_receiver"
}
