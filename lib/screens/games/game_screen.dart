import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '/l10n/app_localizations.dart';
import '/services/audio_manager.dart';
import '/providers/game_provider.dart';
import '/models/question.dart';
import '/models/multiple_choice_answer.dart';

class GameScreen extends StatefulWidget {
  final String gameType; // 'true_false' o 'multiple_choice'
  final String category; // nome del medium o 'mix'
  final String mode; // 'classica', 'tempo', 'zen'

  const GameScreen({
    super.key,
    required this.gameType,
    required this.category,
    required this.mode,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  int _remainingSeconds = 60; // Per modalità tempo
  bool _isLoading = true;
  bool _showingFeedback = false;
  int? _selectedAnswerIndex; // Per multiple choice

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Imposta i filtri
    gameProvider.setGameFilters(
      medium: widget.category == 'MIX' ? null : widget.category,
      gameMode: widget.mode,
      questionType: widget.gameType,
    );

    // Carica le domande
    await gameProvider.loadQuestions(
      questionType: widget.gameType,
      limit: widget.mode.toLowerCase() == 'zen' ? 100 : 20, // Zen mode = tante domande
    );

    // Avvia il timer se modalità tempo
    if (widget.mode.toLowerCase() == 'a tempo' || widget.mode.toLowerCase() == 'timed') {
      _startTimer();
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          if (_remainingSeconds <= 10) {
            AudioManager().playTimerTick();
          }
        } else {
          _timer?.cancel();
          AudioManager().playTimeUp();
          _showGameOverDialog();
        }
      });
    });
  }

  void _handleTrueFalseAnswer(bool answer) async {
    if (_showingFeedback) return;

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentQuestion = gameProvider.currentQuestion;

    if (currentQuestion == null) return;

    // Registra la risposta
    await gameProvider.answerQuestion(answer);

    // Verifica se la risposta è corretta
    final isCorrect = currentQuestion.correctAnswerAsBool == answer;

    // Mostra feedback
    _showAnswerFeedback(isCorrect, currentQuestion, null);
  }

  void _handleMultipleChoiceAnswer(int answerIndex) async {
    if (_showingFeedback) return;

    setState(() {
      _selectedAnswerIndex = answerIndex;
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final currentQuestion = gameProvider.currentQuestion;
    final currentAnswers = gameProvider.currentAnswers;

    if (currentQuestion == null || currentAnswers == null) return;

    // Registra la risposta
    await gameProvider.answerQuestion(answerIndex);

    // Verifica se la risposta è corretta
    final selectedAnswer = currentAnswers[answerIndex];
    final isCorrect = selectedAnswer.isCorrect;

    // Mostra feedback
    _showAnswerFeedback(isCorrect, currentQuestion, currentAnswers);
  }

  void _showAnswerFeedback(bool isCorrect, Question question, List<MultipleChoiceAnswer>? answers) {
    setState(() {
      _showingFeedback = true;
    });

    if (isCorrect) {
      AudioManager().playTransition();
    } else {
      AudioManager().playWrongAnswer();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;

        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isCorrect ? Colors.green : Colors.red,
              width: 3,
            ),
          ),
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? l10n.get('correct') : l10n.get('wrong'),
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isCorrect) ...[
                Text(
                  '${l10n.get('correct_answer_was')}:',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                if (question.type == 'true_false')
                  Text(
                    question.correctAnswerAsBool ? l10n.get('true') : l10n.get('false'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                else if (answers != null)
                  Text(
                    answers.firstWhere((a) => a.isCorrect).optionText,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 10),
              ],
              if (question.explanation != null && question.explanation!.isNotEmpty) ...[
                Text(
                  '${l10n.get('explanation')}:',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  question.explanation!,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                '+${isCorrect ? question.basePoints : 0} ${l10n.get('points')}',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nextQuestion();
              },
              child: Text(
                l10n.get('continue'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _nextQuestion() {
    setState(() {
      _showingFeedback = false;
      _selectedAnswerIndex = null;
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    if (gameProvider.isGameOver) {
      _showGameOverDialog();
    } else {
      gameProvider.nextQuestion();
    }
  }

  void _showGameOverDialog() {
    _timer?.cancel();

    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    AudioManager().playAchievement();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.purple, width: 3),
          ),
          title: Text(
            l10n.get('game_over'),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Punteggio
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.get('final_score'),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${gameProvider.score}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Statistiche
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatColumn(
                    Icons.check_circle,
                    Colors.green,
                    gameProvider.correctAnswers.toString(),
                    l10n.get('correct_answers'),
                  ),
                  _buildStatColumn(
                    Icons.cancel,
                    Colors.red,
                    gameProvider.wrongAnswers.toString(),
                    l10n.get('wrong_answers'),
                  ),
                  _buildStatColumn(
                    Icons.percent,
                    Colors.blue,
                    '${(gameProvider.accuracy * 100).toStringAsFixed(0)}%',
                    l10n.get('accuracy'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Torna al menu modalità
              },
              child: Text(
                l10n.get('menu'),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                  _remainingSeconds = 60;
                  _selectedAnswerIndex = null;
                });
                _initializeGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text(
                l10n.get('play_again'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatColumn(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gameProvider = Provider.of<GameProvider>(context);

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/theater_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  l10n.get('loading'),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = gameProvider.currentQuestion;
    if (currentQuestion == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/backgrounds/theater_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              l10n.get('no_questions'),
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/theater_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Progress
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${gameProvider.currentQuestionIndex + 1} / ${gameProvider.totalQuestions}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      // Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${l10n.get('points')}: ${gameProvider.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer (se modalità tempo)
                if (widget.mode.toLowerCase() == 'a tempo' || widget.mode.toLowerCase() == 'timed')
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _remainingSeconds <= 10 ? Colors.red : Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Question Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.5), width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Opera info
                        if (currentQuestion.operaName != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              currentQuestion.operaName!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Question
                        Flexible(
                          child: SingleChildScrollView(
                            child: Text(
                              currentQuestion.questionText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Answer options based on question type
                        if (currentQuestion.type == 'true_false')
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTrueFalseButton(
                                l10n.get('true').toUpperCase(),
                                Colors.green,
                                    () => _handleTrueFalseAnswer(true),
                              ),
                              _buildTrueFalseButton(
                                l10n.get('false').toUpperCase(),
                                Colors.red,
                                    () => _handleTrueFalseAnswer(false),
                              ),
                            ],
                          )
                        else if (currentQuestion.type == 'multiple_choice' && gameProvider.currentAnswers != null)
                          ..._buildMultipleChoiceOptions(gameProvider.currentAnswers!),
                      ],
                    ),
                  ),
                ),

                // Back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: GestureDetector(
                      onTap: () {
                        _timer?.cancel();
                        AudioManager().playNavigationBack();
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/icons/backicon.png',
                        width: 55,
                        height: 55,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrueFalseButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _showingFeedback ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(120, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildMultipleChoiceOptions(List<MultipleChoiceAnswer> answers) {
    return answers.asMap().entries.map((entry) {
      final index = entry.key;
      final answer = entry.value;

      Color buttonColor = Colors.deepPurple;
      Color borderColor = Colors.deepPurple;

      if (_showingFeedback) {
        if (answer.isCorrect) {
          buttonColor = Colors.green;
          borderColor = Colors.green;
        } else if (_selectedAnswerIndex == index) {
          buttonColor = Colors.red;
          borderColor = Colors.red;
        } else {
          buttonColor = Colors.grey.shade700;
          borderColor = Colors.grey.shade700;
        }
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showingFeedback ? null : () => _handleMultipleChoiceAnswer(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor.withOpacity(0.3),
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: borderColor,
                  width: 2,
                ),
              ),
              elevation: 3,
            ),
            child: Text(
              answer.optionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }).toList();
  }
}