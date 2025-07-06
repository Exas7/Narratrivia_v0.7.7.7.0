import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/badge.dart';
import '../models/title.dart' as app_title;

class UserDatabaseService {
  static final UserDatabaseService _instance = UserDatabaseService._internal();
  static Database? _database;

  factory UserDatabaseService() => _instance;

  UserDatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'user_info.db');

    // Check if database exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);
        final data = await rootBundle.load('assets/data/user_info.db');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        if (kDebugMode) {
          print('User database copied successfully');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error copying user database: $e');
        }
      }
    }

    // Open database
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        if (kDebugMode) {
          print('User database opened successfully');
        }
      },
    );
  }

  // USER PROFILE METHODS

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile({int userId = 1}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Create user profile if not exists
  Future<void> createUserProfileIfNotExists({int userId = 1}) async {
    final db = await database;
    final existing = await getUserProfile(userId: userId);

    if (existing == null) {
      await db.insert(
        'user_profile',
        {
          'user_id': userId,
          'username': 'Giocatore',
          'level': 1,
          'total_xp': 0,
          'games_played': 0,
          'games_won': 0,
          'games_lost': 0,
          'correct_answers': 0,
          'wrong_answers': 0,
          'current_title_id': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // Update username
  Future<void> updateUsername(String username, {int userId = 1}) async {
    final db = await database;
    await db.update(
      'user_profile',
      {'username': username},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Update current title
  Future<void> updateCurrentTitle(int titleId, {int userId = 1}) async {
    final db = await database;
    await db.update(
      'user_profile',
      {'current_title_id': titleId},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Update user statistics
  Future<void> updateUserStats(Map<String, dynamic> stats, {int userId = 1}) async {
    final db = await database;
    await db.update(
      'user_profile',
      stats,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Reset user statistics
  Future<void> resetUserStatistics({int userId = 1}) async {
    final db = await database;
    await db.update(
      'user_profile',
      {
        'level': 1,
        'total_xp': 0,
        'games_played': 0,
        'games_won': 0,
        'games_lost': 0,
        'correct_answers': 0,
        'wrong_answers': 0,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // BADGE METHODS

  // Get all badges
  Future<List<Badge>> getAllBadges() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'badges',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  // Get non-secret badges (for display in collection)
  Future<List<Badge>> getVisibleBadges() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'badges',
      where: 'is_secret = 0',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  // Get unlocked badge IDs for a user
  Future<List<int>> getUnlockedBadgeIds({int userId = 1}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_badges',
      columns: ['badge_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.map((r) => r['badge_id'] as int).toList();
  }

  // Get unlocked badges with details
  Future<List<Map<String, dynamic>>> getUnlockedBadgesWithDetails({int userId = 1}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT b.*, ub.unlocked_at
      FROM badges b
      JOIN user_badges ub ON b.badge_id = ub.badge_id
      WHERE ub.user_id = ?
      ORDER BY ub.unlocked_at DESC
    ''', [userId]);
    return results;
  }

  // Unlock a badge
  Future<void> unlockBadge(int badgeId, {int userId = 1}) async {
    final db = await database;
    await db.insert(
      'user_badges',
      {
        'user_id': userId,
        'badge_id': badgeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Check if a badge is unlocked
  Future<bool> isBadgeUnlocked(int badgeId, {int userId = 1}) async {
    final db = await database;
    final results = await db.query(
      'user_badges',
      where: 'user_id = ? AND badge_id = ?',
      whereArgs: [userId, badgeId],
    );
    return results.isNotEmpty;
  }

  // TITLE METHODS

  // Get all titles
  Future<List<app_title.Title>> getAllTitles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'titles',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => app_title.Title.fromMap(maps[i]));
  }

  // Get unlocked title IDs for a user
  Future<List<int>> getUnlockedTitleIds({int userId = 1}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_titles',
      columns: ['title_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return results.map((r) => r['title_id'] as int).toList();
  }

  // Unlock a title
  Future<void> unlockTitle(int titleId, {int userId = 1}) async {
    final db = await database;
    await db.insert(
      'user_titles',
      {
        'user_id': userId,
        'title_id': titleId,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Check if a title is unlocked
  Future<bool> isTitleUnlocked(int titleId, {int userId = 1}) async {
    final db = await database;
    final results = await db.query(
      'user_titles',
      where: 'user_id = ? AND title_id = ?',
      whereArgs: [userId, titleId],
    );
    return results.isNotEmpty;
  }

  // STATISTICS METHODS

  // Get game statistics for charts
  Future<Map<String, dynamic>> getGameStatistics({int userId = 1}) async {
    final profile = await getUserProfile(userId: userId);
    if (profile == null) return {};

    return {
      'totalGames': profile['games_played'] ?? 0,
      'wins': profile['games_won'] ?? 0,
      'losses': profile['games_lost'] ?? 0,
      'winRate': profile['games_played'] > 0
          ? ((profile['games_won'] ?? 0) / profile['games_played'] * 100).toStringAsFixed(1)
          : '0.0',
      'totalAnswers': (profile['correct_answers'] ?? 0) + (profile['wrong_answers'] ?? 0),
      'correctAnswers': profile['correct_answers'] ?? 0,
      'wrongAnswers': profile['wrong_answers'] ?? 0,
      'accuracy': ((profile['correct_answers'] ?? 0) + (profile['wrong_answers'] ?? 0)) > 0
          ? ((profile['correct_answers'] ?? 0) /
          ((profile['correct_answers'] ?? 0) + (profile['wrong_answers'] ?? 0)) * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  // Get progress towards next unlock
  Future<Map<String, dynamic>> getProgressInfo({int userId = 1}) async {
    final profile = await getUserProfile(userId: userId);
    if (profile == null) return {};

    final level = profile['level'] ?? 1;
    final totalXp = profile['total_xp'] ?? 0;
    final xpForNextLevel = level * 1000;
    final xpProgress = totalXp % xpForNextLevel;

    // Check next milestones
    final nextBadgeMilestones = {
      'games': _getNextMilestone(profile['games_played'] ?? 0, [50, 100, 1000]),
      'level': _getNextMilestone(level, [10, 25, 50, 100]),
    };

    return {
      'currentLevel': level,
      'totalXp': totalXp,
      'xpForNextLevel': xpForNextLevel,
      'xpProgress': xpProgress,
      'xpProgressPercentage': (xpProgress / xpForNextLevel * 100).toStringAsFixed(1),
      'nextMilestones': nextBadgeMilestones,
    };
  }

  int? _getNextMilestone(int current, List<int> milestones) {
    for (var milestone in milestones) {
      if (current < milestone) return milestone;
    }
    return null;
  }

  // ACHIEVEMENT CHECKING

  // Check and unlock achievements based on current stats
  Future<List<int>> checkAndUnlockAchievements({int userId = 1}) async {
    final profile = await getUserProfile(userId: userId);
    if (profile == null) return [];

    final unlockedBadgeIds = await getUnlockedBadgeIds(userId: userId);
    final allBadges = await getAllBadges();
    final newlyUnlocked = <int>[];

    // Map internal names to badge IDs for easier checking
    final badgeMap = {for (var badge in allBadges) badge.internalName: badge.badgeId};

    // Check game milestones
    final gamesPlayed = profile['games_played'] ?? 0;
    if (gamesPlayed >= 1 && !unlockedBadgeIds.contains(badgeMap['first_game'])) {
      await unlockBadge(badgeMap['first_game']!, userId: userId);
      newlyUnlocked.add(badgeMap['first_game']!);
    }
    if (gamesPlayed >= 50 && !unlockedBadgeIds.contains(badgeMap['games_50'])) {
      await unlockBadge(badgeMap['games_50']!, userId: userId);
      newlyUnlocked.add(badgeMap['games_50']!);
    }
    if (gamesPlayed >= 100 && !unlockedBadgeIds.contains(badgeMap['games_100'])) {
      await unlockBadge(badgeMap['games_100']!, userId: userId);
      newlyUnlocked.add(badgeMap['games_100']!);
    }
    if (gamesPlayed >= 1000 && !unlockedBadgeIds.contains(badgeMap['games_1000'])) {
      await unlockBadge(badgeMap['games_1000']!, userId: userId);
      newlyUnlocked.add(badgeMap['games_1000']!);
    }

    // Check win milestones
    final gamesWon = profile['games_won'] ?? 0;
    if (gamesWon >= 1 && !unlockedBadgeIds.contains(badgeMap['first_win'])) {
      await unlockBadge(badgeMap['first_win']!, userId: userId);
      newlyUnlocked.add(badgeMap['first_win']!);
    }

    // Check level milestones
    final level = profile['level'] ?? 1;
    if (level >= 10 && !unlockedBadgeIds.contains(badgeMap['level_10'])) {
      await unlockBadge(badgeMap['level_10']!, userId: userId);
      newlyUnlocked.add(badgeMap['level_10']!);
      // Also unlock the title
      await unlockTitle(2, userId: userId); // Apprentice
    }
    if (level >= 25 && !unlockedBadgeIds.contains(badgeMap['level_25'])) {
      await unlockBadge(badgeMap['level_25']!, userId: userId);
      newlyUnlocked.add(badgeMap['level_25']!);
      await unlockTitle(3, userId: userId); // Expert
    }
    if (level >= 50 && !unlockedBadgeIds.contains(badgeMap['level_50'])) {
      await unlockBadge(badgeMap['level_50']!, userId: userId);
      newlyUnlocked.add(badgeMap['level_50']!);
      await unlockTitle(4, userId: userId); // Master
    }
    if (level >= 100 && !unlockedBadgeIds.contains(badgeMap['level_100'])) {
      await unlockBadge(badgeMap['level_100']!, userId: userId);
      newlyUnlocked.add(badgeMap['level_100']!);
      await unlockTitle(5, userId: userId); // Legend
    }

    return newlyUnlocked;
  }

  // Unlock special achievement (for time-based or special conditions)
  Future<bool> unlockSpecialAchievement(String internalName, {int userId = 1}) async {
    final badges = await getAllBadges();
    final badge = badges.firstWhere(
          (b) => b.internalName == internalName,
      orElse: () => Badge(badgeId: -1, internalName: '', iconEmoji: '',
          category: '', rarity: 'bronze', isSecret: false),
    );

    if (badge.badgeId != -1) {
      final isUnlocked = await isBadgeUnlocked(badge.badgeId, userId: userId);
      if (!isUnlocked) {
        await unlockBadge(badge.badgeId, userId: userId);
        return true;
      }
    }
    return false;
  }
}