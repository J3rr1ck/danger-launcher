package com.danger.danger_launcher

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.location.Location
import android.location.LocationManager
import android.os.Bundle
import androidx.core.graphics.drawable.toBitmap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.danger.danger_launcher/launcher"
    private val WEATHER_CHANNEL = "com.danger.danger_launcher/weather"
    private val RSS_CHANNEL = "com.danger.danger_launcher/rss"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        // Launcher channel
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("GET_APPS_FAILED", e.message ?: "Unknown error", null)
                    }
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val success = launchApp(packageName)
                    result.success(success)
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    try {
                        val iconBytes = getAppIcon(packageName)
                        if (iconBytes != null) {
                            result.success(iconBytes)
                        } else {
                            result.error("ICON_NOT_FOUND", "Icon not found for $packageName", null)
                        }
                    } catch (e: Exception) {
                        result.error("ICON_ERROR", e.message ?: "Icon error", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Weather channel
        MethodChannel(engine.dartExecutor.binaryMessenger, WEATHER_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getWeather" -> {
                    try {
                        val weather = getLocalWeather()
                        result.success(weather)
                    } catch (e: Exception) {
                        result.error("WEATHER_FAILED", e.message ?: "Unknown error", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // RSS channel
        MethodChannel(engine.dartExecutor.binaryMessenger, RSS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "fetchRss" -> {
                    val url = call.argument<String>("url") ?: ""
                    try {
                        val rssContent = fetchRss(url)
                        result.success(rssContent)
                    } catch (e: Exception) {
                        result.error("RSS_FAILED", e.message ?: "Unknown error", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val apps = mutableListOf<Map<String, Any>>()
        val pm = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfoList = pm.queryIntentActivities(intent, 0)

        for (resolveInfo in resolveInfoList) {
            val activityInfo = resolveInfo.activityInfo
            val app = mutableMapOf<String, Any>()
            app["packageName"] = activityInfo.packageName
            app["appName"] = pm.getApplicationLabel(activityInfo.applicationInfo).toString()
            app["activityName"] = activityInfo.name
            apps.add(app)
        }

        return apps.sortedBy { it["appName"] as? String }
    }

    private fun launchApp(packageName: String): Boolean {
        return try {
            val intent = pm.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val pm = packageManager
            val icon: Drawable = pm.getApplicationIcon(packageName)
            val bitmap: Bitmap = when (icon) {
                is BitmapDrawable -> icon.bitmap
                else -> icon.toBitmap()
            }
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private fun getLocalWeather(): Map<String, Any> {
        val result = mutableMapOf<String, Any>()
        result["success"] = false

        try {
            val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            val location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

            if (location != null) {
                // In production use OpenWeatherMap API. For MVP use simulated data.
                result["success"] = true
                result["temperature"] = 72
                result["condition"] = "Sunny"
                result["high"] = 78
                result["low"] = 65
                result["city"] = "San Francisco"
            } else {
                // Fallback simulated data
                result["success"] = true
                result["temperature"] = 72
                result["condition"] = "Sunny"
                result["high"] = 78
                result["low"] = 65
                result["city"] = "San Francisco"
            }
        } catch (e: Exception) {
            // Simulated fallback
            result["success"] = true
            result["temperature"] = 72
            result["condition"] = "Sunny"
            result["high"] = 78
            result["low"] = 65
            result["city"] = "San Francisco"
        }

        return result
    }

    private fun fetchRss(url: String): String {
        try {
            val connection = java.net.URL(url).openConnection()
            connection.setRequestProperty("User-Agent", "DangerLauncher/1.0")
            return connection.inputStream.bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            return "<error>${e.message}</error>"
        }
    }

    private val pm: PackageManager
        get() = packageManager
}
