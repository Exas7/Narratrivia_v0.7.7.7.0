import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';
import '../widgets/image_button.dart';
import 'game_menu_screen.dart';
import 'settings_screen.dart';
import 'extra_screen.dart';
import 'credits_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    l10n.get('app_title'),
                    style: const TextStyle(
                      fontSize: 40,
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
                  const Spacer(),
                  ImageButton(
                    imagePath: 'assets/images/buttons/pulsante_gioca.png',
                    text: l10n.get('play'),
                    onPressed: () {
                      AudioManager().playNavigationForward();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const GameMenuScreen()),
                      );
                    },
                    width: 350,
                    height: 112,
                  ),
                  const SizedBox(height: 20),
                  ImageButton(
                    imagePath: 'assets/images/buttons/pulsante_generico.png',
                    text: l10n.get('settings'),
                    onPressed: () {
                      AudioManager().playNavigationForward();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    width: 240,
                    height: 65,
                  ),
                  const SizedBox(height: 15),
                  ImageButton(
                    imagePath: 'assets/images/buttons/pulsante_generico.png',
                    text: l10n.get('extra'),
                    onPressed: () {
                      AudioManager().playNavigationForward();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExtraScreen()),
                      );
                    },
                    width: 240,
                    height: 65,
                  ),
                  const SizedBox(height: 15),
                  ImageButton(
                    imagePath: 'assets/images/buttons/pulsante_generico.png',
                    text: l10n.get('credits'),
                    onPressed: () {
                      AudioManager().playNavigationForward();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreditsScreen()),
                      );
                    },
                    width: 240,
                    height: 65,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}