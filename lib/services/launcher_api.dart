import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/installed_app.dart';

/// Platform channel bridge to Android's PackageManager.
class LauncherApi {
  static const MethodChannel _channel = MethodChannel(
    'com.danger.danger_launcher/launcher',
  );

  /// Fetch all installed apps with launcher activities.
  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      return result.map((e) => InstalledApp.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('getInstalledApps error: $e');
      return [];
    }
  }

  /// Launch an app by its package name.
  Future<bool> launchApp(String packageName) async {
    try {
      return await _channel.invokeMethod<bool>('launchApp', {
        'packageName': packageName,
      }) ?? false;
    } catch (e) {
      debugPrint('launchApp error: $e');
      return false;
    }
  }

  /// Get app icon as PNG bytes.
  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final Uint8List? bytes = await _channel.invokeMethod<Uint8List>('getAppIcon', {
        'packageName': packageName,
      });
      return bytes;
    } catch (e) {
      debugPrint('getAppIcon error: $e');
      return null;
    }
  }
}
