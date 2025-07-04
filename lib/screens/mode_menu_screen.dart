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

    // Determina quali modalità mostrare in base al tipo di gioco
    List<Widget> modeButtons = _buildModeButtons(context, l10n);

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
                  '${gameMode} - $category',
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
                // Mode buttons
                ...modeButtons,
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

  List<Widget> _buildModeButtons(BuildContext context, AppLocalizations l10n) {
    List<Widget> buttons = [];

    // Determina quale tipo di gioco è stato selezionato
    if (gameMode == l10n.get('true_false') || gameMode.toLowerCase() == 'true/false') {
      // Modalità True/False
      buttons = [
        _buildModeButton(
          context,
          l10n.get('classic'),
          'classic',
          '15 domande bilanciate',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'Speed Round',
          'speed',
          '20 domande in 60 secondi',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'Il Bugiardo',
          'inverse',
          '30 domande - Sbaglia sempre!',
        ),
      ];
    } else if (gameMode == l10n.get('multiple_choice')) {
      // Modalità Multiple Choice
      buttons = [
        _buildModeButton(
          context,
          l10n.get('classic'),
          'classic',
          '15 domande con penalità',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'Per Universo',
          'universe',
          'Domande da un solo universo',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'Challenge',
          'timed',
          '15 domande in 5 minuti',
        ),
      ];
    } else if (gameMode == l10n.get('bad_images')) {
      // Modalità Bad Images
      buttons = [
        _buildModeButton(
          context,
          l10n.get('classic'),
          'classic',
          '5 immagini stilizzate',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'Stili Artistici',
          'styles',
          'Diversi stili di disegno',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          l10n.get('timed'),
          'timed',
          '5 immagini in 2 minuti',
        ),
      ];
    } else if (gameMode == l10n.get('bad_descriptions')) {
      // Modalità Bad Descriptions
      buttons = [
        _buildModeButton(
          context,
          l10n.get('classic'),
          'classic',
          '5 descrizioni fuorvianti',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          'POV',
          'pov',
          'Prospettive alternative',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          l10n.get('timed'),
          'timed',
          '5 descrizioni in 3 minuti',
        ),
      ];
    } else {
      // Fallback alle modalità standard
      buttons = [
        _buildModeButton(
          context,
          l10n.get('classic'),
          'classic',
          'Modalità standard',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          l10n.get('timed'),
          'timed',
          'Con limite di tempo',
        ),
        const SizedBox(height: 20),
        _buildModeButton(
          context,
          l10n.get('zen'),
          'zen',
          'Senza limiti',
        ),
      ];
    }

    return buttons;
  }

  Widget _buildModeButton(BuildContext context, String title, String variant, String description) {
    return Column(
      children: [
        ImageButton(
          imagePath: 'assets/images/buttons/pulsante_generico.png',
          text: title,
          onPressed: () {
            AudioManager().playNavigationForward();
            _navigateToGame(context, variant);
          },
          width: 280,
          height: 70,
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _navigateToGame(BuildContext context, String variant) {
    final l10n = AppLocalizations.of(context)!;

    // Determina quale schermata di gioco lanciare in base al gameMode
    Widget gameScreen;

    if (gameMode == l10n.get('true_false') || gameMode.toLowerCase() == 'true/false') {
      gameScreen = GameScreen(
        gameType: 'true_false',
        category: category,
        mode: variant == 'classic' || variant == 'speed' || variant == 'inverse' ? 'special' : variant,
        variant: variant,
      );
    } else if (gameMode == l10n.get('multiple_choice')) {
      // Per modalità universo, dovremmo mostrare prima una schermata di selezione universo
      if (variant == 'universe') {
        _showUniverseSelection(context, variant);
        return;
      }
      gameScreen = GameScreen(
        gameType: 'multiple_choice',
        category: category,
        mode: variant == 'classic' || variant == 'timed' ? 'special' : variant,
        variant: variant,
      );
    } else if (gameMode == l10n.get('bad_images')) {
      // Per modalità stili, dovremmo mostrare prima una schermata di selezione stile
      if (variant == 'styles') {
        _showStyleSelection(context, variant);
        return;
      }
      gameScreen = BadImagesGameScreen(
        category: category,
        mode: variant,
        variant: variant,
      );
    } else if (gameMode == l10n.get('bad_descriptions')) {
      // Per modalità POV, dovremmo mostrare prima una schermata di selezione POV
      if (variant == 'pov') {
        _showPOVSelection(context, variant);
        return;
      }
      gameScreen = BadDescriptionsGameScreen(
        category: category,
        mode: variant,
        variant: variant,
      );
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

  void _showUniverseSelection(BuildContext context, String variant) {
    final l10n = AppLocalizations.of(context)!;

    // Per ora mostra un placeholder
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purple, width: 2),
          ),
          title: const Text(
            'Seleziona Universo',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'La selezione universi sarà implementata con il database completo.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Procedi con universo generico per ora
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      gameType: 'multiple_choice',
                      category: category,
                      mode: 'universe',
                      variant: variant,
                    ),
                  ),
                );
              },
              child: Text(
                l10n.get('continue'),
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showStyleSelection(BuildContext context, String variant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final styles = [
          'Pixel Art',
          'Emoji Rebus',
          'Stick Figures',
          'Silhouette',
          'Minimalista',
          'ASCII Art',
          'Flow Chart',
          'Child Drawing',
          'Ikea Instructions',
          'Astratto',
        ];

        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purple, width: 2),
          ),
          title: const Text(
            'Seleziona Stile',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: styles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BadImagesGameScreen(
                            category: category,
                            mode: 'styles',
                            variant: styles[index],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      styles[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showPOVSelection(BuildContext context, String variant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final povs = [
          {'name': 'Villain', 'desc': 'Dal punto di vista del cattivo'},
          {'name': 'Bambino', 'desc': 'Come lo vedrebbe un bambino'},
          {'name': 'Recensore Amazon', 'desc': 'Come recensione prodotto'},
          {'name': 'Notiziario', 'desc': 'Come breaking news'},
        ];

        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purple, width: 2),
          ),
          title: const Text(
            'Seleziona Punto di Vista',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: povs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.purple),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BadDescriptionsGameScreen(
                            category: category,
                            mode: 'pov',
                            variant: povs[index]['name']!,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          povs[index]['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          povs[index]['desc']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
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