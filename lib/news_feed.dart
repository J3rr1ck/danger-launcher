import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  final List<NewsCard> _feedItems = [];

  @override
  void initState() {
    super.initState();
    _generateFeed();
  }

  void _generateFeed() {
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
        _feedItems.add(NewsCard(
          title: headline,
          category: topic.$1,
          icon: topic.$2,
          timestamp: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        ));
      }
    }

    // Shuffle for organic feel but keep grouped
    _feedItems.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
            Color(0xFF0f0f1a),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Google Now header with Liquid Glass styling
            _buildHeader(),
            // Feed content
            Expanded(
              child: _buildFeed(),
            ),
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
          Icon(Icons.auto_awesome,
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _feedItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildWeatherCard();
        }
        final item = _feedItems[index - 1];
        return _buildNewsCard(item);
      },
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
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
              const Text(
                'San Francisco',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const Text(
                '72°F',
                style: TextStyle(
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
                'Sunny',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              Text(
                'H: 78° L: 65°',
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

  Widget _buildNewsCard(NewsCard item) {
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
                color: Color(0xFF8B5CF6), size: 22),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

class NewsCard {
  final String title;
  final String category;
  final IconData icon;
  final String timestamp;

  NewsCard({
    required this.title,
    required this.category,
    required this.icon,
    required this.timestamp,
  });
}
