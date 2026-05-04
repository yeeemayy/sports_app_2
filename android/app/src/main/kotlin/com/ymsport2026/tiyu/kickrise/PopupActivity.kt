package com.ymsport2026.tiyu.kickrise

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
import com.ymsport2026.tiyu.MainActivity

class PopupActivity : android.app.Activity() {

    private lateinit var webView: WebView
    private lateinit var reporter: EventReporter
    private lateinit var repo: PopupConfigRepository
    private val validExposureHandler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyLockScreenFlags()

        val baseUrl = getSharedPreferences(EventReporter.PREFS_NAME, Context.MODE_PRIVATE)
            .getString(ScreenEventReceiver.KEY_BASE_URL, "") ?: ""

        reporter = EventReporter(this, baseUrl)
        repo = PopupConfigRepository(this, baseUrl)

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()
        if (config == null || !config.enabled || creative == null) {
            reporter.reportLog(LogLevel.WARN, "Popup aborted: no valid config or creative", tag = "popup")
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

        repo.incrementDailyCount()
        reporter.incrementShowCount()
        dismissTriggeringNotification()

        setupWebView(creative.popupHtml)
        reporter.reportEvent(EventType.POPUP_OPEN)

        validExposureHandler.postDelayed({
            reporter.reportEvent(EventType.VALID_EXPOSURE)
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
    }

    private fun applyLockScreenFlags() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN)
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

    override fun onDestroy() {
        super.onDestroy()
        validExposureHandler.removeCallbacksAndMessages(null)
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
                val intent = Intent(this@PopupActivity, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
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

}
