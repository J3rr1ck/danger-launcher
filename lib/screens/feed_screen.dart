import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/news_feed_service.dart';
import '../widgets/liquid_glass_button.dart';
import '../services/gemini_service.dart';

class FeedScreen extends StatefulWidget {
  final NewsFeedService newsFeedService;
  final GeminiService geminiService;
  final VoidCallback? onDismiss;

  const FeedScreen({
    super.key,
    required this.newsFeedService,
    required this.geminiService,
    this.onDismiss,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<NewsArticle>? _articles;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final articles = await widget.newsFeedService.fetchFeed();
    if (mounted) {
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    final articles = await widget.newsFeedService.fetchFeed(forceRefresh: true);
    if (mounted) {
      setState(() {
        _articles = articles;
        _isRefreshing = false;
      });
    }
  }

  void _search(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0A0A0A), const Color(0xFF1A1A2E)]
              : [const Color(0xFFF5F5F5), const Color(0xFFE8ECF1)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Google Now-style search bar
            _buildSearchBar(theme, isDark),
            // Feed content
            Expanded(child: _buildFeedContent(theme, isDark)),
            // Gemini trigger button at bottom
            _buildGeminiTrigger(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: LiquidGlassButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        tintColor: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(16),
        onTap: () => _search(''),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Search news & updates...',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.mic_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedContent(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3));
    }

    final articles = _articles ?? [];
    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No articles available',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: articles.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFeedHeader(theme, isDark);
          }
          final article = articles[index - 1];
          return _buildArticleCard(article, theme, isDark);
        },
      ),
    );
  }

  Widget _buildFeedHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Text(
            'Today\'s Feed',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Gemini quick trigger
          LiquidGlassButton(
            padding: const EdgeInsets.all(8),
            tintColor: const Color(0xFF818CF8),
            borderRadius: BorderRadius.circular(12),
            onTap: () => widget.geminiService.triggerVoiceQuery(),
            child: Icon(
              Icons.auto_awesome,
              color: const Color(0xFF818CF8),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle article, ThemeData theme, bool isDark) {
    final hasImage = article.imageUrl != null && article.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: LiquidGlassButton(
        padding: EdgeInsets.zero,
        tintColor: isDark ? Colors.white : Colors.black,
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Open article (would use url_launcher in production)
          HapticFeedback.mediumImpact();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  article.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_outlined)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        article.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(article.publishedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiTrigger(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LiquidGlassButton(
        height: 56,
        tintColor: const Color(0xFF818CF8),
        borderRadius: BorderRadius.circular(20),
        isActive: true,
        onTap: () => widget.geminiService.launchGemini(),
        onLongPress: () => widget.geminiService.triggerVoiceQuery(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.onSurface,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Ask Gemini',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours > 24) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
