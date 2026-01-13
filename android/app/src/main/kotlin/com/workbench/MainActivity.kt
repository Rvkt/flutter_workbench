package com.workbench

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "device_info_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceAndAppInfo" -> {
                    DeviceInfoService.getDeviceAndAppInfo(this) { data ->
                        result.success(data)
                    }
                }
                "getSimInfo" -> {
                    SimEnvironmentService.getSimEnvironmentInfo(this) { data ->
                        result.success(data)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

