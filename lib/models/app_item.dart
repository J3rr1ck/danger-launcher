import 'package:flutter/material.dart';

class AppItem {
  final String name;
  final String packageName;
  final IconData icon;
  final Color color;

  const AppItem({
    required this.name,
    required this.packageName,
    required this.icon,
    this.color = const Color(0xFF6366F1),
  });

  static List<AppItem> getDefaultApps() {
    return [
      AppItem(
        name: 'Phone',
        packageName: 'com.android.dialer',
        icon: Icons.phone_outlined,
        color: const Color(0xFF34C759),
      ),
      AppItem(
        name: 'Messages',
        packageName: 'com.android.messaging',
        icon: Icons.message_outlined,
        color: const Color(0xFF007AFF),
      ),
      AppItem(
        name: 'Camera',
        packageName: 'com.android.camera',
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFFF9500),
      ),
      AppItem(
        name: 'Photos',
        packageName: 'com.android.photos',
        icon: Icons.photo_library_outlined,
        color: const Color(0xFFAF52DE),
      ),
      AppItem(
        name: 'Calendar',
        packageName: 'com.android.calendar',
        icon: Icons.calendar_month_outlined,
        color: const Color(0xFF5856D6),
      ),
      AppItem(
        name: 'Maps',
        packageName: 'com.google.android.apps.maps',
        icon: Icons.map_outlined,
        color: const Color(0xFF34C759),
      ),
      AppItem(
        name: 'Gmail',
        packageName: 'com.google.android.gm',
        icon: Icons.mail_outlined,
        color: const Color(0xFF007AFF),
      ),
      AppItem(
        name: 'Chrome',
        packageName: 'com.android.chrome',
        icon: Icons.language_outlined,
        color: const Color(0xFF5856D6),
      ),
      AppItem(
        name: 'YouTube',
        packageName: 'com.google.android.youtube',
        icon: Icons.play_circle_outlined,
        color: const Color(0xFFFF3B30),
      ),
      AppItem(
        name: 'Clock',
        packageName: 'com.google.android.clock',
        icon: Icons.alarm_outlined,
        color: const Color(0xFF6366F1),
      ),
      AppItem(
        name: 'Settings',
        packageName: 'com.android.settings',
        icon: Icons.settings_outlined,
        color: const Color(0xFF8E8E93),
      ),
      AppItem(
        name: 'Gemini',
        packageName: 'com.google.android.gemini',
        icon: Icons.auto_awesome_outlined,
        color: const Color(0xFF818CF8),
      ),
    ];
  }
}
