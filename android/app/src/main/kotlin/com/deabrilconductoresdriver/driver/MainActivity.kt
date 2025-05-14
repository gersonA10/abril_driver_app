package com.deabrilconductoresdriver.driver

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterFragmentActivity() {
    private val channel = "flutter.app/awake"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            if (call.method == "awakeapp") {
                val isActive = call.argument<Boolean>("isActive") ?: false
                if (isActive) {
                    awakeapp()
                    result.success(null)
                } else {
                    result.error("NOT_ACTIVE", "El conductor no está activo.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun awakeapp() {
        val bringToForegroundIntent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(bringToForegroundIntent)
    }
}
