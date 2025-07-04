import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';
import '../services/audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/theater_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      l10n.get('settings'),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Settings container
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              // Music Volume
                              _buildVolumeControl(
                                l10n.get('music_volume'),
                                settings.musicVolume,
                                    (value) => settings.setMusicVolume(value),
                              ),
                              const SizedBox(height: 30),
                              // SFX Volume
                              _buildVolumeControl(
                                l10n.get('sfx_volume'),
                                settings.sfxVolume,
                                    (value) => settings.setSfxVolume(value),
                              ),
                              const SizedBox(height: 30),
                              // Brightness
                              _buildBrightnessControl(
                                l10n.get('brightness'),
                                settings.brightness,
                                    (value) => settings.setBrightness(value),
                              ),
                              const SizedBox(height: 30),
                              // Language selector
                              _buildLanguageSelector(l10n, settings),
                              const SizedBox(height: 30),
                              // Reset Statistics Button
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showResetStatsDialog(context, l10n),
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: Text(
                                    l10n.get('reset_statistics'),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.withValues(alpha: 0.7),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Back button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager().playNavigationBack();
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'assets/images/icons/backicon.png',
                            width: 55,
                            height: 55,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeControl(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                AudioManager().playSeatClick();
                if (value > 0) onChanged((value - 0.1).clamp(0.0, 1.0));
              },
              child: Image.asset(
                'assets/images/icons/voldownicon.png',
                width: 40,
                height: 40,
              ),
            ),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF8B0000),
                inactiveColor: Colors.grey,
              ),
            ),
            GestureDetector(
              onTap: () {
                AudioManager().playSeatClick();
                if (value < 1) onChanged((value + 0.1).clamp(0.0, 1.0));
              },
              child: Image.asset(
                'assets/images/icons/volupicon.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrightnessControl(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                AudioManager().playSeatClick();
                if (value > 0) onChanged((value - 0.1).clamp(0.0, 1.0));
              },
              child: Image.asset(
                'assets/images/icons/bridownicon.png',
                width: 40,
                height: 40,
              ),
            ),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.yellow,
                inactiveColor: Colors.grey,
              ),
            ),
            GestureDetector(
              onTap: () {
                AudioManager().playSeatClick();
                if (value < 1) onChanged((value + 0.1).clamp(0.0, 1.0));
              },
              child: Image.asset(
                'assets/images/icons/briupicon.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(AppLocalizations l10n, SettingsProvider settings) {
    final languages = {
      'it': '🇮🇹 Italiano',
      'en': '🇬🇧 English',
      'es': '🇪🇸 Español',
      'fr': '🇫🇷 Français',
      'de': '🇩🇪 Deutsch',
      'pt': '🇵🇹 Português',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('language'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30),
          ),
          child: DropdownButton<String>(
            value: settings.languageCode,
            isExpanded: true,
            dropdownColor: const Color(0xFF1a1a1a),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                AudioManager().playSeatClick();
                settings.setLanguage(newValue);
              }
            },
            items: languages.entries.map<DropdownMenuItem<String>>((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showResetStatsDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          l10n.get('reset_statistics'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.get('reset_stats_warning'),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.get('cancel'),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.resetStatistics();
              AudioManager().playNavigationBack();
              Navigator.pop(context);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.get('stats_reset_success')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              l10n.get('confirm'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}