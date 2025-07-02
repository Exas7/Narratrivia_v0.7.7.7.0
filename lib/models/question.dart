import 'opera.dart';

/// Modello base per una domanda
class Question {
  final int questionId;
  final String type;
  final String difficulty;
  final String questionText;
  final String? correctAnswer; // Nullable per le domande multiple choice
  final String? explanation;
  final int operaId;
  final String? imagePath;
  final int timesShown;
  final int timesCorrect;

  // Relazioni opzionali (popolate con JOIN)
  Opera? opera;
  String? operaName;
  String? universeName;
  String? mediumName;

  Question({
    required this.questionId,
    required this.type,
    required this.difficulty,
    required this.questionText,
    this.correctAnswer,
    this.explanation,
    required this.operaId,
    this.imagePath,
    this.timesShown = 0,
    this.timesCorrect = 0,
    this.opera,
    this.operaName,
    this.universeName,
    this.mediumName,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionId: map['question_id'] as int,
      type: map['type'] as String,
      difficulty: map['difficulty'] as String,
      questionText: map['question_text'] as String,
      correctAnswer: map['correct_answer'] as String?,
      explanation: map['explanation'] as String?,
      operaId: map['opera_id'] as int,
      imagePath: map['image_path'] as String?,
      timesShown: map['times_shown'] as int? ?? 0,
      timesCorrect: map['times_correct'] as int? ?? 0,
      operaName: map['opera_name'] as String?,
      universeName: map['universe_name'] as String?,
      mediumName: map['medium_name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'type': type,
      'difficulty': difficulty,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'opera_id': operaId,
      'image_path': imagePath,
      'times_shown': timesShown,
      'times_correct': timesCorrect,
    };
  }

  /// Converte il valore correct_answer in bool per domande true/false
  bool get correctAnswerAsBool {
    if (correctAnswer == null) return false;
    return correctAnswer!.toLowerCase() == 'true' ||
        correctAnswer == '1' ||
        correctAnswer!.toLowerCase() == 'vero';
  }

  /// Ottiene i punti base in base alla difficoltà
  int get basePoints {
    switch (difficulty.toLowerCase()) {
      case 'easy':
      case 'facile':
        return 10;
      case 'normal':
      case 'medium':
      case 'medio':
        return 20;
      case 'hard':
      case 'difficile':
        return 30;
      case 'expert':
      case 'esperto':
        return 50;
      default:
        return 10;
    }
  }

  /// Compatibilità con il vecchio getter 'id'
  int get id => questionId;
}