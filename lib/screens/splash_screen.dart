import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Inizializza AudioManager e avvia musica
      await AudioManager().init();

      // Piccolo delay per assicurarsi che AudioPlayer sia pronto
      await Future.delayed(const Duration(milliseconds: 100));

      // Ottieni i volumi salvati e avvia la musica
      final prefs = await SharedPreferences.getInstance();
      final savedMusicVolume = prefs.getDouble('musicVolume') ?? 0.5;
      final savedSfxVolume = prefs.getDouble('sfxVolume') ?? 0.5;
      AudioManager().updateMusicVolume(savedMusicVolume);
      AudioManager().updateSfxVolume(savedSfxVolume);

      // Avvia la musica
      await AudioManager().playMenuMusic();

      // Aspetta 2 secondi
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    } catch (e) {
      // Naviga comunque anche in caso di errore
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Image.asset(
          'assets/images/backgrounds/IconaNarratrivia.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}