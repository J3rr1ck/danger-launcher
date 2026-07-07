import 'dart:math';
import 'package:flutter/material.dart';

/// Dynamic wallpaper with Liquid Glass depth layers.
/// iOS 26 style: adaptive, fluid backgrounds with light interaction.
class DynamicWallpaper extends StatefulWidget {
  const DynamicWallpaper({super.key});

  @override
  State<DynamicWallpaper> createState() => _DynamicWallpaperState();
}

class _DynamicWallpaperState extends State<DynamicWallpaper>
    with TickerProviderStateMixin {
  late final AnimationController _driftController;
  late final AnimationController _pulseController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // Create ambient particles for glass depth effect
    for (var i = 0; i < 24; i++) {
      _particles.add(_Particle(
        Random().nextDouble(),
        Random().nextDouble(),
        Random().nextDouble() * 60 + 20,
        Random().nextDouble() * 0.15,
        Random().nextDouble() * 0.003 + 0.001,
      ));
    }

    _driftController.addListener(() => setState(() {}));
    _pulseController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _driftController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0f0c29),
            const Color(0xFF302b63),
            const Color(0xFF24243e),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _GlassParticlesPainter(
          particles: _particles,
          drift: _driftController.value,
          pulse: _pulseController.value,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;

  _Particle(this.x, this.y, this.size, this.opacity, this.speed);
}

class _GlassParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double drift;
  final double pulse;

  _GlassParticlesPainter({
    required this.particles,
    required this.drift,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final dx = p.x + drift * p.speed * 50;
      final dy = p.y + drift * (1 - p.speed) * 30;

      final opacity = p.opacity * (0.8 + 0.2 * sin(pulse * 2 * pi + p.x * 10));
      final radius = p.size * (0.9 + 0.1 * sin(pulse * 3 + p.y * 8));

      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
        ..shader = RadialGradient(
          colors: [
            Colors.white.withOpacity(opacity * 0.5),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(dx * size.width, dy * size.height),
          radius: radius,
        ));

      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GlassParticlesPainter oldDelegate) => true;
}
