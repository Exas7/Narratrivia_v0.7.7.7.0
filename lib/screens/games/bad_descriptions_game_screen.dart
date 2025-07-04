import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '/services/audio_manager.dart';

class BadDescriptionsGameScreen extends StatefulWidget {
  final String category;
  final String mode;
  final String? variant; // Aggiunto parametro variant

  const BadDescriptionsGameScreen({
    super.key,
    required this.category,
    required this.mode,
    this.variant, // Parametro opzionale per POV/varianti
  });

  @override
  State<BadDescriptionsGameScreen> createState() => _BadDescriptionsGameScreenState();
}

class _BadDescriptionsGameScreenState extends State<BadDescriptionsGameScreen> {
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
                  l10n.get('bad_descriptions'),
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
                Text(
                  '${l10n.get('category')}: ${widget.category}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  '${l10n.get('mode')}: ${widget.mode}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                if (widget.variant != null)
                  Text(
                    'POV: ${widget.variant}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                const Spacer(),
                // Placeholder content
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 100,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.get('to_implement'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bad Descriptions game mode\nCategory: ${widget.category}\nMode: ${widget.mode}${widget.variant != null ? '\nPOV: ${widget.variant}' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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