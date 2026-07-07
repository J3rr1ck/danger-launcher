import 'package:flutter/material.dart';
import '../services/launcher_api.dart';

class SettingsScreen extends StatefulWidget {
  final LauncherApi api;

  const SettingsScreen({super.key, required this.api});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0f0c29),
            Color(0xFF302b63),
            Color(0xFF24243e),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSection('Display', [
                    _buildTile('Wallpaper & Theme', Icons.wallpaper,
                        'Dynamic Liquid Glass'),
                    _buildTile('Icon Size', Icons.grid_view,
                        'Medium'),
                    _buildTile('Dock Style', Icons.dock,
                        'Glass Morphism'),
                  ]),
                  _buildSection('Launcher', [
                    _buildTile('Default Home', Icons.home,
                        'Page 1'),
                    _buildTile('App Drawer Style', Icons.apps,
                        'Full-screen grid'),
                    _buildTile('Search Engine', Icons.search,
                        'Google'),
                  ]),
                  _buildSection('Gemini AI', [
                    _buildTile('Voice Trigger', Icons.mic,
                        'Enabled'),
                    _buildTile('Overlay Shortcut', Icons.auto_awesome,
                        'Swipe from left'),
                    _buildTile('Context Awareness', Icons.psychology,
                        'On'),
                  ]),
                  _buildSection('About', [
                    _buildTile('Version', Icons.info_outline,
                        'v0.0.1'),
                    _buildTile('Build', Icons.build,
                        'danger-launcher'),
                    _buildTile('License', Icons.article,
                        'MIT'),
                  ]),
                ],
              ),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.settings,
              color: Colors.white70, size: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ...tiles,
      ],
    );
  }

  Widget _buildTile(String label, IconData icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right,
              color: Colors.white.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }
}
