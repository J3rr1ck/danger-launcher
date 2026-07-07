import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/installed_app.dart';
import '../services/launcher_api.dart';
import '../widgets/dynamic_wallpaper.dart';
import '../widgets/glass_app_icon.dart';
import '../widgets/app_drawer.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final List<InstalledApp> apps;
  final LauncherApi api;
  final VoidCallback onRefresh;
  final VoidCallback? onOpenFeed;
  final VoidCallback? onHome;

  const HomeScreen({
    super.key,
    required this.apps,
    required this.api,
    required this.onRefresh,
    this.onOpenFeed,
    this.onHome,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  bool _showDrawer = false;
  int _currentPage = 0;
  String _dateTime = '';

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    _dateTime = '${months[now.month]} ${now.day}, ${now.year}';
  }

  void _launchApp(InstalledApp app) {
    HapticFeedback.mediumImpact();
    widget.api.launchApp(app.packageName);
  }

  void _openDrawer() => setState(() => _showDrawer = true);
  void _closeDrawer() => setState(() => _showDrawer = false);

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SettingsScreen(api: widget.api),
    ));
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
            // Glass depth overlay
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
            // Main content
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
            // App drawer overlay
            if (_showDrawer)
              AppDrawer(
                apps: widget.apps,
                api: widget.api,
                onLaunch: _launchApp,
                onClose: _closeDrawer,
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
          GestureDetector(
            onTap: _openSettings,
            child: Row(
              children: [
                Icon(Icons.settings_outlined,
                    color: Colors.white70, size: 18),
                const SizedBox(width: 6),
                Text(
                  _dateTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onOpenFeed,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome,
                      color: Color(0xFF8B5CF6), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppGrid() {
    final pageApps = widget.apps;
    if (pageApps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apps, color: Colors.white.withOpacity(0.3), size: 48),
            const SizedBox(height: 8),
            Text('Loading apps...',
              style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ],
        ),
      );
    }

    final maxApps = (_currentPage + 1) * 8;
    final visible = pageApps.take(maxApps).toList();
    final rows = (visible.length / 4).ceil().clamp(0, 3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var col = 0; col < 4; col++) ...[
                    if (row * 4 + col < visible.length)
                      GlassAppIcon(
                        app: visible[row * 4 + col],
                        onTap: () =>
                            _launchApp(visible[row * 4 + col]),
                      ),
                  ],
                ],
              ),
            ),
          // Page dots
          if (pageApps.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < (pageApps.length / 8).ceil(); i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDock() {
    final dockApps = widget.apps.take(4).toList();
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
        children: [
          ...dockApps.map((app) => GestureDetector(
            onTap: () => _launchApp(app),
            child: GlassAppIcon(app: app, size: 44),
          )),
          // App drawer button
          GestureDetector(
            onTap: _openDrawer,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withOpacity(0.1),
              ),
              child: const Icon(Icons.apps,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
