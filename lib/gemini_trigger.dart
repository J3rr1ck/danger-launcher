import 'package:flutter/material.dart';

/// Gemini integration triggers.
/// Launches Gemini app or invokes Gemini intent.
class GeminiTrigger {
  static const String _geminiPackage = 'com.google.android.gemini';
  static const String _geminiDeepLink = 'gemini://';

  /// Launch Gemini app via deep link.
  static void launchGemini(BuildContext context) {
    try {
      // In a real launcher, use platform channel to launch the app.
      // For now, show a visual trigger animation and intent.
      _showGeminiOverlay(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gemini not installed. Install from Play Store.'),
          backgroundColor: const Color(0xFF8B5CF6),
        ),
      );
    }
  }

  static void _showGeminiOverlay(BuildContext context) {
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => _GeminiLaunchOverlay(
        onDismiss: () => entry?.remove(),
      ),
    );
    Overlay.of(context).insert(entry);
  }
}

class _GeminiLaunchOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;

  const _GeminiLaunchOverlay({this.onDismiss});

  @override
  State<_GeminiLaunchOverlay> createState() => _GeminiLaunchOverlayState();
}

class _GeminiLaunchOverlayState extends State<_GeminiLaunchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF8B5CF6),
                    Color(0xFF6C63FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Gemini',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Thinking...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
