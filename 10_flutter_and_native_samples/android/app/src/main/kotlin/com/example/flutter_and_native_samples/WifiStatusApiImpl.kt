package com.example.flutter_and_native_samples

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager

/**
 * Implements the Pigeon-generated [WifiStatusApi] using Android system services.
 *
 * The WifiStatus type is defined once in the Pigeon schema; this only fills it in.
 */
class WifiStatusApiImpl(context: Context) : WifiStatusApi {
    private val appContext = context.applicationContext

    override fun getWifiStatus(callback: (Result<WifiStatus>) -> Unit) {
        try {
            val wifiManager =
                appContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val connectivityManager =
                appContext.getSystemService(Context.CONNECTIVITY_SERVICE)
                    as ConnectivityManager

            val capabilities =
                connectivityManager.getNetworkCapabilities(
                    connectivityManager.activeNetwork,
                )
            val usesWifi =
                capabilities?.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) == true

            val connectionType =
                when {
                    usesWifi -> WifiConnectionType.WIFI
                    capabilities != null -> WifiConnectionType.OTHER
                    else -> WifiConnectionType.NONE
                }

            callback(
                Result.success(
                    WifiStatus(
                        isEnabled = wifiManager.isWifiEnabled,
                        isConnected = usesWifi,
                        connectionType = connectionType,
                        ssid = null,
                        signalLevel = null,
                    ),
                ),
            )
        } catch (error: Exception) {
            callback(Result.failure(error))
        }
    }
}
