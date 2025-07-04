import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question.dart';
import '../models/multiple_choice_answer.dart';
import '../models/medium.dart';
import '../models/opera.dart';
import '../models/universe.dart';
import '../models/badge.dart';
import '../models/title.dart' as app_title;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'narratrivia.db');

    // Check if database exists
    final exists = await databaseExists(path);

    if (!exists) {
      // Copy from assets
      try {
        await Directory(dirname(path)).create(recursive: true);
        final data = await rootBundle.load('assets/data/narratrivia.db');
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
      } catch (e) {
        print('Error copying database: $e');
      }
    }

    // Open database
    return await openDatabase(
      path,
      version: 2, // Incrementato per forzare aggiornamento
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crea tutte le tabelle
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medium (
        medium_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS universe (
        universe_id INTEGER PRIMARY KEY,
        medium_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (medium_id) REFERENCES medium(medium_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS opera (
        opera_id INTEGER PRIMARY KEY,
        universe_id INTEGER NOT NULL,
        medium_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        year INTEGER,
        FOREIGN KEY (universe_id) REFERENCES universe(universe_id),
        FOREIGN KEY (medium_id) REFERENCES medium(medium_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        question_id INTEGER PRIMARY KEY,
        opera_id INTEGER NOT NULL,
        type TEXT CHECK(type IN ('multiple_choice', 'true_false')),
        difficulty TEXT CHECK(difficulty IN ('easy', 'normal', 'hard')),
        question_text TEXT NOT NULL,
        correct_answer TEXT,
        explanation TEXT,
        image_path TEXT,
        times_shown INTEGER DEFAULT 0,
        times_correct INTEGER DEFAULT 0,
        FOREIGN KEY (opera_id) REFERENCES opera(opera_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS multiple_choice_answers (
        answer_id INTEGER PRIMARY KEY,
        question_id INTEGER NOT NULL,
        option_text TEXT NOT NULL,
        is_correct INTEGER CHECK(is_correct IN (0, 1)),
        FOREIGN KEY (question_id) REFERENCES questions(question_id)
      )
    ''');

    // Nuove tabelle per user profile
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        user_id INTEGER PRIMARY KEY,
        username TEXT NOT NULL DEFAULT 'Giocatore',
        level INTEGER DEFAULT 1,
        total_xp INTEGER DEFAULT 0,
        games_played INTEGER DEFAULT 0,
        games_won INTEGER DEFAULT 0,
        games_lost INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        wrong_answers INTEGER DEFAULT 0,
        current_title_id INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS badges (
        badge_id INTEGER PRIMARY KEY,
        internal_name TEXT NOT NULL UNIQUE,
        icon_emoji TEXT NOT NULL,
        category TEXT NOT NULL,
        rarity TEXT CHECK(rarity IN ('bronze', 'silver', 'gold', 'platinum')) NOT NULL,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_badges (
        user_id INTEGER,
        badge_id INTEGER,
        unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, badge_id),
        FOREIGN KEY (user_id) REFERENCES user_profile(user_id),
        FOREIGN KEY (badge_id) REFERENCES badges(badge_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS titles (
        title_id INTEGER PRIMARY KEY,
        internal_name TEXT NOT NULL UNIQUE,
        unlock_condition TEXT,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    // Inserisci dati iniziali
    await _insertInitialData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Aggiungi nuove tabelle per user profile
      await _onCreate(db, newVersion);
    }
  }

  Future<void> _insertInitialData(Database db) async {
    // Inserisci utente default
    await db.insert(
      'user_profile',
      {'user_id': 1},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    // Inserisci badge
    final badges = [
      {'badge_id': 1, 'internal_name': 'first_game', 'icon_emoji': '🎮', 'category': 'first_steps', 'rarity': 'bronze', 'sort_order': 1},
      {'badge_id': 2, 'internal_name': 'first_win', 'icon_emoji': '🏆', 'category': 'first_steps', 'rarity': 'bronze', 'sort_order': 2},
      {'badge_id': 3, 'internal_name': 'first_true_false', 'icon_emoji': '✅', 'category': 'first_steps', 'rarity': 'bronze', 'sort_order': 3},
      {'badge_id': 4, 'internal_name': 'first_multiple_choice', 'icon_emoji': '🎯', 'category': 'first_steps', 'rarity': 'bronze', 'sort_order': 4},
      {'badge_id': 5, 'internal_name': 'level_10', 'icon_emoji': '⭐', 'category': 'progress', 'rarity': 'silver', 'sort_order': 5},
      {'badge_id': 6, 'internal_name': 'level_25', 'icon_emoji': '🌟', 'category': 'progress', 'rarity': 'silver', 'sort_order': 6},
      {'badge_id': 7, 'internal_name': 'games_50', 'icon_emoji': '🎲', 'category': 'progress', 'rarity': 'silver', 'sort_order': 7},
      {'badge_id': 8, 'internal_name': 'games_100', 'icon_emoji': '🎪', 'category': 'progress', 'rarity': 'silver', 'sort_order': 8},
      {'badge_id': 9, 'internal_name': 'win_streak_10', 'icon_emoji': '🔥', 'category': 'master', 'rarity': 'gold', 'sort_order': 9},
      {'badge_id': 10, 'internal_name': 'perfect_game', 'icon_emoji': '💯', 'category': 'master', 'rarity': 'gold', 'sort_order': 10},
      {'badge_id': 11, 'internal_name': 'speed_demon', 'icon_emoji': '⚡', 'category': 'master', 'rarity': 'gold', 'sort_order': 11},
      {'badge_id': 12, 'internal_name': 'knowledge_master', 'icon_emoji': '🧠', 'category': 'master', 'rarity': 'gold', 'sort_order': 12},
      {'badge_id': 13, 'internal_name': 'level_50', 'icon_emoji': '👑', 'category': 'legendary', 'rarity': 'platinum', 'sort_order': 13},
      {'badge_id': 14, 'internal_name': 'level_100', 'icon_emoji': '🏅', 'category': 'legendary', 'rarity': 'platinum', 'sort_order': 14},
      {'badge_id': 15, 'internal_name': 'games_1000', 'icon_emoji': '🎭', 'category': 'legendary', 'rarity': 'platinum', 'sort_order': 15},
      {'badge_id': 16, 'internal_name': 'ultimate_champion', 'icon_emoji': '💎', 'category': 'legendary', 'rarity': 'platinum', 'sort_order': 16},
      {'badge_id': 17, 'internal_name': 'night_owl', 'icon_emoji': '🦉', 'category': 'secret', 'rarity': 'silver', 'sort_order': 17},
      {'badge_id': 18, 'internal_name': 'early_bird', 'icon_emoji': '🐦', 'category': 'secret', 'rarity': 'silver', 'sort_order': 18},
      {'badge_id': 19, 'internal_name': 'lucky_seven', 'icon_emoji': '🍀', 'category': 'secret', 'rarity': 'gold', 'sort_order': 19},
      {'badge_id': 20, 'internal_name': 'easter_egg', 'icon_emoji': '🥚', 'category': 'secret', 'rarity': 'platinum', 'sort_order': 20},
    ];

    for (var badge in badges) {
      await db.insert('badges', badge, conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Inserisci titoli
    final titles = [
      {'title_id': 1, 'internal_name': 'novice', 'unlock_condition': 'Default', 'sort_order': 1},
      {'title_id': 2, 'internal_name': 'apprentice', 'unlock_condition': 'Level 10', 'sort_order': 2},
      {'title_id': 3, 'internal_name': 'expert', 'unlock_condition': 'Level 25', 'sort_order': 3},
      {'title_id': 4, 'internal_name': 'master', 'unlock_condition': 'Level 50', 'sort_order': 4},
      {'title_id': 5, 'internal_name': 'legend', 'unlock_condition': 'Level 100', 'sort_order': 5},
    ];

    for (var title in titles) {
      await db.insert('titles', title, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  // QUESTION METHODS

  Future<List<Question>> getTrueFalseQuestions({int? operaId, int limit = 20}) async {
    final db = await database;

    String whereClause = "type = 'true_false'";
    List<dynamic> whereArgs = [];

    if (operaId != null) {
      whereClause += " AND opera_id = ?";
      whereArgs.add(operaId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: limit,
    );

    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  Future<List<Map<String, dynamic>>> getMultipleChoiceQuestionsWithAnswers({
    int? operaId,
    int limit = 20,
  }) async {
    final db = await database;

    String whereClause = "type = 'multiple_choice'";
    List<dynamic> whereArgs = [];

    if (operaId != null) {
      whereClause += " AND opera_id = ?";
      whereArgs.add(operaId);
    }

    final List<Map<String, dynamic>> questions = await db.query(
      'questions',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: limit,
    );

    List<Map<String, dynamic>> result = [];

    for (var questionMap in questions) {
      final question = Question.fromMap(questionMap);

      final List<Map<String, dynamic>> answerMaps = await db.query(
        'multiple_choice_answers',
        where: 'question_id = ?',
        whereArgs: [question.questionId],
      );

      final answers = answerMaps.map((map) => MultipleChoiceAnswer.fromMap(map)).toList();

      result.add({
        'question': question,
        'answers': answers,
      });
    }

    return result;
  }

  Future<void> updateQuestionStats(int questionId, bool wasCorrect) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE questions 
      SET times_shown = times_shown + 1,
          times_correct = times_correct + ?
      WHERE question_id = ?
    ''', [wasCorrect ? 1 : 0, questionId]);
  }

  // MEDIA/OPERA METHODS

  Future<List<Medium>> getAllMedia() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('medium');
    return List.generate(maps.length, (i) => Medium.fromMap(maps[i]));
  }

  Future<List<Opera>> getOperaByMedium(int mediumId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'opera',
      where: 'medium_id = ?',
      whereArgs: [mediumId],
    );
    return List.generate(maps.length, (i) => Opera.fromMap(maps[i]));
  }

  Future<List<Universe>> getUniversesByMedium(int mediumId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'universe',
      where: 'medium_id = ?',
      whereArgs: [mediumId],
    );
    return List.generate(maps.length, (i) => Universe.fromMap(maps[i]));
  }

  // USER PROFILE METHODS

  Future<Map<String, dynamic>?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_profile',
      where: 'user_id = ?',
      whereArgs: [1],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateUsername(String username) async {
    final db = await database;
    await db.update(
      'user_profile',
      {'username': username, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [1],
    );
  }

  Future<void> updateCurrentTitle(int titleId) async {
    final db = await database;
    await db.update(
      'user_profile',
      {'current_title_id': titleId, 'updated_at': DateTime.now().toIso8601String()},
      where: 'user_id = ?',
      whereArgs: [1],
    );
  }

  Future<void> updateUserStats(Map<String, dynamic> stats) async {
    final db = await database;
    stats['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'user_profile',
      stats,
      where: 'user_id = ?',
      whereArgs: [1],
    );
  }

  Future<void> resetUserStatistics() async {
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
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [1],
    );
  }

  // BADGE METHODS

  Future<List<Badge>> getAllBadges() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'badges',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Badge.fromMap(maps[i]));
  }

  Future<List<int>> getUnlockedBadgeIds() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'user_badges',
      columns: ['badge_id'],
      where: 'user_id = ?',
      whereArgs: [1],
    );
    return results.map((r) => r['badge_id'] as int).toList();
  }

  Future<void> unlockBadge(int badgeId) async {
    final db = await database;
    await db.insert(
      'user_badges',
      {
        'user_id': 1,
        'badge_id': badgeId,
        'unlocked_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // TITLE METHODS

  Future<List<app_title.Title>> getAllTitles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'titles',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => app_title.Title.fromMap(maps[i]));
  }
}