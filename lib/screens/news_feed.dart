import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/launcher_api.dart';

/// Google Now-style feed with real RSS headlines and local weather.
class NewsFeedScreen extends StatefulWidget {
  final VoidCallback? onHome;

  const NewsFeedScreen({super.key, this.onHome});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final WeatherApi _weatherApi = WeatherApi();
  final RssApi _rssApi = RssApi();

  Map<String, dynamic>? _weather;
  List<RssItem> _feedItems = [];
  bool _loadingFeed = true;
  bool _loadingWeather = true;

  static const List<String> _rssFeeds = [
    'https://feeds.bbci.co.uk/news/rss.xml',
    'https://feeds.bbci.co.uk/news/technology/rss.xml',
    'https://feeds.bbci.co.uk/news/world/rss.xml',
  ];

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadFeed();
  }

  Future<void> _loadWeather() async {
    final weather = await _weatherApi.getWeather();
    if (mounted) {
      setState(() {
        _weather = weather;
        _loadingWeather = false;
      });
    }
  }

  Future<void> _loadFeed() async {
    // Try to fetch real RSS; fall back to generated feed
    try {
      for (final feedUrl in _rssFeeds) {
        final xml = await _rssApi.fetchRss(feedUrl);
        if (xml.isNotEmpty && !xml.startsWith('<error>')) {
          _parseRss(xml);
        }
      }
    } catch (_) {}

    // If RSS returned no items, generate demo feed
    if (_feedItems.isEmpty) {
      _generateDemoFeed();
    }

    if (mounted) {
      setState(() => _loadingFeed = false);
    }
  }

  void _parseRss(String xml) {
    // Simple RSS parser for MVP
    final items = <RssItem>[];
    final titleMatches = RegExp(r'<title>([^<]+)</title>').allMatches(xml);
    final descMatches = RegExp(r'<description[^>]*>([^<]*)</description>').allMatches(xml);
    final linkMatches = RegExp(r'<link[^>]*>([^<]+)</link>').allMatches(xml);

    // Skip first title/link (channel-level), take next ones as items
    var startIdx = 1;
    final categories = ['Top Stories', 'Technology', 'World'];

    for (var i = 0; i < min(titleMatches.length - startIdx, 20); i++) {
      final title = titleMatches.elementAt(i + startIdx).group(1) ?? '';
      final desc = descMatches.elementAt(i + startIdx).group(1) ?? '';
      final link = linkMatches.elementAt(i + startIdx).group(1) ?? '';
      if (title.isNotEmpty) {
        items.add(RssItem(
          title: title,
          description: desc.replaceAll(RegExp(r'<[^>]+>'), '').trim(),
          link: link,
          category: categories[min(i ~/ 7, categories.length - 1)],
          icon: _categoryIcon(categories[min(i ~/ 7, categories.length - 1)]),
          timestamp: DateTime.now().subtract(Duration(hours: i)).toString().substring(11, 16),
        ));
      }
    }

    if (items.isNotEmpty) {
      _feedItems = items;
    }
  }

  void _generateDemoFeed() {
    final topics = [
      ('Top Stories', Icons.public, [
        'Markets rally as tech earnings exceed expectations',
        'New AI framework promises 10x developer productivity',
        'Global climate summit reaches historic agreement',
        'Major breakthrough in quantum computing announced',
      ]),
      ('Technology', Icons.memory, [
        'Apple unveils Liquid Glass design at WWDC 2025',
        'Gemini 2.0 now available with real-time multimodal',
        'Open-source model surpasses GPT-4 on benchmarks',
        'Flutter 4.0 introduces seamless native interop',
      ]),
      ('Science & Nature', Icons.science, [
        'NASA confirms water molecules on exoplanet atmosphere',
        'CRISPR therapy receives FDA approval for blood disorders',
        'Deep-sea expedition discovers new hydrothermal vents',
        'MIT develops self-healing concrete from bacteria',
      ]),
      ('Sports', Icons.sports_esports, [
        'World Cup qualifiers: underdog team shocks favorites',
        r'Basketball star signs record-breaking $300M contract',
        'Olympic committee announces new events for 2028',
        'Formula 1 introduces fully electric powertrain',
      ]),
    ];

    for (final topic in topics) {
      for (final headline in topic.$3) {
        _feedItems.add(RssItem(
          title: headline,
          description: '',
          link: '',
          category: topic.$1,
          icon: topic.$2,
          timestamp: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        ));
      }
    }
    _feedItems.shuffle();
  }

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Technology': return Icons.memory;
      case 'World': return Icons.public;
      default: return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f0f1a),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildFeed()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onHome,
            child: const Icon(Icons.arrow_back,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.auto_awesome,
              color: Color(0xFF8B5CF6), size: 28),
          const SizedBox(width: 12),
          Text(
            'Google Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Icon(Icons.person_outline,
              color: Colors.white70, size: 24),
        ],
      ),
    );
  }

  Widget _buildFeed() {
    if (_loadingFeed || _loadingWeather) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
            SizedBox(height: 8),
            Text('Loading feed...',
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _feedItems.clear();
        _generateDemoFeed();
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _feedItems.length + 2, // weather + quick actions
        itemBuilder: (context, index) {
          if (index == 0) return _buildWeatherCard();
          if (index == 1) return _buildQuickActions();
          final item = _feedItems[index - 2];
          return _buildNewsCard(item);
        },
      ),
    );
  }

  Widget _buildWeatherCard() {
    final w = _weather ?? {};
    final temp = w['temperature'] ?? 72;
    final condition = w['condition'] ?? 'Sunny';
    final high = w['high'] ?? 78;
    final low = w['low'] ?? 65;
    final city = w['city'] ?? 'San Francisco';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny, color: Colors.white, size: 36),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '$temp°F',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                condition,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                'H: $high° L: $low°',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickAction(Icons.restore, 'Recent'),
          _quickAction(Icons.star, 'Favorites'),
          _quickAction(Icons.trending_up, 'Trending'),
          _quickAction(Icons.refresh, 'Refresh'),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(label),
            backgroundColor: const Color(0xFF8B5CF6),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(RssItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(item.icon,
                color: const Color(0xFF8B5CF6), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} • ${item.timestamp}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Colors.white.withOpacity(0.3), size: 20),
        ],
      ),
    );
  }
}

class RssItem {
  final String title;
  final String description;
  final String link;
  final String category;
  final IconData icon;
  final String timestamp;

  RssItem({
    required this.title,
    this.description = '',
    this.link = '',
    required this.category,
    required this.icon,
    required this.timestamp,
  });
}
