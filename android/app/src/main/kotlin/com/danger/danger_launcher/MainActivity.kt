package com.danger.danger_launcher

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import androidx.core.graphics.drawable.toBitmap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.danger.danger_launcher/launcher"

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val success = launchApp(packageName)
                    result.success(success)
                }
                "getAppIcon" -> {
                    val packageName = call.argument<String>("packageName") ?: ""
                    val iconBytes = getAppIcon(packageName)
                    if (iconBytes != null) {
                        result.success(iconBytes)
                    } else {
                        result.error("ICON_NOT_FOUND", "Icon not found for $packageName", null)
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

        return apps.sortedBy { it["appName"] }
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
            val icon: Drawable?
            try {
                icon = pm.getApplicationIcon(packageName)
            } catch (e: Exception) {
                return null
            }
            val bitmap = (icon as? BitmapDrawable)?.bitmap ?: icon.toBitmap()
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }

    private val pm: PackageManager
        get() = packageManager
}
