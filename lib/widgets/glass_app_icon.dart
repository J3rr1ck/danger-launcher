import 'package:flutter/material.dart';
import '../models/app_item.dart';

/// Liquid Glass layered app icon widget.
/// iOS 26 style: multi-layer depth, glass refraction, light interaction.
class GlassAppIcon extends StatefulWidget {
  final AppItem app;
  final VoidCallback? onTap;

  const GlassAppIcon({
    super.key,
    required this.app,
    this.onTap,
  });

  @override
  State<GlassAppIcon> createState() => _GlassAppIconState();
}

class _GlassAppIconState extends State<GlassAppIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
          return AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.app.color.withOpacity(0.85),
                    widget.app.color.withOpacity(0.65),
                    widget.app.color.withOpacity(0.5),
                  ],
                ),
                boxShadow: [
                  // Liquid Glass depth shadow
                  BoxShadow(
                    color: widget.app.color.withOpacity(0.3 * glow),
                    blurRadius: 16 * (0.5 + glow * 0.5),
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  // Inner glass reflection
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
                  // Layered icon with depth effect
                  Stack(
                    children: [
                      // Back layer (glass refraction)
                      Opacity(
                        opacity: 0.3,
                        child: Icon(widget.app.icon,
                            size: 28,
                            color: Colors.white.withOpacity(0.5)),
                      ),
                      // Front layer
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 1, top: 1),
                        child: Icon(widget.app.icon,
                            size: 28, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Name label with iOS style
                  Text(
                    widget.app.name,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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
