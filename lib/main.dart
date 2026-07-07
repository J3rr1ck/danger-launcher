import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/installed_app.dart';
import 'services/launcher_api.dart';
import 'screens/home_screen.dart';
import 'screens/news_feed.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
  runApp(const DangerLauncherApp());
}

class DangerLauncherApp extends StatefulWidget {
  const DangerLauncherApp({super.key});

  @override
  State<DangerLauncherApp> createState() => _DangerLauncherAppState();
}

class _DangerLauncherAppState extends State<DangerLauncherApp> {
  final LauncherApi _api = LauncherApi();
  List<InstalledApp> _allApps = [];

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    final apps = await _api.getInstalledApps();
    setState(() => _allApps = apps);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danger Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
      ),
      home: LauncherRoot(
        allApps: _allApps,
        api: _api,
        onRefresh: _loadApps,
      ),
    );
  }
}

class LauncherRoot extends StatefulWidget {
  final List<InstalledApp> allApps;
  final LauncherApi api;
  final VoidCallback onRefresh;

  const LauncherRoot({
    super.key,
    required this.allApps,
    required this.api,
    required this.onRefresh,
  });

  @override
  State<LauncherRoot> createState() => _LauncherRootState();
}

class _LauncherRootState extends State<LauncherRoot>
    with TickerProviderStateMixin {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page-based navigation: feed | home
          PageView(
            controller: _pageController,
            onPageChanged: (_) => HapticFeedback.lightImpact(),
            children: [
              NewsFeedScreen(onHome: () => _pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut)),
              HomeScreen(
                apps: widget.allApps,
                api: widget.api,
                onRefresh: widget.onRefresh,
                onOpenFeed: () => _pageController.animateToPage(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut),
                onHome: () => _pageController.animateToPage(1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut),
              ),
            ],
          ),
          // Home indicator pill
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pageController.animateToPage(1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut),
              child: Center(
                child: Container(
                  width: 36,
                  height: 5,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
