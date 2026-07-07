import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/installed_app.dart';

class GlassAppIcon extends StatefulWidget {
  final InstalledApp app;
  final VoidCallback? onTap;
  final double size;

  const GlassAppIcon({
    super.key,
    required this.app,
    this.onTap,
    this.size = 64,
  });

  @override
  State<GlassAppIcon> createState() => _GlassAppIconState();
}

class _GlassAppIconState extends State<GlassAppIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  bool _pressed = false;
  Image? _iconImage;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadIcon();
  }

  Future<void> _loadIcon() async {
    try {
      final channel = MethodChannel(
        'com.danger.danger_launcher/launcher',
      );
      final Uint8List? bytes = await channel.invokeMethod<Uint8List>(
        'getAppIcon',
        {'packageName': widget.app.packageName},
      );
      if (bytes != null && mounted) {
        setState(() {
          _iconImage = Image.memory(bytes, fit: BoxFit.contain);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glow = _glowController.value;
          final size = widget.size;
          final iconSize = size * 0.5;
          return AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.27),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8B5CF6).withOpacity(0.85),
                    const Color(0xFF6C63FF).withOpacity(0.65),
                    const Color(0xFF5B47FF).withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3 * glow),
                    blurRadius: 16 * (0.5 + glow * 0.5),
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15 * glow),
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: const Offset(-2, -2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App icon or fallback
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: _iconImage ?? Icon(
                        Icons.app_box_outlined,
                        color: Colors.white.withOpacity(0.7),
                        size: iconSize * 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.app.appName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
