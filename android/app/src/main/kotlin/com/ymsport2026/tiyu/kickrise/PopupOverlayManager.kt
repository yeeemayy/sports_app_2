package com.ymsport2026.tiyu.kickrise

import android.annotation.SuppressLint
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.webkit.JavascriptInterface
import android.webkit.WebView
import android.webkit.WebViewClient
import com.ymsport2026.tiyu.MainActivity
import com.ymsport2026.tiyu.OverlayPermissionCompat

class PopupOverlayManager(private val context: Context) {

    private var overlayView: WebView? = null
    private val handler = Handler(Looper.getMainLooper())
    private val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager

    fun show(onFailure: (() -> Unit)? = null) {
        val baseUrl = EventReporter.getBaseUrl(context)
        val reporter = EventReporter(context, baseUrl)
        val repo = PopupConfigRepository(context, baseUrl)

        val config = repo.getCached()
        val creative = config?.creatives?.firstOrNull()

        if (config == null || !config.enabled || creative == null) {
            reporter.reportLog(LogLevel.WARN, "Overlay aborted: no valid config or creative", tag = "overlay")
            return
        }
        if (repo.isDailyLimitReached(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Overlay blocked: daily limit reached", tag = "overlay",
                context = mapOf("plan_id" to config.planId, "daily_max" to config.frequency.dailyMax))
            reporter.reportAudit()
            return
        }
        if (!repo.isWithinSchedule(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.TIME_WINDOW)
            reporter.reportLog(LogLevel.INFO, "Overlay blocked: outside schedule", tag = "overlay",
                context = mapOf("plan_id" to config.planId))
            reporter.reportAudit()
            return
        }
        if (!repo.isMinIntervalPassedSinceLastShown(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.FREQUENCY)
            reporter.reportLog(LogLevel.INFO, "Overlay blocked: min interval not reached", tag = "overlay",
                context = mapOf("plan_id" to config.planId, "min_interval_min" to config.frequency.minInterval))
            reporter.reportAudit()
            return
        }

        if (!repo.isInstallDelayPassed(config)) {
            reporter.reportBlock(BlockSource.GOD, BlockReason.POLICY)
            reporter.reportLog(LogLevel.INFO, "Overlay blocked: install delay not passed", tag = "overlay",
                context = mapOf("plan_id" to config.planId, "install_delay_min" to config.frequency.installDelayMinutes))
            reporter.reportAudit()
            return
        }

        handler.post { addOverlayView(creative, config, reporter, repo, onFailure) }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun addOverlayView(creative: PopupCreative, config: PopupConfig, reporter: EventReporter, repo: PopupConfigRepository, onFailure: (() -> Unit)? = null) {
        val webView = WebView(context).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            setBackgroundColor(Color.TRANSPARENT)
            webViewClient = WebViewClient()
            addJavascriptInterface(Bridge(reporter, repo), "Android")
        }

        @Suppress("DEPRECATION")
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else
            WindowManager.LayoutParams.TYPE_TOAST

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            type,
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )

        try {
            windowManager.addView(webView, params)
            overlayView = webView
            hideSystemBars(webView)
            webView.loadDataWithBaseURL(null, creative.popupHtml, "text/html", "UTF-8", null)

            repo.incrementDailyCount()
            reporter.incrementShowCount()
            reporter.reportEvent(EventType.POPUP_OPEN, planId = config.planId, creativeId = creative.id)
            reporter.reportLog(LogLevel.INFO, "Overlay shown via WindowManager", tag = "overlay",
                context = mapOf("rom" to RomUtils.romLabel()))
            reporter.reportLog(LogLevel.INFO, "popup_render_success", tag = "funnel",
                context = mapOf("method" to "overlay", "rom" to RomUtils.romLabel(), "sdk" to Build.VERSION.SDK_INT))

            handler.postDelayed({
                reporter.reportEvent(EventType.VALID_EXPOSURE, planId = config.planId, creativeId = creative.id)
            }, config.frequency.defaultDelayMs)
        } catch (e: Exception) {
            val isLocked = (context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager).isKeyguardLocked
            val hasOverlay = OverlayPermissionCompat.canDrawOverlays(context)
            val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                "TYPE_APPLICATION_OVERLAY" else "TYPE_TOAST"
            Log.e(TAG, "WindowManager.addView failed: ${e.message}")
            reporter.reportLog(LogLevel.ERROR, "WindowManager.addView failed", tag = "overlay",
                context = mapOf(
                    "exception" to e.javaClass.simpleName, "message" to (e.message ?: ""),
                    "sdk" to Build.VERSION.SDK_INT, "overlay_permission" to hasOverlay,
                    "locked" to isLocked, "layout_type" to layoutType
                ))
            onFailure?.invoke()
        }
    }

    private fun hideSystemBars(view: View) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            view.windowInsetsController?.let {
                it.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                it.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            view.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            )
        }
    }

    fun dismiss(reporter: EventReporter? = null) {
        handler.post {
            overlayView?.let {
                try { windowManager.removeView(it) } catch (_: Exception) {}
                overlayView = null
                PopupConfigRepository(context, EventReporter.getBaseUrl(context)).recordDismissed()
            }
            reporter?.reportAudit()
        }
    }

    inner class Bridge(private val reporter: EventReporter, private val repo: PopupConfigRepository) {
        @JavascriptInterface
        fun close() {
            reporter.reportEvent(EventType.CLOSE_CLICK)
            dismiss(reporter)
        }

        @JavascriptInterface
        fun openApp() {
            reporter.reportEvent(EventType.TRIAL_CLICK)
            val config = repo.getCached()
            val intent = if (config?.openHostApp == true && !config.hostAppPackage.isNullOrBlank()) {
                context.packageManager.getLaunchIntentForPackage(config.hostAppPackage!!)
                    ?.apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP) }
                    ?: Intent(context, MainActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
            } else {
                Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
            }
            context.startActivity(intent)
            dismiss(reporter)
        }

        @JavascriptInterface
        fun openDetail() {
            val url = repo.getCached()?.landingPageUrl ?: return
            reporter.reportEvent(EventType.DETAIL_OPEN)
            try {
                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            } catch (_: Exception) {}
            dismiss(reporter)
        }

        @JavascriptInterface
        fun openUrl(url: String) {
            val target = url.takeIf { it.isNotBlank() } ?: repo.getCached()?.landingPageUrl ?: return
            reporter.reportEvent(EventType.TRIAL_CLICK)
            try {
                context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(target)).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            } catch (_: Exception) {}
            dismiss(reporter)
        }
    }

    companion object {
        private const val TAG = "KickRise"
    }
}
