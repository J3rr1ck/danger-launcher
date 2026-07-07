import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsArticle {
  final String title;
  final String description;
  final String? imageUrl;
  final String source;
  final String url;
  final DateTime publishedAt;

  const NewsArticle({
    required this.title,
    required this.description,
    this.imageUrl,
    required this.source,
    required this.url,
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      imageUrl: json['urlToImage'],
      source: json['source']?['name'] ?? 'Unknown',
      url: json['url'] ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class NewsFeedService {
  static const String _newsKey = 'cached_news_feed';
  static const String _lastFetchKey = 'last_fetch_time';

  /// Fetch top headlines (simulates Google Now feed)
  Future<List<NewsArticle>> fetchFeed({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Cache for 15 minutes
    if (!forceRefresh && (now - lastFetch) < 900000) {
      final cached = prefs.getString(_newsKey);
      if (cached != null) {
        final List<dynamic> cachedList = json.decode(cached);
        return cachedList
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    try {
      // Using a public news API endpoint
      final response = await http.get(
        Uri.parse(
          'https://newsapi.org/v2/top-headlines'
          '?country=us&pageSize=20&apiKey=demo',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articles = data['articles'] ?? [];
        final feeds = articles
            .take(15)
            .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache the feed
        await prefs.setString(_newsKey, json.encode(feeds.map((f) => {
          'title': f.title,
          'description': f.description,
          'urlToImage': f.imageUrl,
          'source': {'name': f.source},
          'url': f.url,
          'publishedAt': f.publishedAt.toIso8601String(),
        }).toList()));
        await prefs.setInt(_lastFetchKey, now);

        return feeds;
      }
    } catch (e) {
      debugPrint('News feed fetch failed: $e');
    }

    // Return cached if available
    final cached = prefs.getString(_newsKey);
    if (cached != null) {
      final List<dynamic> cachedList = json.decode(cached);
      return cachedList
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Fallback demo articles
    return _getDemoArticles();
  }

  List<NewsArticle> _getDemoArticles() {
    return [
      const NewsArticle(
        title: 'Pixel 10 Pro: What to Expect',
        description: 'Google\'s next flagship pushes AI-native computing with Gemini integration.',
        source: 'Android Central',
        url: '',
        publishedAt: DateTime.now(),
      ),
      const NewsArticle(
        title: 'iOS 26 Liquid Glass Design',
        description: 'Apple\'s new design language transforms how users interact with their devices.',
        source: 'TechCrunch',
        url: '',
        publishedAt: DateTime.now(),
      ),
      const NewsArticle(
        title: 'Gemini Nano Now Runs on-device',
        description: 'Google\'s lightweight AI model is available directly on Pixel devices.',
        source: 'The Verge',
        url: '',
        publishedAt: DateTime.now(),
      ),
      const NewsArticle(
        title: 'Material You evolves with AI',
        description: 'Dynamic theming gets smarter with contextual color adaptation.',
        source: 'Android Authority',
        url: '',
        publishedAt: DateTime.now(),
      ),
    ];
  }
}
