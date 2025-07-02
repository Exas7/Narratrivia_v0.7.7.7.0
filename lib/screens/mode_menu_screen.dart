import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';
import '../widgets/image_button.dart';
import 'games/game_screen.dart';
import 'games/bad_images_game_screen.dart';
import 'games/bad_descriptions_game_screen.dart';

class ModeMenuScreen extends StatelessWidget {
  final String gameMode;
  final String category;

  const ModeMenuScreen({
    super.key,
    required this.gameMode,
    required this.category,
  });

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
            child: Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  '${l10n.get('mode')} - $category',
                  style: const TextStyle(
                    fontSize: 25,
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
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('classic'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    _navigateToGame(context, l10n.get('classic'));
                  },
                  width: 250,
                  height: 70,
                ),
                const SizedBox(height: 30),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('timed'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    _navigateToGame(context, l10n.get('timed'));
                  },
                  width: 250,
                  height: 70,
                ),
                const SizedBox(height: 30),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('zen'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    _navigateToGame(context, l10n.get('zen'));
                  },
                  width: 250,
                  height: 70,
                ),
                const Spacer(),
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
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, String mode) {
    final l10n = AppLocalizations.of(context)!;

    // Determina quale schermata di gioco lanciare in base al gameMode
    Widget gameScreen;

    if (gameMode == l10n.get('true_false')) {
      gameScreen = GameScreen(
        gameType: 'true_false',
        category: category,
        mode: mode,
      );
    } else if (gameMode == l10n.get('multiple_choice')) {
      gameScreen = GameScreen(
        gameType: 'multiple_choice',
        category: category,
        mode: mode,
      );
    } else if (gameMode == l10n.get('bad_images')) {
      gameScreen = BadImagesGameScreen(category: category, mode: mode);
    } else if (gameMode == l10n.get('bad_descriptions')) {
      gameScreen = BadDescriptionsGameScreen(category: category, mode: mode);
    } else {
      // Fallback - non dovrebbe mai succedere
      _showNotImplemented(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => gameScreen),
    );
  }

  void _showNotImplemented(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('to_implement')),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
