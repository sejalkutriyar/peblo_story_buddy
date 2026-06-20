class QuizModel {
  final String question;
  final List<String> options;
  final String answer;

  QuizModel({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}