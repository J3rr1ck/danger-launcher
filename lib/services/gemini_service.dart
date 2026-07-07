import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _geminiPackage = 'com.google.android.gemini';
  static const String _geminiActivity = 'com.google.android.gemini.MainActivity';

  /// Launch Gemini AI app directly
  Future<bool> launchGemini() async {
    try {
      await MethodChannel('danger_launcher/gemini').invokeMethod('launchGemini');
      return true;
    } catch (e) {
      debugPrint('Failed to launch Gemini: $e');
      return false;
    }
  }

  /// Quick voice query trigger - opens Gemini with speech input
  Future<bool> triggerVoiceQuery() async {
    try {
      await MethodChannel('danger_launcher/gemini').invokeMethod('voiceQuery');
      return true;
    } catch (e) {
      debugPrint('Failed to trigger voice query: $e');
      return false;
    }
  }

  /// Trigger Gemini with a text prompt
  Future<bool> triggerTextQuery(String query) async {
    try {
      await MethodChannel('danger_launcher/gemini').invokeMethod('textQuery', {
        'query': query,
      });
      return true;
    } catch (e) {
      debugPrint('Failed to trigger text query: $e');
      return false;
    }
  }

  /// Check if Gemini app is installed
  Future<bool> isGeminiInstalled() async {
    try {
      final result = await MethodChannel('danger_launcher/gemini')
          .invokeMethod('isInstalled');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Failed to check Gemini installation: $e');
      return false;
    }
  }

  /// Get trigger preferences
  static Future<Map<String, bool>> getTriggerPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'doubleTapHome': prefs.getBool('gemini_double_tap') ?? true,
      'swipeUp': prefs.getBool('gemini_swipe_up') ?? true,
      'longPressHome': prefs.getBool('gemini_long_press') ?? false,
      'edgeSwipe': prefs.getBool('gemini_edge_swipe') ?? true,
    };
  }

  /// Save trigger preferences
  static Future<void> setTriggerPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gemini_$key', value);
  }
}
