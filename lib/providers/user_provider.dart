import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/badge.dart';
import '../models/title.dart';

class UserProvider extends ChangeNotifier {
  // User data
  String _username = 'Giocatore';
  int _level = 1;
  int _totalXp = 0;
  int _gamesPlayed = 0;
  int _gamesWon = 0;
  int _gamesLost = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;
  int _currentTitleId = 1;

  // Collections
  List<Badge> _allBadges = [];
  List<int> _unlockedBadgeIds = [];
  List<Title> _allTitles = [];

  // Getters
  String get username => _username;
  int get level => _level;
  int get totalXp => _totalXp;
  int get gamesPlayed => _gamesPlayed;
  int get gamesWon => _gamesWon;
  int get gamesLost => _gamesLost;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  int get currentTitleId => _currentTitleId;

  List<Badge> get allBadges => _allBadges;
  List<Badge> get unlockedBadges =>
      _allBadges.where((b) => _unlockedBadgeIds.contains(b.badgeId)).toList();
  List<int> get unlockedBadgeIds => List.unmodifiable(_unlockedBadgeIds);
  List<Title> get allTitles => _allTitles;
  Title? get currentTitle =>
      _allTitles.firstWhere((t) => t.titleId == _currentTitleId);

  // Calcolo XP necessaria per prossimo livello
  int get xpForNextLevel => _level * 1000; // Formula: livello * 1000
  int get xpProgress => _totalXp % xpForNextLevel;
  double get xpProgressPercentage => xpProgress / xpForNextLevel;

  // Win rate
  double get winRate => _gamesPlayed > 0 ? (_gamesWon / _gamesPlayed) * 100 : 0;

  // Accuracy rate
  double get accuracy => (_correctAnswers + _wrongAnswers) > 0
      ? (_correctAnswers / (_correctAnswers + _wrongAnswers)) * 100
      : 0;

  UserProvider() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    final db = DatabaseService();

    // Carica dati utente
    final userData = await db.getUserProfile();
    if (userData != null) {
      _username = userData['username'] ?? 'Giocatore';
      _level = userData['level'] ?? 1;
      _totalXp = userData['total_xp'] ?? 0;
      _gamesPlayed = userData['games_played'] ?? 0;
      _gamesWon = userData['games_won'] ?? 0;
      _gamesLost = userData['games_lost'] ?? 0;
      _correctAnswers = userData['correct_answers'] ?? 0;
      _wrongAnswers = userData['wrong_answers'] ?? 0;
      _currentTitleId = userData['current_title_id'] ?? 1;
    }

    // Carica badge
    _allBadges = await db.getAllBadges();
    _unlockedBadgeIds = await db.getUnlockedBadgeIds();

    // Carica titoli
    _allTitles = await db.getAllTitles();

    notifyListeners();
  }

  // Aggiorna username
  Future<void> updateUsername(String newUsername) async {
    if (newUsername.isEmpty || newUsername.length > 20) return;

    _username = newUsername;
    await DatabaseService().updateUsername(newUsername);
    notifyListeners();
  }

  // Cambia titolo corrente
  Future<void> changeTitle(int titleId) async {
    _currentTitleId = titleId;
    await DatabaseService().updateCurrentTitle(titleId);
    notifyListeners();
  }

  // Aggiungi XP e controlla level up
  Future<void> addXp(int xp) async {
    _totalXp += xp;

    // Controlla level up
    while (_totalXp >= (_level * 1000)) {
      _totalXp -= (_level * 1000);
      _level++;

      // Controlla sblocco titoli basati sul livello
      await _checkLevelBasedUnlocks();
    }

    await DatabaseService().updateUserStats({
      'total_xp': _totalXp,
      'level': _level,
    });

    notifyListeners();
  }

  // Aggiorna statistiche partita
  Future<void> updateGameStats({
    required bool won,
    required int correctAnswersCount,
    required int wrongAnswersCount,
    required int scoreEarned,
  }) async {
    _gamesPlayed++;
    if (won) {
      _gamesWon++;
    } else {
      _gamesLost++;
    }
    _correctAnswers += correctAnswersCount;
    _wrongAnswers += wrongAnswersCount;

    // Aggiungi XP basato sul punteggio (conversione 10:1)
    await addXp(scoreEarned ~/ 10);

    await DatabaseService().updateUserStats({
      'games_played': _gamesPlayed,
      'games_won': _gamesWon,
      'games_lost': _gamesLost,
      'correct_answers': _correctAnswers,
      'wrong_answers': _wrongAnswers,
    });

    // Controlla sblocco badge
    await _checkBadgeUnlocks();

    notifyListeners();
  }

  // Controlla e sblocca badge
  Future<void> _checkBadgeUnlocks() async {
    final db = DatabaseService();

    // First game
    if (_gamesPlayed == 1 && !_unlockedBadgeIds.contains(1)) {
      await db.unlockBadge(1);
      _unlockedBadgeIds.add(1);
    }

    // First win
    if (_gamesWon == 1 && !_unlockedBadgeIds.contains(2)) {
      await db.unlockBadge(2);
      _unlockedBadgeIds.add(2);
    }

    // Games milestones
    if (_gamesPlayed >= 50 && !_unlockedBadgeIds.contains(7)) {
      await db.unlockBadge(7);
      _unlockedBadgeIds.add(7);
    }

    if (_gamesPlayed >= 100 && !_unlockedBadgeIds.contains(8)) {
      await db.unlockBadge(8);
      _unlockedBadgeIds.add(8);
    }

    if (_gamesPlayed >= 1000 && !_unlockedBadgeIds.contains(15)) {
      await db.unlockBadge(15);
      _unlockedBadgeIds.add(15);
    }
  }

  // Controlla sblocchi basati sul livello
  Future<void> _checkLevelBasedUnlocks() async {
    final db = DatabaseService();

    // Badge livello
    if (_level >= 10 && !_unlockedBadgeIds.contains(5)) {
      await db.unlockBadge(5);
      _unlockedBadgeIds.add(5);
    }

    if (_level >= 25 && !_unlockedBadgeIds.contains(6)) {
      await db.unlockBadge(6);
      _unlockedBadgeIds.add(6);
    }

    if (_level >= 50 && !_unlockedBadgeIds.contains(13)) {
      await db.unlockBadge(13);
      _unlockedBadgeIds.add(13);
    }

    if (_level >= 100 && !_unlockedBadgeIds.contains(14)) {
      await db.unlockBadge(14);
      _unlockedBadgeIds.add(14);
    }
  }

  // Reset statistiche (ma non badge)
  Future<void> resetStatistics() async {
    _level = 1;
    _totalXp = 0;
    _gamesPlayed = 0;
    _gamesWon = 0;
    _gamesLost = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;

    await DatabaseService().resetUserStatistics();
    notifyListeners();
  }

  // Sblocca badge speciali (per eventi particolari)
  Future<void> unlockSpecialBadge(String internalName) async {
    final badge = _allBadges.firstWhere(
          (b) => b.internalName == internalName,
      orElse: () => Badge(badgeId: -1, internalName: '', iconEmoji: '', category: '', rarity: 'bronze'),
    );

    if (badge.badgeId != -1 && !_unlockedBadgeIds.contains(badge.badgeId)) {
      await DatabaseService().unlockBadge(badge.badgeId);
      _unlockedBadgeIds.add(badge.badgeId);
      notifyListeners();
    }
  }
}