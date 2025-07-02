/// Rappresenta una risposta per domande a scelta multipla
class MultipleChoiceAnswer {
  final int answerId;
  final int questionId;
  final String optionText;
  final bool isCorrect;

  MultipleChoiceAnswer({
    required this.answerId,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
  });

  factory MultipleChoiceAnswer.fromMap(Map<String, dynamic> map) {
    // Gestione sicura dei null e mapping corretto dei nomi colonne
    final answerId = map['answer_id'] != null ? map['answer_id'] as int : 0;
    final questionId = map['question_id'] != null ? map['question_id'] as int : 0;
    final optionText = map['option_text']?.toString() ?? '';
    final isCorrect = map['is_correct'] == true || map['is_correct'] == 1;

    return MultipleChoiceAnswer(
      answerId: answerId,
      questionId: questionId,
      optionText: optionText,
      isCorrect: isCorrect,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'answer_id': answerId,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect ? 1 : 0,
    };
  }
}