import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/app_item.dart';
import 'widgets/glass_app_icon.dart';
import 'widgets/glass_dock.dart';
import 'widgets/dynamic_wallpaper.dart';
import 'gemini_trigger.dart';

class LauncherHomeScreen extends StatefulWidget {
  final VoidCallback? onOpenFeed;
  final VoidCallback? onHome;

  const LauncherHomeScreen({super.key, this.onOpenFeed, this.onHome});

  @override
  State<LauncherHomeScreen> createState() => _LauncherHomeScreenState();
}

class _LauncherHomeScreenState extends State<LauncherHomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  final List<AppItem> _apps = [];
  final List<AppItem> _dockApps = [];
  int _selectedPage = 0;
  String _dateTime = '';

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _updateDateTime();
    _initApps();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      _dateTime = '${months[now.month]} ${now.day}, ${now.year}';
    });
  }

  void _initApps() {
    final installed = <AppItem>[
      AppItem(name: 'Phone', icon: Icons.phone, color: const Color(0xFF34C759)),
      AppItem(name: 'Messages', icon: Icons.message, color: const Color(0xFF007AFF)),
      AppItem(name: 'Mail', icon: Icons.mail, color: const Color(0xFF007AFF)),
      AppItem(name: 'Safari', icon: Icons.public, color: const Color(0xFF34C759)),
      AppItem(name: 'Photos', icon: Icons.photo_album, color: const Color(0xFFFF9500)),
      AppItem(name: 'Music', icon: Icons.music_note, color: const Color(0xFFFF3B30)),
      AppItem(name: 'Calendar', icon: Icons.calendar_month, color: const Color(0xFF007AFF)),
      AppItem(name: 'Settings', icon: Icons.settings, color: const Color(0xFF8E8E93)),
      AppItem(name: 'Camera', icon: Icons.camera_alt, color: const Color(0xFFFFD60A)),
      AppItem(name: 'Notes', icon: Icons.note, color: const Color(0xFFFF9500)),
      AppItem(name: 'Gemini', icon: Icons.auto_awesome, color: const Color(0xFF8B5CF6)),
      AppItem(name: 'Weather', icon: Icons.wb_sunny, color: const Color(0xFF34C759)),
    ];
    _apps.addAll(installed);

    _dockApps.addAll([
      AppItem(name: 'Phone', icon: Icons.phone, color: const Color(0xFF34C759)),
      AppItem(name: 'Messages', icon: Icons.message, color: const Color(0xFF007AFF)),
      AppItem(name: 'Mail', icon: Icons.mail, color: const Color(0xFF007AFF)),
      AppItem(name: 'Gemini', icon: Icons.auto_awesome, color: const Color(0xFF8B5CF6)),
    ]);
  }

  void _launchApp(AppItem app) {
    HapticFeedback.mediumImpact();
    if (app.name == 'Gemini') {
      GeminiTrigger.launchGemini(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Launching ${app.name}...'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
      );
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, child) {
        return Stack(
          children: [
            const DynamicWallpaper(),
            // Glass overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  _buildStatusBar(),
                  const Spacer(),
                  _buildAppGrid(),
                  const SizedBox(height: 16),
                  _buildDock(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            // Bottom home indicator
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildHomeIndicator(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _dateTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.signal_cellular_alt,
              color: Colors.white70, size: 16),
        ],
      ),
    );
  }

  Widget _buildAppGrid() {
    final pageCount = (_apps.length / 8).ceil();
    final page = _selectedPage.clamp(0, pageCount - 1);
    final start = page * 8;
    final end = (start + 8).clamp(0, _apps.length).toInt();
    final pageApps = _apps.sublist(start, end);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var row = 0; row < 3; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var col = 0; col < 4; col++) ...[
                    if (row * 4 + col < pageApps.length)
                      GlassAppIcon(
                        app: pageApps[row * 4 + col],
                        onTap: () =>
                            _launchApp(pageApps[row * 4 + col]),
                      ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDock() {
    return GlassDock(
      apps: _dockApps,
      onTap: (app) => _launchApp(app),
    );
  }

  Widget _buildHomeIndicator() {
    return GestureDetector(
      onTap: widget.onHome,
      child: Container(
        width: 36,
        height: 5,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
