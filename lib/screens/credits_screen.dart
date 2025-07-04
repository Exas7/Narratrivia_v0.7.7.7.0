import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

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
                const SizedBox(height: 20),
                Text(
                  l10n.get('app_title'),
                  style: const TextStyle(
                    fontSize: 35,
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
                const SizedBox(height: 10),
                Text(
                  '${l10n.get('version')} 0.7.7.7.0',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Credits scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCreditSection(l10n.get('executive_production'), [
                            _buildCreditRow(l10n.get('executive_producer'), 'Io'),
                            _buildCreditRow(l10n.get('creative_director'), 'Io'),
                            _buildCreditRow(l10n.get('product_owner'), 'Io'),
                          ]),
                          _buildCreditSection(l10n.get('development'), [
                            _buildCreditRow(l10n.get('lead_developer'), 'Claude'),
                            _buildCreditRow(l10n.get('senior_developer'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('gameplay_programmer'), 'Claude'),
                            _buildCreditRow(l10n.get('ui_programmer'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('backend_developer'), 'Claude'),
                            _buildCreditRow(l10n.get('database_architect'), 'ChatGPT'),
                          ]),
                          _buildCreditSection(l10n.get('design'), [
                            _buildCreditRow(l10n.get('game_designer'), 'Io'),
                            _buildCreditRow(l10n.get('ui_ux_designer'), 'Claude'),
                            _buildCreditRow(l10n.get('level_designer'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('art_director'), 'Io'),
                            _buildCreditRow(l10n.get('graphic_designer'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('content_creation'), [
                            _buildCreditRow(l10n.get('lead_writer'), 'Io'),
                            _buildCreditRow(l10n.get('narrative_designer'), 'Claude'),
                            _buildCreditRow(l10n.get('content_creator'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('trivia_specialist'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('localization'), [
                            _buildCreditRow(l10n.get('localization_manager'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('italian_translator'), 'Io'),
                            _buildCreditRow(l10n.get('english_translator'), 'Claude'),
                            _buildCreditRow(l10n.get('spanish_translator'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('french_translator'), 'Claude'),
                            _buildCreditRow(l10n.get('german_translator'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('portuguese_translator'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('audio'), [
                            _buildCreditRow(l10n.get('audio_director'), 'Claude'),
                            _buildCreditRow(l10n.get('sound_designer'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('music_composer'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('quality_assurance'), [
                            _buildCreditRow(l10n.get('qa_lead'), 'Io'),
                            _buildCreditRow(l10n.get('qa_tester'), 'Claude'),
                            _buildCreditRow(l10n.get('qa_tester'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('playtester'), 'Io'),
                          ]),
                          _buildCreditSection(l10n.get('marketing'), [
                            _buildCreditRow(l10n.get('marketing_director'), 'Io'),
                            _buildCreditRow(l10n.get('social_media_manager'), 'Claude'),
                            _buildCreditRow(l10n.get('community_manager'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('pr_manager'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('business_legal'), [
                            _buildCreditRow(l10n.get('business_developer'), 'Io'),
                            _buildCreditRow(l10n.get('legal_advisor'), 'Claude'),
                            _buildCreditRow(l10n.get('compliance_officer'), 'ChatGPT'),
                            _buildCreditRow(l10n.get('ip_manager'), 'Claude'),
                          ]),
                          _buildCreditSection(l10n.get('special_thanks'), [
                            _buildCreditRow('', l10n.get('special_thanks_text')),
                          ]),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              '© 2025 Narratrivia - ${l10n.get('all_rights_reserved')}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSection(String title, List<Widget> credits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        ...credits,
      ],
    );
  }

  Widget _buildCreditRow(String role, String name) {
    if (role.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          name,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              role,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}