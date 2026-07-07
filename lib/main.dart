import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/gemini_service.dart';
import 'services/news_feed_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DangerLauncherApp());
}

class DangerLauncherApp extends StatefulWidget {
  const DangerLauncherApp({super.key});

  @override
  State<DangerLauncherApp> createState() => _DangerLauncherAppState();
}

class _DangerLauncherAppState extends State<DangerLauncherApp> {
  late GeminiService _geminiService;
  late NewsFeedService _newsFeedService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _newsFeedService = NewsFeedService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danger Launcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorSchemeSeed: const Color(0xFF6366F1),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorSchemeSeed: const Color(0xFF818CF8),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(
        geminiService: _geminiService,
        newsFeedService: _newsFeedService,
      ),
      routes: {
        '/settings': (context) => SettingsScreen(geminiService: _geminiService),
      },
    );
  }
}
