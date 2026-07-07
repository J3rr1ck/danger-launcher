import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_item.dart';
import '../widgets/liquid_glass_button.dart';
import '../services/gemini_service.dart';
import '../services/news_feed_service.dart';
import 'feed_screen.dart';

class HomeScreen extends StatefulWidget {
  final GeminiService geminiService;
  final NewsFeedService newsFeedService;

  const HomeScreen({
    super.key,
    required this.geminiService,
    required this.newsFeedService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pageAnimController;
  int _currentPage = 0;
  final List<AppItem> _apps = AppItem.getDefaultApps();
  final List<AppItem> _dockApps = AppItem.getDefaultApps().sublist(0, 4);

  bool _showAppDrawer = false;
  bool _showSearch = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    _pageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageAnimController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openApp(AppItem app) {
    HapticFeedback.mediumImpact();
    debugPrint('Opening ${app.name} (${app.packageName})');

    if (app.name == 'Gemini') {
      widget.geminiService.launchGemini();
    }
  }

  void _toggleAppDrawer() {
    setState(() => _showAppDrawer = !_showAppDrawer);
    if (_showAppDrawer) {
      HapticFeedback.mediumImpact();
    }
  }

  void _onHomeGesture() {
    widget.geminiService.launchGemini();
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          _buildWallpaperLayer(isDark, size),
          _buildPageView(isDark, size),
          _buildDock(isDark, size),
          _buildStatusBar(isDark),
          if (_showAppDrawer) _buildAppDrawer(isDark, size),
          if (_showSearch) _buildSearchOverlay(isDark, size),
        ],
      ),
    );
  }

  Widget _buildWallpaperLayer(bool isDark, Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ]
              : [
                  const Color(0xFFE8ECF1),
                  const Color(0xFFD4D9E1),
                  const Color(0xFFC8CDD6),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildPageView(bool isDark, Size size) {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) {
        setState(() => _currentPage = page);
      },
      children: [
        FeedScreen(
          newsFeedService: widget.newsFeedService,
          geminiService: widget.geminiService,
          onDismiss: () => _goToPage(1),
        ),
        _buildHomeContent(isDark, size),
      ],
    );
  }

  Widget _buildHomeContent(bool isDark, Size size) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60),
          _buildTimeWidget(isDark),
          const SizedBox(height: 40),
          Expanded(child: _buildAppGrid(isDark)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTimeWidget(bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Text(
                  _formatTime(),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            // Settings/Gemini trigger config button
            Positioned(
              right: -60,
              top: -20,
              child: LiquidGlassButton(
                padding: const EdgeInsets.all(8),
                tintColor: const Color(0xFF818CF8),
                borderRadius: BorderRadius.circular(12),
                isActive: true,
                onTap: () => Navigator.pushNamed(context, '/settings'),
                child: Icon(
                  Icons.tune,
                  color: isDark ? Colors.white : Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppGrid(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          return _buildAppIcon(app, isDark);
        },
      ),
    );
  }

  Widget _buildAppIcon(AppItem app, bool isDark) {
    return LiquidGlassButton(
      padding: const EdgeInsets.all(4),
      tintColor: app.color,
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openApp(app),
      onLongPress: () {
        HapticFeedback.heavyImpact();
        if (app.name == 'Gemini') {
          widget.geminiService.triggerVoiceQuery();
        } else {
          _showContextMenu(app);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  app.color.withOpacity(0.3),
                  app.color.withOpacity(0.15),
                ],
              ),
            ),
            child: Icon(app.icon, size: 28, color: app.color),
          ),
          const SizedBox(height: 6),
          Text(
            app.name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDock(bool isDark, Size size) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: LiquidGlassButton(
        padding: EdgeInsets.zero,
        tintColor: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(24),
        height: 72,
        onLongPress: _onHomeGesture,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ..._dockApps.map((app) => _buildDockIcon(app, isDark)),
            LiquidGlassButton(
              padding: const EdgeInsets.all(8),
              tintColor: const Color(0xFF818CF8),
              borderRadius: BorderRadius.circular(16),
              isActive: true,
              onTap: () => widget.geminiService.launchGemini(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF818CF8), Color(0xFF6366F1)],
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockIcon(AppItem app, bool isDark) {
    return LiquidGlassButton(
      padding: const EdgeInsets.all(6),
      tintColor: app.color,
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openApp(app),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              app.color.withOpacity(0.25),
              app.color.withOpacity(0.1),
            ],
          ),
        ),
        child: Icon(app.icon, size: 24, color: app.color),
      ),
    );
  }

  Widget _buildStatusBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        children: [
          Icon(
            Icons.signal_cellular_alt,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.wifi,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const Spacer(),
          Text(
            _formatTimeShort(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.battery_full,
            size: 16,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildAppDrawer(bool isDark, Size size) {
    return Positioned.fill(
      child: Container(
        color: isDark
            ? Colors.black.withOpacity(0.85)
            : Colors.white.withOpacity(0.9),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: LiquidGlassButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  tintColor: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search apps',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _apps.length + 5,
                  itemBuilder: (context, index) {
                    if (index < _apps.length) {
                      final app = _apps[index];
                      return _buildAppIcon(app, isDark);
                    }
                    return LiquidGlassButton(
                      padding: const EdgeInsets.all(4),
                      tintColor: isDark ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                            ),
                            child: Icon(
                              Icons.apps,
                              size: 28,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black38,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'App',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              LiquidGlassButton(
                padding: const EdgeInsets.all(12),
                tintColor: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(20),
                onTap: _toggleAppDrawer,
                child: const Icon(Icons.close),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay(bool isDark, Size size) {
    return Positioned.fill(
      child: Container(
        color: isDark
            ? Colors.black.withOpacity(0.9)
            : Colors.white.withOpacity(0.95),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: LiquidGlassButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  tintColor: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: isDark ? Colors.white60 : Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Search apps, news, or ask Gemini...'
                              : _searchQuery,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () =>
                              setState(() => _searchQuery = ''),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.auto_awesome,
                        color: const Color(0xFF818CF8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Type to search across apps, contacts, and Gemini',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white50 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(AppItem app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiquidGlassButton(
        padding: EdgeInsets.zero,
        tintColor: Theme.of(ctx).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
        borderRadius: BorderRadius.circular(20),
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(Icons.info_outline, 'App Info', () => Navigator.pop(ctx)),
            _menuItem(Icons.share_outlined, 'Share', () => Navigator.pop(ctx)),
            _menuItem(Icons.delete_outline, 'Remove', () => Navigator.pop(ctx)),
            if (app.name == 'Gemini')
              _menuItem(Icons.auto_awesome, 'Voice Query', () {
                Navigator.pop(ctx);
                widget.geminiService.triggerVoiceQuery();
              }),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  String _formatTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimeShort() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate() {
    final now = DateTime.now();
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday',
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
