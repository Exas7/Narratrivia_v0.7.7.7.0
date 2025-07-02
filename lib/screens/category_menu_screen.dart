import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/mode_menu_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';
import '../services/database_service.dart';
import '../providers/game_provider.dart';
import '../models/medium.dart';
import '../widgets/image_button.dart';

class CategoryMenuScreen extends StatefulWidget {
  final String gameMode;

  const CategoryMenuScreen({super.key, required this.gameMode});

  @override
  State<CategoryMenuScreen> createState() => _CategoryMenuScreenState();
}

class _CategoryMenuScreenState extends State<CategoryMenuScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Medium> _availableMedia = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMediaFromDatabase();
  }

  Future<void> _loadMediaFromDatabase() async {
    try {
      final media = await _databaseService.getAllMedia();

      if (mounted) {
        setState(() {
          _availableMedia = media;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore nel caricamento delle categorie: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _selectMedium(BuildContext context, Medium medium) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setGameFilters(
      medium: medium.name,
      gameMode: widget.gameMode,
    );

    AudioManager().playNavigationForward();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModeMenuScreen(
          gameMode: widget.gameMode,
          category: medium.name,
        ),
      ),
    );
  }

  Widget _buildMediumButton(Medium medium) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ImageButton(
        imagePath: 'assets/images/buttons/pulsante_generico.png',
        text: medium.name,
        onPressed: () => _selectMedium(context, medium),
        width: 250,
        height: 70,
      ),
    );
  }

  Widget _buildMixButton() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ImageButton(
        imagePath: 'assets/images/buttons/pulsante_generico.png',
        text: l10n.get('mix'),
        onPressed: () {
          final gameProvider = Provider.of<GameProvider>(context, listen: false);
          gameProvider.setGameFilters(
            medium: 'mix',
            gameMode: widget.gameMode,
          );

          AudioManager().playNavigationForward();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModeMenuScreen(
                gameMode: widget.gameMode,
                category: l10n.get('mix'),
              ),
            ),
          );
        },
        width: 250,
        height: 70,
      ),
    );
  }

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
                  widget.gameMode,
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
                const SizedBox(height: 20),

                // Contenuto principale
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                      : _errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 50,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _loadMediaFromDatabase();
                          },
                          child: Text(l10n.get('retry')),
                        ),
                      ],
                    ),
                  )
                      : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          // Pulsanti per ogni medium dal database
                          ..._availableMedia.map(_buildMediumButton),

                          // Pulsante Mix sempre presente
                          _buildMixButton(),
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
            ),
          ),
        ],
      ),
    );
  }
}