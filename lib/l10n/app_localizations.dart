import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('it'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'it': {
      // App generale
      'app_title': 'Narratrivia',
      'loading': 'Caricamento...',
      'error': 'Errore',
      'cancel': 'Annulla',
      'confirm': 'Conferma',
      'close': 'Chiudi',
      'back': 'Indietro',
      'next': 'Avanti',
      'play': 'Gioca',
      'settings': 'Impostazioni',
      'profile': 'Profilo',
      'extra': 'Extra',
      'credits': 'Crediti',
      'version': 'Versione',
      'level': 'Livello',
      'points': 'Punti',
      'score': 'Punteggio',
      'time': 'Tempo',

      // Menu principale
      'play_button': 'GIOCA',
      'profile_button': 'PROFILO',
      'settings_button': 'IMPOSTAZIONI',
      'extra_button': 'EXTRA',

      // Modalità gioco
      'select_game_mode': 'Seleziona Modalità',
      'true_false': 'Vero o Falso',
      'multiple_choice': 'Scelta Multipla',
      'bad_images': 'Brutte Immagini',
      'bad_descriptions': 'Brutte Descrizioni',
      'choose_category': 'Scegli Categoria',

      // Modalità
      'classic_mode': 'Modalità Classica',
      'time_mode': 'Modalità Tempo',
      'zen_mode': 'Modalità Zen',
      'select_mode': 'Seleziona Modalità',

      // In gioco
      'question': 'Domanda',
      'true': 'Vero',
      'false': 'Falso',
      'correct': 'Corretto!',
      'wrong': 'Sbagliato!',
      'explanation': 'Spiegazione',
      'game_over': 'Fine Partita',
      'final_score': 'Punteggio Finale',
      'play_again': 'Gioca Ancora',
      'main_menu': 'Menu Principale',

      // Impostazioni
      'music_volume': 'Volume Musica',
      'sfx_volume': 'Volume Effetti',
      'brightness': 'Luminosità',
      'language': 'Lingua',

      // Profilo
      'player_name': 'Nome Giocatore',
      'statistics': 'Statistiche',
      'badges': 'Badge',
      'titles': 'Titoli',
      'games_played': 'Partite Giocate',
      'games_won': 'Partite Vinte',
      'games_lost': 'Partite Perse',
      'win_rate': 'Percentuale Vittorie',
      'correct_answers': 'Risposte Corrette',
      'wrong_answers': 'Risposte Sbagliate',
      'accuracy': 'Precisione',
      'change_username': 'Cambia Nome Utente',
      'enter_new_username': 'Inserisci nuovo nome',
      'reset_statistics': 'Resetta Statistiche',
      'reset_stats_warning': 'Questa azione resetterà tutte le tue statistiche (ma non i badge). Sei sicuro?',
      'stats_reset_success': 'Statistiche resettate con successo!',
      'locked': 'Bloccato',

      // Titoli
      'novice': 'Novizio',
      'apprentice': 'Apprendista',
      'expert': 'Esperto',
      'master': 'Maestro',
      'legend': 'Leggenda',

      // Badge names
      'first_game': 'Prima Partita',
      'first_win': 'Prima Vittoria',
      'first_true_false': 'Vero o Falso',
      'first_multiple_choice': 'Scelta Multipla',
      'level_10': 'Livello 10',
      'level_25': 'Livello 25',
      'games_50': '50 Partite',
      'games_100': '100 Partite',
      'win_streak_10': 'Serie di 10',
      'perfect_game': 'Partita Perfetta',
      'speed_demon': 'Demone Velocità',
      'knowledge_master': 'Maestro Sapienza',
      'level_50': 'Livello 50',
      'level_100': 'Livello 100',
      'games_1000': '1000 Partite',
      'ultimate_champion': 'Campione Supremo',
      'night_owl': 'Gufo Notturno',
      'early_bird': 'Mattiniero',
      'lucky_seven': 'Sette Fortunato',
      'easter_egg': 'Uovo di Pasqua',

      // Badge descriptions
      'first_game_desc': 'Hai giocato la tua prima partita!',
      'first_win_desc': 'Hai vinto la tua prima partita!',
      'first_true_false_desc': 'Prima partita Vero o Falso completata',
      'first_multiple_choice_desc': 'Prima partita Scelta Multipla completata',
      'level_10_desc': 'Hai raggiunto il livello 10',
      'level_25_desc': 'Hai raggiunto il livello 25',
      'games_50_desc': 'Hai giocato 50 partite',
      'games_100_desc': 'Hai giocato 100 partite',
      'win_streak_10_desc': 'Hai vinto 10 partite di fila',
      'perfect_game_desc': 'Partita completata senza errori',
      'speed_demon_desc': 'Completato modalità tempo in meno di 1 minuto',
      'knowledge_master_desc': '1000 risposte corrette totali',
      'level_50_desc': 'Hai raggiunto il livello 50',
      'level_100_desc': 'Hai raggiunto il livello 100',
      'games_1000_desc': 'Hai giocato 1000 partite',
      'ultimate_champion_desc': 'Hai sbloccato tutti gli altri badge',
      'night_owl_desc': 'Giocato tra le 2 e le 4 di notte',
      'early_bird_desc': 'Giocato tra le 5 e le 7 del mattino',
      'lucky_seven_desc': '7 risposte corrette di fila',
      'easter_egg_desc': 'Hai trovato un segreto!',

      // Rarità
      'bronze': 'Bronzo',
      'silver': 'Argento',
      'gold': 'Oro',
      'platinum': 'Platino',

      // Credits
      'developed_by': 'Sviluppato da',
      'team': 'Team Narratrivia',
      'executive_production': 'Produzione Esecutiva',
      'executive_producer': 'Produttore Esecutivo',
      'creative_director': 'Direttore Creativo',
      'product_owner': 'Product Owner',
      'development': 'Sviluppo',
      'lead_developer': 'Lead Developer',
      'senior_developer': 'Senior Developer',
      'gameplay_programmer': 'Gameplay Programmer',
      'ui_programmer': 'UI Programmer',
      'backend_developer': 'Backend Developer',
      'database_architect': 'Database Architect',
      'design': 'Design',
      'game_designer': 'Game Designer',
      'ui_ux_designer': 'UI/UX Designer',
      'level_designer': 'Level Designer',
      'art_director': 'Art Director',
      'graphic_designer': 'Graphic Designer',
      'content_creation': 'Creazione Contenuti',
      'lead_writer': 'Lead Writer',
      'narrative_designer': 'Narrative Designer',
      'content_creator': 'Content Creator',
      'trivia_specialist': 'Specialista Trivia',
      'localization': 'Localizzazione',
      'localization_manager': 'Localization Manager',
      'italian_translator': 'Traduttore Italiano',
      'english_translator': 'Traduttore Inglese',
      'spanish_translator': 'Traduttore Spagnolo',
      'french_translator': 'Traduttore Francese',
      'german_translator': 'Traduttore Tedesco',
      'portuguese_translator': 'Traduttore Portoghese',
      'audio': 'Audio',
      'audio_director': 'Audio Director',
      'sound_designer': 'Sound Designer',
      'music_composer': 'Compositore Musica',
      'quality_assurance': 'Quality Assurance',
      'qa_lead': 'QA Lead',
      'qa_tester': 'QA Tester',
      'playtester': 'Playtester',
      'marketing': 'Marketing',
      'marketing_director': 'Marketing Director',
      'social_media_manager': 'Social Media Manager',
      'community_manager': 'Community Manager',
      'pr_manager': 'PR Manager',
      'business_legal': 'Business & Legale',
      'business_developer': 'Business Developer',
      'legal_advisor': 'Consulente Legale',
      'compliance_officer': 'Compliance Officer',
      'ip_manager': 'IP Manager',
      'special_thanks': 'Ringraziamenti Speciali',
      'special_thanks_text': 'A tutti i fan della cultura pop che rendono possibile questo gioco!',
      'all_rights_reserved': 'Tutti i diritti riservati',

      // Placeholder
      'coming_soon': 'Prossimamente!',
      'feature_not_available': 'Funzione non ancora disponibile',
    },
    'en': {
      // App general
      'app_title': 'Narratrivia',
      'loading': 'Loading...',
      'error': 'Error',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'play': 'Play',
      'settings': 'Settings',
      'profile': 'Profile',
      'extra': 'Extra',
      'credits': 'Credits',
      'version': 'Version',
      'level': 'Level',
      'points': 'Points',
      'score': 'Score',
      'time': 'Time',

      // Main menu
      'play_button': 'PLAY',
      'profile_button': 'PROFILE',
      'settings_button': 'SETTINGS',
      'extra_button': 'EXTRA',

      // Game modes
      'select_game_mode': 'Select Mode',
      'true_false': 'True or False',
      'multiple_choice': 'Multiple Choice',
      'bad_images': 'Bad Images',
      'bad_descriptions': 'Bad Descriptions',
      'choose_category': 'Choose Category',

      // Modes
      'classic_mode': 'Classic Mode',
      'time_mode': 'Time Mode',
      'zen_mode': 'Zen Mode',
      'select_mode': 'Select Mode',

      // In game
      'question': 'Question',
      'true': 'True',
      'false': 'False',
      'correct': 'Correct!',
      'wrong': 'Wrong!',
      'explanation': 'Explanation',
      'game_over': 'Game Over',
      'final_score': 'Final Score',
      'play_again': 'Play Again',
      'main_menu': 'Main Menu',

      // Settings
      'music_volume': 'Music Volume',
      'sfx_volume': 'SFX Volume',
      'brightness': 'Brightness',
      'language': 'Language',

      // Profile
      'player_name': 'Player Name',
      'statistics': 'Statistics',
      'badges': 'Badges',
      'titles': 'Titles',
      'games_played': 'Games Played',
      'games_won': 'Games Won',
      'games_lost': 'Games Lost',
      'win_rate': 'Win Rate',
      'correct_answers': 'Correct Answers',
      'wrong_answers': 'Wrong Answers',
      'accuracy': 'Accuracy',
      'change_username': 'Change Username',
      'enter_new_username': 'Enter new username',
      'reset_statistics': 'Reset Statistics',
      'reset_stats_warning': 'This will reset all your statistics (but not badges). Are you sure?',
      'stats_reset_success': 'Statistics reset successfully!',
      'locked': 'Locked',

      // Titles
      'novice': 'Novice',
      'apprentice': 'Apprentice',
      'expert': 'Expert',
      'master': 'Master',
      'legend': 'Legend',

      // Badge names
      'first_game': 'First Game',
      'first_win': 'First Win',
      'first_true_false': 'True or False',
      'first_multiple_choice': 'Multiple Choice',
      'level_10': 'Level 10',
      'level_25': 'Level 25',
      'games_50': '50 Games',
      'games_100': '100 Games',
      'win_streak_10': '10 Win Streak',
      'perfect_game': 'Perfect Game',
      'speed_demon': 'Speed Demon',
      'knowledge_master': 'Knowledge Master',
      'level_50': 'Level 50',
      'level_100': 'Level 100',
      'games_1000': '1000 Games',
      'ultimate_champion': 'Ultimate Champion',
      'night_owl': 'Night Owl',
      'early_bird': 'Early Bird',
      'lucky_seven': 'Lucky Seven',
      'easter_egg': 'Easter Egg',

      // Badge descriptions
      'first_game_desc': 'You played your first game!',
      'first_win_desc': 'You won your first game!',
      'first_true_false_desc': 'First True or False game completed',
      'first_multiple_choice_desc': 'First Multiple Choice game completed',
      'level_10_desc': 'You reached level 10',
      'level_25_desc': 'You reached level 25',
      'games_50_desc': 'You played 50 games',
      'games_100_desc': 'You played 100 games',
      'win_streak_10_desc': 'You won 10 games in a row',
      'perfect_game_desc': 'Game completed without errors',
      'speed_demon_desc': 'Completed time mode in less than 1 minute',
      'knowledge_master_desc': '1000 total correct answers',
      'level_50_desc': 'You reached level 50',
      'level_100_desc': 'You reached level 100',
      'games_1000_desc': 'You played 1000 games',
      'ultimate_champion_desc': 'You unlocked all other badges',
      'night_owl_desc': 'Played between 2 and 4 AM',
      'early_bird_desc': 'Played between 5 and 7 AM',
      'lucky_seven_desc': '7 correct answers in a row',
      'easter_egg_desc': 'You found a secret!',

      // Rarity
      'bronze': 'Bronze',
      'silver': 'Silver',
      'gold': 'Gold',
      'platinum': 'Platinum',

      // Credits
      'developed_by': 'Developed by',
      'team': 'Team Narratrivia',
      'executive_production': 'Executive Production',
      'executive_producer': 'Executive Producer',
      'creative_director': 'Creative Director',
      'product_owner': 'Product Owner',
      'development': 'Development',
      'lead_developer': 'Lead Developer',
      'senior_developer': 'Senior Developer',
      'gameplay_programmer': 'Gameplay Programmer',
      'ui_programmer': 'UI Programmer',
      'backend_developer': 'Backend Developer',
      'database_architect': 'Database Architect',
      'design': 'Design',
      'game_designer': 'Game Designer',
      'ui_ux_designer': 'UI/UX Designer',
      'level_designer': 'Level Designer',
      'art_director': 'Art Director',
      'graphic_designer': 'Graphic Designer',
      'content_creation': 'Content Creation',
      'lead_writer': 'Lead Writer',
      'narrative_designer': 'Narrative Designer',
      'content_creator': 'Content Creator',
      'trivia_specialist': 'Trivia Specialist',
      'localization': 'Localization',
      'localization_manager': 'Localization Manager',
      'italian_translator': 'Italian Translator',
      'english_translator': 'English Translator',
      'spanish_translator': 'Spanish Translator',
      'french_translator': 'French Translator',
      'german_translator': 'German Translator',
      'portuguese_translator': 'Portuguese Translator',
      'audio': 'Audio',
      'audio_director': 'Audio Director',
      'sound_designer': 'Sound Designer',
      'music_composer': 'Music Composer',
      'quality_assurance': 'Quality Assurance',
      'qa_lead': 'QA Lead',
      'qa_tester': 'QA Tester',
      'playtester': 'Playtester',
      'marketing': 'Marketing',
      'marketing_director': 'Marketing Director',
      'social_media_manager': 'Social Media Manager',
      'community_manager': 'Community Manager',
      'pr_manager': 'PR Manager',
      'business_legal': 'Business & Legal',
      'business_developer': 'Business Developer',
      'legal_advisor': 'Legal Advisor',
      'compliance_officer': 'Compliance Officer',
      'ip_manager': 'IP Manager',
      'special_thanks': 'Special Thanks',
      'special_thanks_text': 'To all the pop culture fans who make this game possible!',
      'all_rights_reserved': 'All rights reserved',

      // Placeholder
      'coming_soon': 'Coming Soon!',
      'feature_not_available': 'Feature not yet available',
    },
    'es': {
      // Basic translations - expand as needed
      'app_title': 'Narratrivia',
      'play_button': 'JUGAR',
      'profile_button': 'PERFIL',
      'settings_button': 'AJUSTES',
      'extra_button': 'EXTRA',
      'level': 'Nivel',
      'points': 'Puntos',
      'coming_soon': '¡Próximamente!',
    },
    'fr': {
      // Basic translations - expand as needed
      'app_title': 'Narratrivia',
      'play_button': 'JOUER',
      'profile_button': 'PROFIL',
      'settings_button': 'PARAMÈTRES',
      'extra_button': 'EXTRA',
      'level': 'Niveau',
      'points': 'Points',
      'coming_soon': 'Bientôt disponible!',
    },
    'de': {
      // Basic translations - expand as needed
      'app_title': 'Narratrivia',
      'play_button': 'SPIELEN',
      'profile_button': 'PROFIL',
      'settings_button': 'EINSTELLUNGEN',
      'extra_button': 'EXTRA',
      'level': 'Level',
      'points': 'Punkte',
      'coming_soon': 'Demnächst!',
    },
    'pt': {
      // Basic translations - expand as needed
      'app_title': 'Narratrivia',
      'play_button': 'JOGAR',
      'profile_button': 'PERFIL',
      'settings_button': 'CONFIGURAÇÕES',
      'extra_button': 'EXTRA',
      'level': 'Nível',
      'points': 'Pontos',
      'coming_soon': 'Em breve!',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['it', 'en', 'es', 'fr', 'de', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}