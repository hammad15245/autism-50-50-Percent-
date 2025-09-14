import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';

class AlphabetQuizController extends GetxController {
  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  var currentLetterIndex = 0.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // ✅ Only A → D now
  final List<String> letters = ['A', 'B', 'C', 'D'];

  final Map<String, List<String>> fuzzyLetterMap = {
    'A': ['A', 'AY', 'EH', 'EI'],
    'B': ['B', 'BE', 'BI', 'BEE'],
    'C': ['C', 'SEE', 'SI', 'SEA'],
    'D': ['D', 'DEE', 'DI', 'DE'],
  };

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, _speakCurrentLetter);
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }

  void _speakCurrentLetter() {
    final letter = letters[currentLetterIndex.value];
    audioService.setInstructionAndSpeak(
      "Hey kiddos! Let's learn the letter $letter. Repeat after me: $letter.",
    );
  }

  /// ✅ Check pronunciation and drill user if wrong
  void checkLetterPronunciation({
    required String spokenText,
    required VoidCallback onCorrect,
    required VoidCallback onIncorrect,
  }) async {
    final targetLetter = letters[currentLetterIndex.value];
    final cleanedText = spokenText.trim().toUpperCase();
    final acceptableVariants = fuzzyLetterMap[targetLetter] ?? [targetLetter];
    print("STT raw result: $spokenText");

    if (acceptableVariants.any((variant) => cleanedText.contains(variant))) {
      await _playCorrectFeedback(onCorrect);
    } else {
      await _playDrillFeedback(cleanedText, onIncorrect);
    }
  }

  /// ✅ Correct pronunciation feedback (with 5s delay before moving on)
  Future<void> _playCorrectFeedback(VoidCallback onCorrect) async {
    audioService.playCorrectFeedback(
        message: "Excellent! You pronounced it correctly!");
    onCorrect();

    // ✅ Wait 5 seconds before automatically moving to next letter
    await Future.delayed(const Duration(seconds: 5));
    nextLetter();
  }

  /// 🔄 Drill for incorrect pronunciation
  Future<void> _playDrillFeedback(
      String spokenText, VoidCallback onIncorrect) async {
    wrongAttempts.value++;
    retries.value++;

    final targetLetter = letters[currentLetterIndex.value];

    abcModuleController.recordWrongAnswer(
      quizId: "speech_quiz",
      questionId: "Letter $targetLetter pronunciation",
      wrongAnswer: "Said: $spokenText",
      correctAnswer: "Should say: $targetLetter",
    );

    await audioService.playIncorrectFeedback(
      message:
          "Oops! That wasn't correct. Let's try saying $targetLetter slowly.",
    );

    await Future.delayed(const Duration(seconds: 2));
    audioService.setInstructionAndSpeak(
      "Say the letter $targetLetter clearly. Repeat after me: $targetLetter.",
    );

    onIncorrect();
  }

  /// ➡ Move to next letter or complete the quiz
  void nextLetter() {
    if (currentLetterIndex.value < letters.length - 1) {
      currentLetterIndex.value++;
      _speakCurrentLetter();
    } else {
      completeQuiz();
    }
  }

  /// ✅ Complete the quiz
  void completeQuiz() {
    final totalLetters = letters.length;

    abcModuleController.recordQuizResult(
      quizId: "speech_quiz",
      score: totalLetters,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );

    abcModuleController.syncModuleProgress();

    audioService.playCorrectFeedback(
        message: "Amazing! You pronounced all letters correctly!");
    Get.snackbar(
      "Congratulations! 🎉",
      "You completed the alphabet quiz!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void repeatInstruction() => _speakCurrentLetter();

  void resetQuiz() {
    currentLetterIndex.value = 0;
    retries.value = 0;
    wrongAttempts.value = 0;
    _speakCurrentLetter();
  }
}
