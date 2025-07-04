import 'package:audioplayers/audioplayers.dart';

// Audio Manager Singleton
class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Volumi separati per musica e SFX
  double _musicVolume = 0.5;
  double _sfxVolume = 0.5;

  // Stato per sapere se la musica dovrebbe essere in riproduzione
  bool _shouldPlayMusic = false;

  // Nomi file audio (placeholder)
  static const String menuMusic = 'sounds/menu_soundtrack.mp3';
  static const String curtainOpenSound = 'sounds/curtain_open.mp3';
  static const String seatClickSound = 'sounds/seat_click.mp3';
  static const String wrongAnswerSound = 'sounds/wrong_answer.mp3';
  static const String timerTickSound = 'sounds/timer_tick.mp3';
  static const String timeUpGongSound = 'sounds/time_up_gong.mp3';
  static const String transitionSound = 'sounds/transition.mp3';
  static const String achievementSound = 'sounds/achievement_fanfare.mp3';

  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void updateMusicVolume(double volume) {
    _musicVolume = volume;
    _musicPlayer.setVolume(volume);
  }

  void updateSfxVolume(double volume) {
    _sfxVolume = volume;
    _sfxPlayer.setVolume(volume);
  }

  // Musica di sottofondo
  Future<void> playMenuMusic() async {
    try {
      _shouldPlayMusic = true;
      await _musicPlayer.play(AssetSource(menuMusic));
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> stopMenuMusic() async {
    _shouldPlayMusic = false;
    await _musicPlayer.stop();
  }

  Future<void> pauseMenuMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMenuMusic() async {
    if (_shouldPlayMusic) {
      await _musicPlayer.resume();
    }
  }

  // Effetti sonori
  Future<void> playNavigationForward() async {
    try {
      await _sfxPlayer.play(AssetSource(curtainOpenSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playNavigationBack() async {
    try {
      await _sfxPlayer.play(AssetSource(seatClickSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playSeatClick() async {
    try {
      await _sfxPlayer.play(AssetSource(seatClickSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playWrongAnswer() async {
    try {
      await _sfxPlayer.play(AssetSource(wrongAnswerSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playTimerTick() async {
    try {
      await _sfxPlayer.play(AssetSource(timerTickSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playTimeUp() async {
    try {
      await _sfxPlayer.play(AssetSource(timeUpGongSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playTransition() async {
    try {
      await _sfxPlayer.play(AssetSource(transitionSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  Future<void> playAchievement() async {
    try {
      await _sfxPlayer.play(AssetSource(achievementSound));
      await _sfxPlayer.setVolume(_sfxVolume);
    } catch (e) {
      // Gestione silenziosa dell'errore
    }
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}