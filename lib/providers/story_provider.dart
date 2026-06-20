import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

enum AudioState { idle, loading, playing, completed, error }

class StoryItem {
  final String text;
  final QuizModel quiz;
  StoryItem({required this.text, required this.quiz});
}

class StoryProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();

  AudioState audioState = AudioState.idle;
  bool quizVisible = false;
  String? selectedAnswer;
  bool isCorrect = false;
  bool showSuccess = false;
  int shakeCount = 0;
  int score = 120;
  int pointsJustAdded = 0;
  bool pointsButtonPressed = false;

  final List<StoryItem> stories = [
    StoryItem(
      text: "Once upon a time, a clever little robot named Pip "
          "lost his shiny blue gear in the Whispering Woods...",
      quiz: QuizModel.fromJson({
        "question": "What colour was Pip the Robot's lost gear?",
        "options": ["Red", "Green", "Blue", "Yellow"],
        "answer": "Blue"
      }),
    ),
    StoryItem(
      text: "Deep in the Whispering Woods, Pip met a wise old owl "
          "named Hoot, who knew exactly where shiny things liked to hide...",
      quiz: QuizModel.fromJson({
        "question": "What was the name of the wise owl?",
        "options": ["Hoot", "Whoosh", "Sage", "Feather"],
        "answer": "Hoot"
      }),
    ),
    StoryItem(
      text: "Pip and Hoot followed a trail of sparkling dust to a hollow "
          "tree, where three friendly squirrels were playing with his gear...",
      quiz: QuizModel.fromJson({
        "question": "How many squirrels were playing with the gear?",
        "options": ["Two", "Three", "Four", "Five"],
        "answer": "Three"
      }),
    ),
  ];

  int currentStoryIndex = 0;

  StoryItem get currentStory => stories[currentStoryIndex];
  String get storyText => currentStory.text;
  QuizModel get quiz => currentStory.quiz;

  StoryProvider() {
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.1);

    _tts.setCompletionHandler(() {
      audioState = AudioState.completed;
      quizVisible = true;
      notifyListeners();
    });

    _tts.setErrorHandler((error) {
      audioState = AudioState.error;
      notifyListeners();
    });
  }

  Future<void> playStory() async {
    if (audioState == AudioState.playing) return;
    audioState = AudioState.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      audioState = AudioState.playing;
      notifyListeners();
      await _tts.speak(storyText);
    } catch (e) {
      audioState = AudioState.error;
      notifyListeners();
    }
  }

  void checkAnswer(String selected) {
    if (showSuccess) return;
    selectedAnswer = selected;
    if (selected == quiz.answer) {
      isCorrect = true;
      showSuccess = true;
      pointsJustAdded = 10;
    } else {
      isCorrect = false;
      shakeCount++;
    }
    notifyListeners();
  }

  void claimPoints() {
    if (pointsButtonPressed) return;
    pointsButtonPressed = true;
    score += pointsJustAdded;
    notifyListeners();
  }

  void nextStory() {
    if (currentStoryIndex < stories.length - 1) {
      currentStoryIndex++;
    } else {
      currentStoryIndex = 0;
    }
    audioState = AudioState.idle;
    quizVisible = false;
    selectedAnswer = null;
    isCorrect = false;
    showSuccess = false;
    pointsJustAdded = 0;
    pointsButtonPressed = false;
    notifyListeners();
  }

  void retryAudio() {
    audioState = AudioState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}