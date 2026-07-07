import 'dart:math';
import 'package:flutter/material.dart';

/// iOS 26 Liquid Glass inspired widget
/// Combines optical qualities of glass with fluid, responsive behavior.
/// UI components refract content from below, reflect ambient light,
/// and respond dynamically with subtle animations and depth effects.
class LiquidGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final Color? tintColor;
  final BorderRadiusGeometry? borderRadius;
  final List<BoxShadow>? shadows;
  final bool isActive;

  const LiquidGlassButton({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.tintColor,
    this.borderRadius,
    this.shadows,
    this.isActive = false,
  });

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  double _scale = 1.0;
  double _opacity = 1.0;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(min: 0.3, max: 0.6);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _scale = 0.96;
      _opacity = 0.85;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
      _scale = 1.0;
      _opacity = 1.0;
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
      _scale = 1.0;
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tint = widget.tintColor ?? (isDark ? Colors.white : Colors.black);

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 150),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        child: Container(
          margin: widget.margin,
          padding: widget.padding ?? const EdgeInsets.all(16),
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
            // Liquid Glass: refract content from below with blur
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint.withOpacity(widget.isActive ? 0.35 : 0.12),
                tint.withOpacity(widget.isActive ? 0.25 : 0.06),
                tint.withOpacity(widget.isActive ? 0.15 : 0.04),
              ],
            ),
            border: Border.all(
              width: 1.2,
              color: tint.withOpacity(widget.isActive ? 0.5 : 0.18),
            ),
            boxShadow: [
              // Liquid Glass: reflect ambient light
              BoxShadow(
                color: tint.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              // Inner glow for depth
              BoxShadow(
                color: tint.withOpacity(0.06),
                blurRadius: 30,
                spreadRadius: -8,
                offset: const Offset(0, -4),
              ),
              if (widget.isActive)
                BoxShadow(
                  color: tint.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              if (widget.shadows != null) ...widget.shadows!,
            ],
          ),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Creates the refractive shimmer effect on Liquid Glass surfaces
class LiquidGlassShimmer extends StatefulWidget {
  final Widget child;
  final Color? tint;

  const LiquidGlassShimmer({super.key, required this.child, this.tint});

  @override
  State<LiquidGlassShimmer> createState() => _LiquidGlassShimmerState();
}

class _LiquidGlassShimmerState extends State<LiquidGlassShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(min: 0.0, max: 0.5);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = widget.tint ?? (isDark ? Colors.white : Colors.black);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmer = _shimmerController.value;
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.0 + shimmer * 2, -1.0),
              end: Alignment(1.0, 1.0),
              colors: [
                tint.withOpacity(0.0),
                tint.withOpacity(0.15),
                tint.withOpacity(0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.add,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
