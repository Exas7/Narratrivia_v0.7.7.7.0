import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/multiple_choice_answer.dart';
import '../services/database_service.dart';
import '../providers/user_provider.dart';

class GameProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Game state
  List<Question> _currentQuestions = [];
  Map<int, List<MultipleChoiceAnswer>> _multipleChoiceAnswers = {};
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _correctAnswersCount = 0;
  int _wrongAnswersCount = 0;
  bool _isGameActive = false;

  // Timer state
  Timer? _timer;
  int _timeLeft = 0;

  // Game settings
  String _currentGameType = '';
  String _currentMode = '';
  int _operaId = 0;

  // Getters
  List<Question> get currentQuestions => _currentQuestions;
  Question? get currentQuestion =>
      _currentQuestionIndex < _currentQuestions.length
          ? _currentQuestions[_currentQuestionIndex]
          : null;
  List<MultipleChoiceAnswer>? get currentMultipleChoiceAnswers =>
      currentQuestion != null
          ? _multipleChoiceAnswers[currentQuestion!.questionId]
          : null;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentQuestions.length;
  int get score => _score;
  int get correctAnswersCount => _correctAnswersCount;
  int get wrongAnswersCount => _wrongAnswersCount;
  bool get isGameActive => _isGameActive;
  int get timeLeft => _timeLeft;
  String get currentGameType => _currentGameType;
  String get currentMode => _currentMode;

  // Reset game state
  void resetGame() {
    _currentQuestions = [];
    _multipleChoiceAnswers = {};
    _currentQuestionIndex = 0;
    _score = 0;
    _correctAnswersCount = 0;
    _wrongAnswersCount = 0;
    _isGameActive = false;
    _timer?.cancel();
    _timeLeft = 0;
    notifyListeners();
  }

  // Load questions based on type and filters
  Future<void> loadQuestions({
    required String questionType,
    int? operaId,
    String mode = 'classic',
    int limit = 20,
  }) async {
    resetGame();

    _currentGameType = questionType;
    _currentMode = mode;
    _operaId = operaId ?? 0;

    try {
      if (questionType == 'true_false') {
        _currentQuestions = await _databaseService.getTrueFalseQuestions(
          operaId: operaId,
          limit: limit,
        );
      } else if (questionType == 'multiple_choice') {
        final questionsWithAnswers = await _databaseService.getMultipleChoiceQuestionsWithAnswers(
          operaId: operaId,
          limit: limit,
        );

        _currentQuestions = [];
        _multipleChoiceAnswers = {};

        for (var item in questionsWithAnswers) {
          final question = item['question'] as Question;
          final answers = item['answers'] as List<MultipleChoiceAnswer>;

          _currentQuestions.add(question);
          _multipleChoiceAnswers[question.questionId] = answers;
        }
      }

      _isGameActive = true;
      notifyListeners();
    } catch (e) {
    }
  }

  // Answer current question
  Future<void> answerQuestion(dynamic answer) async {
    if (!_isGameActive || _currentQuestionIndex >= _currentQuestions.length) return;

    final question = _currentQuestions[_currentQuestionIndex];
    bool isCorrect = false;

    if (question.type == 'true_false') {
      isCorrect = answer.toString() == question.correctAnswer;
    } else if (question.type == 'multiple_choice') {
      isCorrect = answer is MultipleChoiceAnswer && answer.isCorrect;
    }

    if (isCorrect) {
      _score += question.basePoints;
      _correctAnswersCount++;
    } else {
      _wrongAnswersCount++;
    }

    // Update question statistics in database
    await _databaseService.updateQuestionStats(question.questionId, isCorrect);

    notifyListeners();
  }

  // Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  // Start timer for timed mode
  void startTimer(int seconds) {
    _timer?.cancel();
    _timeLeft = seconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        // Time's up - could trigger auto-end game
      }
    });
  }

  // End game and update user statistics
  void endGame(BuildContext context, UserProvider userProvider) {
    _isGameActive = false;
    _timer?.cancel();

    // Calculate if won (at least 50% correct answers)
    final totalAnswers = _correctAnswersCount + _wrongAnswersCount;
    final won = totalAnswers > 0 && (_correctAnswersCount / totalAnswers) >= 0.5;

    // Update user statistics
    userProvider.updateGameStats(
      won: won,
      correctAnswersCount: _correctAnswersCount,
      wrongAnswersCount: _wrongAnswersCount,
      scoreEarned: _score,
    );

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}