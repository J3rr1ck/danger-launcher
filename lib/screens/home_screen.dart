import 'dart:math';
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
  bool _refreshing = false;

  static const int appsPerPage = 8;
  static const int columns = 4;

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

  Future<void> _pullToRefresh() async {
    setState(() => _refreshing = true);
    await widget.onRefresh();
    setState(() => _refreshing = false);
  }

  void _nextPage() {
    final totalPages = (widget.apps.length / appsPerPage).ceil();
    if (_currentPage < totalPages - 1) {
      setState(() => _currentPage++);
      HapticFeedback.lightImpact();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      HapticFeedback.lightImpact();
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
            // Page navigation arrows (side gestures)
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: GestureDetector(
                onTap: _prevPage,
                child: Container(width: 40, color: Colors.transparent),
              ),
            ),
            Positioned(
              right: 0, top: 0, bottom: 0,
              child: GestureDetector(
                onTap: _nextPage,
                child: Container(width: 40, color: Colors.transparent),
              ),
            ),
            // Gemini voice trigger pill
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: _buildGeminiTrigger(),
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

  Widget _buildGeminiTrigger() {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.heavyImpact();
        // In production: open Gemini overlay / voice query
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gemini voice trigger activated'),
            backgroundColor: const Color(0xFF8B5CF6),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          color: Color(0xFF8B5CF6),
          size: 24,
        ),
      ),
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
            if (_refreshing)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final startIndex = _currentPage * appsPerPage;
    final endIndex = min(startIndex + appsPerPage, pageApps.length);
    final visible = pageApps.sublist(startIndex, endIndex);
    final rows = (visible.length / columns).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page indicator with dots
          if (pageApps.length > appsPerPage)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _prevPage,
                    child: Icon(Icons.chevron_left,
                        color: Colors.white.withOpacity(0.5), size: 20),
                  ),
                  for (var i = 0; i < (pageApps.length / appsPerPage).ceil(); i++)
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
                  GestureDetector(
                    onTap: _nextPage,
                    child: Icon(Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5), size: 20),
                  ),
                ],
              ),
            ),
          // App grid rows
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var col = 0; col < columns; col++) ...[
                    if (row * columns + col < visible.length)
                      GlassAppIcon(
                        app: visible[row * columns + col],
                        onTap: () =>
                            _launchApp(visible[row * columns + col]),
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
