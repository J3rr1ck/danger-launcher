import 'package:flutter/material.dart';
import '../models/app_item.dart';

/// iOS 26 Liquid Glass dock with depth and blur.
class GlassDock extends StatelessWidget {
  final List<AppItem> apps;
  final void Function(AppItem)? onTap;

  const GlassDock({
    super.key,
    required this.apps,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          // Glass reflection highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: apps.map((app) {
          return GestureDetector(
            onTap: () => onTap?.call(app),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    app.color.withOpacity(0.9),
                    app.color.withOpacity(0.7),
                    app.color.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: app.color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Icon(app.icon, color: Colors.white, size: 24),
            ),
          );
        }).toList(),
      ),
    );
  }
}
