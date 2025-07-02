import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/audio_manager.dart';

// Provider per gestione impostazioni
class SettingsProvider extends ChangeNotifier {
  double _musicVolume = 0.5;
  double _sfxVolume = 0.5;
  double _brightness = 0.5;
  String _languageCode = 'it';

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  double get brightness => _brightness;
  String get languageCode => _languageCode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.5;
    _brightness = prefs.getDouble('brightness') ?? 0.5;
    _languageCode = prefs.getString('language') ?? 'it';

    // Inizializza i volumi dell'AudioManager
    AudioManager().updateMusicVolume(_musicVolume);
    AudioManager().updateSfxVolume(_sfxVolume);

    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', value);
    AudioManager().updateMusicVolume(value);
    notifyListeners();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfxVolume', value);
    AudioManager().updateSfxVolume(value);
    notifyListeners();
  }

  Future<void> setBrightness(double value) async {
    _brightness = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('brightness', value);
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    notifyListeners();
  }
}