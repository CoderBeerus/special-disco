package com.aniweb.app

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "aniweb/display_mode"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPreferredRefreshRate" -> {
                        val refresh = window.windowManager.defaultDisplay?.refreshRate ?: 60f
                        result.success(refresh.toDouble())
                    }
                    "requestHighRefreshIfSupported" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            window.attributes = window.attributes.apply {
                                preferredRefreshRate = 120f
                            }
                        } else {
                            @Suppress("DEPRECATION")
                            window.addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setDecorFitsSystemWindows(false)
    }
}
