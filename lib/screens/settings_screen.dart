import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../widgets/liquid_glass_button.dart';

class SettingsScreen extends StatefulWidget {
  final GeminiService geminiService;

  const SettingsScreen({super.key, required this.geminiService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, bool> _triggers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTriggers();
  }

  Future<void> _loadTriggers() async {
    final triggers = await GeminiService.getTriggerPreferences();
    if (mounted) {
      setState(() {
        _triggers = triggers;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTrigger(String key, bool value) async {
    await GeminiService.setTriggerPreference(key, value);
    setState(() => _triggers[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 3))
            : _buildContent(theme, isDark),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            children: [
              LiquidGlassButton(
                padding: const EdgeInsets.all(10),
                tintColor: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_rounded, size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                'Gemini Triggers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection('Voice & Gesture Triggers', isDark, [
                  _buildTriggerTile(
                    'Double-tap Home',
                    'Double-tap the home screen to launch Gemini',
                    Icons.tap_and_play,
                    'doubleTapHome',
                    theme,
                    isDark,
                  ),
                  _buildTriggerTile(
                    'Swipe Up from Dock',
                    'Swipe up from the dock to trigger Gemini voice query',
                    Icons.swipe_up,
                    'swipeUp',
                    theme,
                    isDark,
                  ),
                  _buildTriggerTile(
                    'Long-press Home',
                    'Hold on home screen for Gemini quick search',
                    Icons.long_press,
                    'longPressHome',
                    theme,
                    isDark,
                  ),
                  _buildTriggerTile(
                    'Edge Swipe',
                    'Swipe from screen edge to launch Gemini',
                    Icons.edge_screw,
                    'edgeSwipe',
                    theme,
                    isDark,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('Quick Actions', isDark, [
                  _buildActionTile(
                    'Launch Gemini',
                    'Open the Gemini AI app directly',
                    Icons.auto_awesome,
                    () => widget.geminiService.launchGemini(),
                    theme,
                    isDark,
                  ),
                  _buildActionTile(
                    'Voice Query',
                    'Start Gemini with voice input',
                    Icons.mic_outlined,
                    () => widget.geminiService.triggerVoiceQuery(),
                    theme,
                    isDark,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection('About Danger Launcher', isDark, [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Danger Launcher v1.0.0',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A custom Android launcher inspired by iOS 26 Liquid Glass design.\n'
                          'Features Google Now-style news feed and Gemini AI integration.',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Made with ❤️ for Pixel devices',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, bool isDark, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        LiquidGlassButton(
          padding: EdgeInsets.zero,
          tintColor: isDark ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(20),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTriggerTile(
    String title,
    String subtitle,
    IconData icon,
    String key,
    ThemeData theme,
    bool isDark,
  ) {
    final value = _triggers[key] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        secondary: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
        value: value,
        onChanged: (v) => _toggleTrigger(key, v),
        activeColor: const Color(0xFF818CF8),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    ThemeData theme,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF818CF8)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.4),
      ),
      onTap: onTap,
    );
  }
}
