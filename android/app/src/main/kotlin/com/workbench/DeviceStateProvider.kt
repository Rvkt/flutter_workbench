package com.workbench

import android.annotation.SuppressLint
import android.content.Context
import android.location.Location
import android.os.Build
import android.provider.Settings
import android.util.Log
import com.google.android.gms.location.LocationServices

object DeviceStateProvider {

    private const val TAG = "DeviceStateProvider"

    /**
     * Fetch device + app + location info
     */
    @SuppressLint("MissingPermission")
    fun getDeviceAndAppInfo(
        context: Context,
        callback: (Map<String, String>) -> Unit
    ) {
        val data = mutableMapOf<String, String>()

        // ───── App Info ─────
        try {
            val pkgInfo =
                context.packageManager.getPackageInfo(context.packageName, 0)

            val buildNumber =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
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

        // ───── Location Info ─────
        val fusedLocationClient =
            LocationServices.getFusedLocationProviderClient(context)

        fusedLocationClient.lastLocation
            .addOnSuccessListener { location: Location? ->
                if (location != null) {
                    data["latitude"] = location.latitude.toString()
                    data["longitude"] = location.longitude.toString()
                } else {
                    setDefaultLocation(data)
                }

                logData(data)
                callback(data)
            }
            .addOnFailureListener { e ->
                setDefaultLocation(data)

                Log.e(TAG, "Location fetch failed", e)
                logData(data)

                callback(data)
            }
    }

    private fun setDefaultLocation(data: MutableMap<String, String>) {
        data["latitude"] = "0.0"
        data["longitude"] = "0.0"
    }

    private fun logData(data: Map<String, String>) {
        Log.d(TAG, "──────── Device & App Info ────────")
        data.forEach { (key, value) ->
            Log.d(TAG, "$key : $value")
        }
        Log.d(TAG, "──────────────────────────────────")
    }
}
