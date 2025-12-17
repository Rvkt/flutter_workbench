package com.workbench

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import com.google.android.gms.location.LocationServices
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
            if (call.method == "getDeviceAndAppInfo") {
                getDeviceAndAppInfo(this) { data ->
                    result.success(data)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // ─────────────────────────────────────────────
    // SINGLE NATIVE FUNCTION
    // ─────────────────────────────────────────────
    @SuppressLint("MissingPermission")
    private fun getDeviceAndAppInfo(
        context: Context,
        callback: (Map<String, String>) -> Unit
    ) {
        val data = mutableMapOf<String, String>()

        // ───── App Info ─────
        try {
            val pkgInfo =
                context.packageManager.getPackageInfo(context.packageName, 0)

            val buildNumber = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pkgInfo.longVersionCode.toString()
            } else {
                @Suppress("DEPRECATION")
                pkgInfo.versionCode.toString()
            }

            data["packageId"] = context.packageName
            data["appVersion"] = pkgInfo.versionName ?: "unknown"
            data["buildNumber"] = buildNumber
        } catch (e: Exception) {
            data["packageId"] = "unknown"
            data["appVersion"] = "unknown"
            data["buildNumber"] = "unknown"
        }

        // ───── Device Info ─────
        data["deviceId"] = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        ) ?: "unknown"

        data["deviceModel"] = Build.MODEL ?: "unknown"
        data["deviceManufacturer"] = Build.MANUFACTURER ?: "unknown"
        data["androidVersion"] = Build.VERSION.RELEASE ?: "unknown"
        data["androidSdk"] = Build.VERSION.SDK_INT.toString()

        // ───── Location ─────
        val fusedLocationClient =
            LocationServices.getFusedLocationProviderClient(context)

        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    data["latitude"] = location.latitude.toString()
                    data["longitude"] = location.longitude.toString()
                } else {
                    data["latitude"] = "0.0"
                    data["longitude"] = "0.0"
                }
                callback(data)
            }
            .addOnFailureListener {
                data["latitude"] = "0.0"
                data["longitude"] = "0.0"
                callback(data)
            }
    }
}
