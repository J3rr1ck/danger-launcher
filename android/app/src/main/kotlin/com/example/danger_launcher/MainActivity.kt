package com.example.danger_launcher

import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "DangerLauncher"
        private const val GEMINI_CHANNEL = "danger_launcher/gemini"
        private const val APP_LAUNCH_CHANNEL = "danger_launcher/apps"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupGeminiChannel(flutterEngine)
        setupAppLaunchChannel(flutterEngine)
    }

    private fun setupGeminiChannel(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            GEMINI_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchGemini" -> launchGeminiApp(result)
                "voiceQuery" -> triggerGeminiVoiceQuery(result)
                "textQuery" -> {
                    val query = call.argument<String>("query") ?: ""
                    triggerGeminiTextQuery(query, result)
                }
                "isInstalled" -> checkGeminiInstalled(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun setupAppLaunchChannel(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            APP_LAUNCH_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "openApp" -> {
                    val packageName = call.argument<String>("package") ?: ""
                    openApp(packageName, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun launchGeminiApp(result: MethodChannel.Result) {
        try {
            val intent = packageManager.getLaunchIntentForPackage("com.google.android.gemini")
            if (intent != null) {
                startActivity(intent)
                result.success(true)
            } else {
                val assistantIntent = Intent(Intent.ACTION_VOICE_COMMAND)
                    .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(assistantIntent)
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch Gemini: ${e.message}")
            result.error("LAUNCH_ERROR", e.message, null)
        }
    }

    private fun triggerGeminiVoiceQuery(result: MethodChannel.Result) {
        try {
            val intent = packageManager.getLaunchIntentForPackage("com.google.android.gemini")
            if (intent != null) {
                intent.action = "android.intent.action.VOICE_COMMAND"
                intent.putExtra("android.intent.extra.VOICE_QUERY", true)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
                startActivity(intent)
                result.success(true)
            } else {
                val voiceIntent = Intent(Intent.ACTION_VOICE_COMMAND)
                    .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(voiceIntent)
                result.success(true)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Voice query trigger failed: ${e.message}")
            result.error("VOICE_ERROR", e.message, null)
        }
    }

    private fun triggerGeminiTextQuery(query: String, result: MethodChannel.Result) {
        try {
            val intent = Intent()
            intent.setPackage("com.google.android.gemini")
            intent.action = Intent.ACTION_SEND
            intent.type = "text/plain"
            intent.putExtra(Intent.EXTRA_TEXT, query)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Text query trigger failed: ${e.message}")
            result.error("TEXT_ERROR", e.message, null)
        }
    }

    private fun checkGeminiInstalled(result: MethodChannel.Result) {
        try {
            val installed = try {
                packageManager.getPackageInfo("com.google.android.gemini", 0)
                true
            } catch (e: PackageManager.NameNotFoundException) {
                false
            }
            result.success(installed)
        } catch (e: Exception) {
            result.error("CHECK_ERROR", e.message, null)
        }
    }

    private fun openApp(packageName: String, result: MethodChannel.Result) {
        try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
                result.success(true)
            } else {
                result.error("APP_NOT_FOUND", "Package $packageName not found", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open app: ${e.message}")
            result.error("OPEN_ERROR", e.message, null)
        }
    }
}
