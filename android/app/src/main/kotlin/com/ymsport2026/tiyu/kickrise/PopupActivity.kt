package com.tiyu2.tiyu.kickrise

import android.annotation.SuppressLint
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.WindowManager
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import com.tiyu2.tiyu.MainActivity

class PopupActivity : android.app.Activity() {

    private lateinit var webView: WebView
    private lateinit var reporter: EventReporter
    private lateinit var repo: PopupConfigRepository
    private val validExposureHandler = Handler(Looper.getMainLooper())
    private var wasShown = false
    private var launchRoute = "unknown"
    private var launchSource = "unknown"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyLockScreenFlags()
        launchRoute = intent.getStringExtra(EXTRA_LAUNCH_ROUTE) ?: "unknown"
        launchSource = intent.getStringExtra(EXTRA_LAUNCH_SOURCE) ?: "unknown"

        val baseUrl = EventReporter.getBaseUrl(this)

        reporter = EventReporter(this, baseUrl)
        repo = PopupConfigRepository(this, baseUrl)

        reporter.reportLog(LogLevel.INFO, "PopupActivity created", tag = "popup",
            context = mapOf("rom" to RomUtils.romLabel(), "sdk" to android.os.Build.VERSION.SDK_INT,
                "domestic" to RomUtils.isAggressiveOemRom(), "launch_route" to launchRoute,
                "launch_source" to launchSource))

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()
        if (config == null || !config.enabled || creative == null) {
            val abortReason = when {
                config == null -> "config_missing"
                !config.enabled -> "config_disabled"
                else -> "creative_missing"
            }
            reporter.reportLog(LogLevel.WARN, "Popup aborted: no valid config or creative", tag = "popup",
                context = mapOf("reason" to abortReason))
            finish()
            return
        }

        if (repo.isDailyLimitReached(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: daily limit reached", tag = "popup",
                context = mapOf("plan_id" to config.planId, "daily_max" to config.frequency.dailyMax))
            reporter.reportAudit()
            finish()
            return
        }

        if (!repo.isWithinSchedule(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.TIME_WINDOW)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: outside schedule", tag = "popup",
                context = mapOf("plan_id" to config.planId))
            reporter.reportAudit()
            finish()
            return
        }

        if (!repo.isMinIntervalPassedSinceLastShown(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: min interval not reached", tag = "popup",
                context = mapOf("plan_id" to config.planId, "min_interval_min" to config.frequency.minInterval))
            reporter.reportAudit()
            finish()
            return
        }

        if (!repo.isInstallDelayPassed(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.POLICY)
            reporter.reportLog(LogLevel.INFO, "Popup blocked: install delay not passed", tag = "popup",
                context = mapOf("plan_id" to config.planId, "install_delay_min" to config.frequency.installDelayMinutes))
            reporter.reportAudit()
            finish()
            return
        }

        repo.incrementDailyCount()
        reporter.incrementShowCount()
        dismissTriggeringNotification()

        wasShown = true
        setupWebView(creative.popupHtml)
        reporter.reportEvent(EventType.POPUP_OPEN, planId = config.planId, creativeId = creative.id)

        validExposureHandler.postDelayed({
            reporter.reportEvent(EventType.VALID_EXPOSURE, planId = config.planId, creativeId = creative.id)
        }, config.frequency.defaultDelayMs)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setupWebView(html: String) {
        webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            setBackgroundColor(android.graphics.Color.TRANSPARENT)
            webViewClient = WebViewClient()
            addJavascriptInterface(AndroidBridge(), "Android")
        }
        setContentView(webView)
        webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null)
        reporter.reportLog(LogLevel.INFO, "popup_render_success", tag = "popup",
            context = mapOf("method" to "activity", "rom" to RomUtils.romLabel(), "sdk" to android.os.Build.VERSION.SDK_INT))
    }

    private fun applyLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
            // Honor/OPPO/MIUI MagicUI ignores setShowWhenLocked API — add window flags as fallback
            if (RomUtils.isAggressiveOemRom()) {
                @Suppress("DEPRECATION")
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                )
            }
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_FULLSCREEN
            )
        }
    }

    private fun dismissTriggeringNotification() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(PopupAlarmReceiver.POPUP_NOTIFICATION_ID)
    }

    override fun onStart() {
        super.onStart()
        if (::reporter.isInitialized) {
            reporter.reportLog(LogLevel.INFO, "popup_activity_lifecycle", tag = "popup",
                context = mapOf("event" to "started", "was_shown" to wasShown,
                    "launch_route" to launchRoute, "launch_source" to launchSource))
        }
    }

    override fun onResume() {
        super.onResume()
        if (::reporter.isInitialized) {
            reporter.reportLog(LogLevel.INFO, "popup_activity_lifecycle", tag = "popup",
                context = mapOf("event" to "resumed", "was_shown" to wasShown,
                    "launch_route" to launchRoute, "launch_source" to launchSource))
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        validExposureHandler.removeCallbacksAndMessages(null)
        if (::reporter.isInitialized) {
            reporter.reportLog(LogLevel.INFO, "popup_activity_lifecycle", tag = "popup",
                context = mapOf("event" to "destroyed", "was_shown" to wasShown,
                    "launch_route" to launchRoute, "launch_source" to launchSource))
        }
        if (wasShown) repo.recordDismissed()
        reporter.reportAudit()
    }

    inner class AndroidBridge {
        @JavascriptInterface
        fun close() {
            reporter.reportEvent(EventType.CLOSE_CLICK)
            runOnUiThread { finish() }
        }

        @JavascriptInterface
        fun openApp() {
            reporter.reportEvent(EventType.TRIAL_CLICK)
            runOnUiThread {
                val config = repo.getCached()
                val intent = if (config?.openHostApp == true && !config.hostAppPackage.isNullOrBlank()) {
                    packageManager.getLaunchIntentForPackage(config.hostAppPackage!!)
                        ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) }
                        ?: Intent(this@PopupActivity, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                        }
                } else {
                    Intent(this@PopupActivity, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                }
                startActivity(intent)
                finish()
            }
        }

        @JavascriptInterface
        fun openDetail() {
            val url = repo.getCached()?.landingPageUrl ?: return
            reporter.reportEvent(EventType.DETAIL_OPEN)
            runOnUiThread {
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                } catch (e: Exception) { /* no browser */ }
                finish()
            }
        }

        @JavascriptInterface
        fun openUrl(url: String) {
            val target = url.takeIf { it.isNotBlank() } ?: repo.getCached()?.landingPageUrl ?: return
            reporter.reportEvent(EventType.TRIAL_CLICK)
            runOnUiThread {
                try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(target)))
                } catch (e: Exception) { /* no browser */ }
                finish()
            }
        }
    }

    companion object {
        const val EXTRA_LAUNCH_ROUTE = "kickrise_launch_route"
        const val EXTRA_LAUNCH_SOURCE = "kickrise_launch_source"
    }
}
