package com.danger.launcher

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent

/**
 * Background service for Gemini AI triggers.
 * Listens for specific gesture patterns and launches Gemini.
 */
class GeminiTriggerService : AccessibilityService() {
    companion object {
        private const val TAG = "GeminiTriggerService"
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_GESTURE_COMPLETED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REQUEST_TOUCH_EXPLORATION_MODE
        }
        setServiceInfo(info)
        Log.i(TAG, "Gemini trigger service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        when (event?.eventType) {
            AccessibilityEvent.TYPE_GESTURE_COMPLETED -> {
                // Handle double-tap or swipe gestures for Gemini trigger
                Log.d(TAG, "Gesture detected - checking Gemini trigger")
            }
        }
    }

    override fun onInterrupt() {
        Log.w(TAG, "Gemini trigger service interrupted")
    }

    /**
     * Launch Gemini from a trigger event
     */
    private fun triggerGemini() {
        try {
            val intent = packageManager.getLaunchIntentForPackage("com.google.android.gemini")
            if (intent != null) {
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
            } else {
                // Fallback to voice command
                val voiceIntent = Intent(Intent.ACTION_VOICE_COMMAND)
                    .setFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(voiceIntent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to trigger Gemini: ${e.message}")
        }
    }
}
