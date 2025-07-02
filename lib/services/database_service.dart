import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/question.dart';
import '../models/multiple_choice_answer.dart';
import '../models/opera.dart';
import '../models/universe.dart';
import '../models/medium.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  static const String _dbName = 'narratrivia.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final exists = await databaseExists(path);

    if (!exists) {
      await _copyDatabaseFromAssets(path);
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      final ByteData data = await rootBundle.load('assets/data/$_dbName');
      final List<int> bytes = data.buffer.asUint8List();

      await Directory(dirname(path)).create(recursive: true);
      await File(path).writeAsBytes(bytes, flush: true);
    } catch (e) {
      throw Exception('Errore nel copiare il database: $e');
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Implementa qui la logica di aggiornamento se necessario
  }

  /// Ottiene domande con JOIN completo
  Future<List<Question>> getQuestions({
    String? type,
    String? difficulty,
    String? mediumName,
    String? universeName,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    String query = '''
      SELECT 
        q.question_id,
        q.type,
        q.difficulty,
        q.question_text,
        q.correct_answer,
        q.explanation,
        q.opera_id,
        q.image_path,
        q.times_shown,
        q.times_correct,
        o.name AS opera_name,
        u.name AS universe_name,
        m.name AS medium_name
      FROM questions q
      JOIN opera o ON q.opera_id = o.opera_id
      JOIN universe u ON o.universe_id = u.universe_id
      JOIN medium m ON o.medium_id = m.medium_id
      WHERE 1=1
    ''';

    List<dynamic> args = [];

    if (type != null) {
      query += ' AND q.type = ?';
      args.add(type);
    }

    if (difficulty != null) {
      query += ' AND q.difficulty = ?';
      args.add(difficulty);
    }

    if (mediumName != null) {
      query += ' AND m.name = ?';
      args.add(mediumName);
    }

    if (universeName != null) {
      query += ' AND u.name = ?';
      args.add(universeName);
    }

    query += ' ORDER BY RANDOM()';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    if (offset != null) {
      query += ' OFFSET ?';
      args.add(offset);
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

    return List.generate(maps.length, (i) {
      return Question.fromMap(maps[i]);
    });
  }

  /// Ottiene domande Vero/Falso
  Future<List<Question>> getTrueFalseQuestions({
    String? difficulty,
    String? mediumName,
    String? universeName,
    int? limit,
  }) async {
    return getQuestions(
      type: 'true_false',
      difficulty: difficulty,
      mediumName: mediumName,
      universeName: universeName,
      limit: limit,
    );
  }

  /// Ottiene le risposte per una domanda a scelta multipla
  Future<List<MultipleChoiceAnswer>> getAnswersForQuestion(int questionId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'multiple_choice_answers',
      where: 'question_id = ?',
      whereArgs: [questionId],
      orderBy: 'RANDOM()',
    );

    return List.generate(maps.length, (i) {
      return MultipleChoiceAnswer.fromMap(maps[i]);
    });
  }

  /// Ottiene domande a scelta multipla con le risposte
  Future<List<Map<String, dynamic>>> getMultipleChoiceQuestionsWithAnswers({
    String? difficulty,
    String? mediumName,
    String? universeName,
    int? limit,
  }) async {
    final questions = await getQuestions(
      type: 'multiple_choice',
      difficulty: difficulty,
      mediumName: mediumName,
      universeName: universeName,
      limit: limit,
    );

    List<Map<String, dynamic>> result = [];

    for (var question in questions) {
      final answers = await getAnswersForQuestion(question.questionId);

      // Skip domande senza risposte
      if (answers.isEmpty) {
        continue;
      }

      result.add({
        'question': question,
        'answers': answers,
      });
    }

    return result;
  }

  /// Ottiene tutti i medium disponibili
  Future<List<Medium>> getAllMedia() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'medium',
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return Medium.fromMap(maps[i]);
    });
  }

  /// Ottiene tutti gli universi disponibili
  Future<List<Universe>> getAllUniverses() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'universe',
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return Universe.fromMap(maps[i]);
    });
  }

  /// Ottiene le opere per un determinato medium
  Future<List<Opera>> getOperaByMedium(int mediumId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'opera',
      where: 'medium_id = ?',
      whereArgs: [mediumId],
      orderBy: 'name',
    );

    return List.generate(maps.length, (i) {
      return Opera.fromMap(maps[i]);
    });
  }

  /// Conta le domande disponibili con i filtri specificati
  Future<int> countQuestions({
    String? type,
    String? difficulty,
    String? mediumName,
    String? universeName,
  }) async {
    final db = await database;

    String query = '''
      SELECT COUNT(*) as count
      FROM questions q
      JOIN opera o ON q.opera_id = o.opera_id
      JOIN universe u ON o.universe_id = u.universe_id
      JOIN medium m ON o.medium_id = m.medium_id
      WHERE 1=1
    ''';

    List<dynamic> args = [];

    if (type != null) {
      query += ' AND q.type = ?';
      args.add(type);
    }

    if (difficulty != null) {
      query += ' AND q.difficulty = ?';
      args.add(difficulty);
    }

    if (mediumName != null) {
      query += ' AND m.name = ?';
      args.add(mediumName);
    }

    if (universeName != null) {
      query += ' AND u.name = ?';
      args.add(universeName);
    }

    final result = await db.rawQuery(query, args);
    return result.first['count'] as int;
  }

  /// Ottiene statistiche sulle domande
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalQuestions = await db.rawQuery('SELECT COUNT(*) as count FROM questions');
    final totalOpera = await db.rawQuery('SELECT COUNT(*) as count FROM opera');
    final totalUniverses = await db.rawQuery('SELECT COUNT(*) as count FROM universe');

    final questionsByType = await db.rawQuery('''
      SELECT type, COUNT(*) as count 
      FROM questions 
      GROUP BY type
    ''');

    final questionsByDifficulty = await db.rawQuery('''
      SELECT difficulty, COUNT(*) as count 
      FROM questions 
      GROUP BY difficulty
    ''');

    final questionsByMedium = await db.rawQuery('''
      SELECT m.name, COUNT(*) as count 
      FROM questions q
      JOIN opera o ON q.opera_id = o.opera_id
      JOIN medium m ON o.medium_id = m.medium_id
      GROUP BY m.name
    ''');

    return {
      'totalQuestions': totalQuestions.first['count'],
      'totalOpera': totalOpera.first['count'],
      'totalUniverses': totalUniverses.first['count'],
      'byType': questionsByType,
      'byDifficulty': questionsByDifficulty,
      'byMedium': questionsByMedium,
    };
  }

  /// Aggiorna le statistiche di una domanda dopo una risposta
  Future<void> updateQuestionStats(int questionId, bool wasCorrect) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE questions 
      SET times_shown = times_shown + 1,
          times_correct = times_correct + ?
      WHERE question_id = ?
    ''', [wasCorrect ? 1 : 0, questionId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}