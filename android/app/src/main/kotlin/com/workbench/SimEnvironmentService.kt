package com.workbench

import android.content.Context
import android.os.Build
import android.provider.Settings
import android.telephony.TelephonyManager
import android.util.Log

object SimEnvironmentService {

    /// Used to detect SIM operator and SIM environment for fraud prevention.
    /// We do not access phone number, call logs, or messages.

    private const val TAG = "SimEnvironmentService"

    fun getSimEnvironmentInfo(
        context: Context,
        callback: (Map<String, String>) -> Unit
    ) {
        val data = mutableMapOf<String, String>()

        // ─────────────────────────────────────────────
        // ANDROID_ID (Always allowed)
        // ─────────────────────────────────────────────
        data["androidId"] = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        ) ?: "unknown"

        try {
            val telephonyManager =
                context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

            // ─────────────────────────────────────────────
            // SIM Operator (MCC + MNC)
            // ─────────────────────────────────────────────
            data["simOperator"] =
                telephonyManager.simOperator?.takeIf { it.isNotBlank() } ?: "unknown"

            // ─────────────────────────────────────────────
            // SIM Country ISO
            // ─────────────────────────────────────────────
            data["simCountryIso"] =
                telephonyManager.simCountryIso?.takeIf { it.isNotBlank() } ?: "unknown"

            // ─────────────────────────────────────────────
            // SIM SLOT COUNT (SAFE API)
            // ─────────────────────────────────────────────
            data["simSlotCount"] =
                try {
                    telephonyManager.phoneCount.toString()
                } catch (e: Exception) {
                    "1" // Safe fallback
                }

        } catch (e: SecurityException) {
            Log.e(TAG, "SIM access restricted by OS", e)
            data["simOperator"] = "unknown"
            data["simCountryIso"] = "unknown"
            data["simSlotCount"] = "unknown"

        } catch (e: Exception) {
            Log.e(TAG, "Failed to read SIM environment", e)
            data["simOperator"] = "unknown"
            data["simCountryIso"] = "unknown"
            data["simSlotCount"] = "unknown"
        }

        logData(data)
        callback(data)
    }

    private fun logData(data: Map<String, String>) {
        Log.d(TAG, "──── SIM ENVIRONMENT INFO ────")
        data.forEach { (key, value) ->
            Log.d(TAG, "$key : $value")
        }
        Log.d(TAG, "─────────────────────────────")
    }
}
