import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Import locali
import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'providers/game_provider.dart'; // NUOVO IMPORT
import 'services/audio_manager.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider( // CAMBIATO DA ChangeNotifierProvider A MultiProvider
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()), // NUOVO PROVIDER
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App in background - pausa la musica
      AudioManager().pauseMenuMusic();
    } else if (state == AppLifecycleState.resumed) {
      // App in foreground - riprendi la musica
      AudioManager().resumeMenuMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'NARRATRIVIA',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          locale: Locale(settings.languageCode),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                // Global brightness overlay
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    // Minimo 30% di oscuramento (0.3 opacità)
                    final opacity = 0.7 * (1 - settings.brightness);
                    return IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: opacity),
                      ),
                    );
                  },
                ),
              ],
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}