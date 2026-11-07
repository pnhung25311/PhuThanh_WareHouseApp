package com.example.phuthanh_warehouseapp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val screenshotStreamChannel = "com.phuthanh.warehouseapp/screenshot_stream"
    private var inForeground = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, screenshotStreamChannel)
            .setStreamHandler(ScreenshotStreamHandler(applicationContext) { inForeground })
    }

    override fun onResume() {
        super.onResume()
        inForeground = true
    }

    override fun onPause() {
        super.onPause()
        inForeground = false
    }
}
