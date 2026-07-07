import 'dart:typed_data';

/// Represents an installed Android app discovered via PackageManager.
class InstalledApp {
  final String packageName;
  final String appName;
  final String activityName;
  Uint8List? _iconBytes;

  InstalledApp({
    required this.packageName,
    required this.appName,
    required this.activityName,
  });

  Future<Uint8List?> get iconBytes => _iconBytes;

  setIconBytes(Uint8List? bytes) {
    _iconBytes = bytes;
  }

  Map<String, dynamic> toMap() => {
    'packageName': packageName,
    'appName': appName,
    'activityName': activityName,
  };

  factory InstalledApp.fromMap(Map<String, dynamic> map) => InstalledApp(
    packageName: map['packageName'] as String,
    appName: map['appName'] as String,
    activityName: map['activityName'] as String,
  );
}
