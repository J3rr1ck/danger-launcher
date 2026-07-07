import 'package:flutter/material.dart';

/// Shared AppItem model used across launcher components.
class AppItem {
  final String name;
  final IconData icon;
  final Color color;

  AppItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}
