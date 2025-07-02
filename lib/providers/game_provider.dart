import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/multiple_choice_answer.dart';
import '../services/database_service.dart';

class GameProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Stato del gioco corrente
  List<Question> _currentQuestions = [];
  Map<int, List<MultipleChoiceAnswer>> _multipleChoiceAnswers = {};
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int _wrongAnswers = 0;

  // Filtri selezionati
  String? _selectedMedium;
  String? _selectedUniverse;
  String? _selectedDifficulty;
  String? _selectedGameMode;
  String? _selectedQuestionType;

  // Timer per modalità tempo
  int _remainingTime = 0;

  // Getters
  List<Question> get currentQuestions => _currentQuestions;
  Question? get currentQuestion => _currentQuestionIndex < _currentQuestions.length
      ? _currentQuestions[_currentQuestionIndex]
      : null;
  List<MultipleChoiceAnswer>? get currentAnswers =>
      currentQuestion != null ? _multipleChoiceAnswers[currentQuestion!.questionId] : null;

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentQuestions.length;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _wrongAnswers;
  int get remainingTime => _remainingTime;

  String? get selectedMedium => _selectedMedium;
  String? get selectedUniverse => _selectedUniverse;
  String? get selectedDifficulty => _selectedDifficulty;
  String? get selectedGameMode => _selectedGameMode;
  String? get selectedQuestionType => _selectedQuestionType;

  bool get isGameOver => _currentQuestionIndex >= _currentQuestions.length;
  double get accuracy => _correctAnswers + _wrongAnswers > 0
      ? _correctAnswers / (_correctAnswers + _wrongAnswers)
      : 0.0;

  /// Imposta i filtri di gioco
  void setGameFilters({
    String? medium,
    String? universe,
    String? difficulty,
    String? gameMode,
    String? questionType,
  }) {
    _selectedMedium = medium;
    _selectedUniverse = universe;
    _selectedDifficulty = difficulty;
    _selectedGameMode = gameMode;
    _selectedQuestionType = questionType;
    notifyListeners();
  }

  /// Carica le domande per il gioco
  Future<void> loadQuestions({
    required String questionType,
    int limit = 20,
  }) async {
    try {
      _resetGameState();

      // Se medium è "mix", usa null per ottenere domande da tutti i medium
      final mediumFilter = (_selectedMedium == 'mix' || _selectedMedium == 'MIX')
          ? null
          : _selectedMedium;

      if (questionType == 'true_false') {
        _currentQuestions = await _databaseService.getTrueFalseQuestions(
          difficulty: _selectedDifficulty,
          mediumName: mediumFilter,
          universeName: _selectedUniverse,
          limit: limit,
        );
      } else if (questionType == 'multiple_choice') {
        final questionsWithAnswers = await _databaseService.getMultipleChoiceQuestionsWithAnswers(
          difficulty: _selectedDifficulty,
          mediumName: mediumFilter,
          universeName: _selectedUniverse,
          limit: limit,
        );

        for (var item in questionsWithAnswers) {
          final question = item['question'] as Question;
          final answers = item['answers'] as List<MultipleChoiceAnswer>;
          _currentQuestions.add(question);
          _multipleChoiceAnswers[question.questionId] = answers;
        }
      } else {
        // Carica domande miste
        final halfLimit = (limit / 2).ceil();

        // Carica domande true/false
        final tfQuestions = await _databaseService.getTrueFalseQuestions(
          difficulty: _selectedDifficulty,
          mediumName: mediumFilter,
          universeName: _selectedUniverse,
          limit: halfLimit,
        );
        _currentQuestions.addAll(tfQuestions);

        // Carica domande multiple choice
        final mcQuestionsWithAnswers = await _databaseService.getMultipleChoiceQuestionsWithAnswers(
          difficulty: _selectedDifficulty,
          mediumName: mediumFilter,
          universeName: _selectedUniverse,
          limit: halfLimit,
        );

        for (var item in mcQuestionsWithAnswers) {
          final question = item['question'] as Question;
          final answers = item['answers'] as List<MultipleChoiceAnswer>;
          _currentQuestions.add(question);
          _multipleChoiceAnswers[question.questionId] = answers;
        }

        // Mischia le domande
        _currentQuestions.shuffle();
      }

      // Imposta il tempo per modalità tempo
      final gameModeToCheck = _selectedGameMode?.toLowerCase() ?? '';
      if (gameModeToCheck == 'tempo' || gameModeToCheck == 'a tempo' || gameModeToCheck == 'timed') {
        _remainingTime = 60; // 1 minuto totale per modalità tempo
      }

      notifyListeners();
    } catch (e) {
      _currentQuestions = [];
      notifyListeners();
    }
  }

  /// Risponde alla domanda corrente
  Future<void> answerQuestion(dynamic answer) async {
    if (isGameOver || currentQuestion == null) return;

    bool isCorrect = false;

    if (currentQuestion!.type == 'true_false') {
      isCorrect = currentQuestion!.correctAnswerAsBool == answer;
    } else if (currentQuestion!.type == 'multiple_choice') {
      if (answer is int) {
        // Risposta per indice
        final answers = _multipleChoiceAnswers[currentQuestion!.questionId];
        if (answers != null && answer < answers.length) {
          isCorrect = answers[answer].isCorrect;
        }
      } else if (answer is String) {
        // Risposta per testo
        final answers = _multipleChoiceAnswers[currentQuestion!.questionId];
        if (answers != null) {
          final selectedAnswer = answers.firstWhere(
                (a) => a.optionText == answer,
            orElse: () => answers.first,
          );
          isCorrect = selectedAnswer.isCorrect;
        }
      }
    }

    if (isCorrect) {
      _correctAnswers++;
      _score += currentQuestion!.basePoints;
    } else {
      _wrongAnswers++;
    }

    // Aggiorna le statistiche nel database
    await _databaseService.updateQuestionStats(currentQuestion!.questionId, isCorrect);

    notifyListeners();
  }

  /// Passa alla prossima domanda
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Aggiorna il tempo rimanente
  void updateRemainingTime(int seconds) {
    _remainingTime = seconds;
    notifyListeners();
  }

  /// Reset dello stato del gioco
  void _resetGameState() {
    _currentQuestions = [];
    _multipleChoiceAnswers = {};
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _remainingTime = 0;
  }

  /// Reset completo
  void resetGame() {
    _resetGameState();
    _selectedMedium = null;
    _selectedUniverse = null;
    _selectedDifficulty = null;
    _selectedGameMode = null;
    _selectedQuestionType = null;
    notifyListeners();
  }
}