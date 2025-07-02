import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';
import '../widgets/image_button.dart';
import 'category_menu_screen.dart';
import 'profile_screen.dart';

class GameMenuScreen extends StatelessWidget {
  const GameMenuScreen({super.key});

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
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 55),
                      Text(
                        l10n.get('app_title'),
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
                      IconButton(
                        icon: const CircleAvatar(
                          radius: 25,
                          child: Icon(Icons.person),
                        ),
                        onPressed: () {
                          AudioManager().playNavigationForward();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('true_false'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryMenuScreen(gameMode: l10n.get('true_false')),
                      ),
                    );
                  },
                  width: 250,
                  height: 70,
                ),
                const SizedBox(height: 20),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('multiple_choice'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryMenuScreen(gameMode: l10n.get('multiple_choice')),
                      ),
                    );
                  },
                  width: 250,
                  height: 70,
                ),
                const SizedBox(height: 20),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('bad_images'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryMenuScreen(gameMode: l10n.get('bad_images')),
                      ),
                    );
                  },
                  width: 250,
                  height: 70,
                ),
                const SizedBox(height: 20),
                ImageButton(
                  imagePath: 'assets/images/buttons/pulsante_generico.png',
                  text: l10n.get('bad_descriptions'),
                  onPressed: () {
                    AudioManager().playNavigationForward();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryMenuScreen(gameMode: l10n.get('bad_descriptions')),
                      ),
                    );
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
}