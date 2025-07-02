import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../services/audio_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
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
                  const SizedBox(height: 50),
                  // Music volume control
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.get('music_volume'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            return Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons/voldownicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: settings.musicVolume,
                                    onChanged: (value) {
                                      settings.setMusicVolume(value);
                                    },
                                    activeColor: Colors.purple,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/icons/volupicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // SFX volume control
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.get('sfx_volume'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            return Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons/voldownicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: settings.sfxVolume,
                                    onChanged: (value) {
                                      settings.setSfxVolume(value);
                                      // Test SFX quando si muove lo slider
                                      AudioManager().playNavigationForward();
                                    },
                                    activeColor: Colors.green,
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/icons/volupicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Brightness control
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.get('brightness'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            return Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons/bridownicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                                Expanded(
                                  child: Slider(
                                    value: settings.brightness,
                                    onChanged: (value) {
                                      settings.setBrightness(value);
                                    },
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/icons/briupicon.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Language selector
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.get('language'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            return DropdownButton<String>(
                              value: settings.languageCode,
                              dropdownColor: Colors.deepPurple,
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'it', child: Text('Italiano')),
                                DropdownMenuItem(value: 'en', child: Text('English')),
                                DropdownMenuItem(value: 'fr', child: Text('Français')),
                                DropdownMenuItem(value: 'es', child: Text('Español')),
                                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                                DropdownMenuItem(value: 'pt', child: Text('Português')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  settings.setLanguage(value);
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Back button
                  Align(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}