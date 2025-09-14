import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class FindLetterController extends GetxController {
  var targetLetters = ["A", "B", "C", "D", "E", "F"].obs;
  var currentIndex = 0.obs;
  var targetLetter = "A".obs;

  var allCollectedLetters = <String>[].obs;
  var currentCollectedLetters = <String>[].obs;
  var correctlyCollectedLetters = <String>[].obs;
  var temporarilyIncorrectLetters = <String>[].obs;

  var isCorrect = false.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  // Audio service
  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  // Instruction TTS (used for main instructions)
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // New observable for feedback-only audio (doesn't affect instruction text)
  var isFeedbackPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Ok kiddos! Let's find hidden letters. Tap on the letter ${targetLetter.value}."
      );
    });
  }

  void nextLetter() {
    if (currentIndex.value < targetLetters.length - 1) {
      currentIndex.value++;
      targetLetter.value = targetLetters[currentIndex.value];
      currentCollectedLetters.clear();
      isCorrect.value = false;

      audioService.setInstructionAndSpeak(
        "Great! Now find the letter ${targetLetter.value}."
      );
    } else {
      completeQuiz();
    }
  }

  void onLetterTapped(String letter) async {
    if (allCollectedLetters.contains(letter)) return;

    allCollectedLetters.add(letter);
    currentCollectedLetters.add(letter);

    if (letter == targetLetter.value) {
      correctlyCollectedLetters.add(letter);
      isCorrect.value = true;

      _playFeedback(() async {
        await audioService.playCorrectFeedback();
      });

      playLetterSound(letter);

      Get.snackbar(
        "Correct!",
        "You found the letter $letter 🎉",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 2), nextLetter);
    } else {
      isCorrect.value = false;
      wrongAttempts.value++;
      temporarilyIncorrectLetters.add(letter);

      _playFeedback(() async {
        await audioService.playIncorrectFeedback();
      });

      abcModuleController.recordWrongAnswer(
        quizId: "quiz3",
        questionId: "Find letter ${targetLetter.value}",
        wrongAnswer: "Selected $letter",
        correctAnswer: "Should select ${targetLetter.value}",
      );

      Get.snackbar(
        "Try Again",
        "$letter is not the right letter. Look for ${targetLetter.value}",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );

      Future.delayed(const Duration(seconds: 1), () {
        temporarilyIncorrectLetters.remove(letter);
      });
    }
  }

  void playLetterSound(String letter) {
    // Add optional letter sound playback using AI or local asset if needed
    // Example: audioService.playLetter(letter);
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;

    _playFeedback(() async {
      await audioService.playCorrectFeedback();
    });

    audioService.setInstructionAndSpeak(
      "Amazing! You found all the letters from A to F!"
    );

    abcModuleController.recordQuizResult(
      quizId: "quiz3",
      score: correctlyCollectedLetters.length,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );

    abcModuleController.syncModuleProgress();

    Get.snackbar(
      "Congratulations!",
      "You found all the letters! 🎉",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
    );
  }

  void checkAnswerAndNavigate() {
    if (allCollectedLetters.length >= targetLetters.length) {
      completeQuiz();
      Get.to(() => const SoundRecognitionScreen());
    } else {
      _playFeedback(() async {
        await audioService.playIncorrectFeedback();
      });

      Get.snackbar(
        "Incomplete",
        "Please find all the letters before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void resetQuiz() {
    currentIndex.value = 0;
    targetLetter.value = "A";
    allCollectedLetters.clear();
    currentCollectedLetters.clear();
    correctlyCollectedLetters.clear();
    temporarilyIncorrectLetters.clear();
    isCorrect.value = false;
    retries.value++;
    wrongAttempts.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;

    audioService.setInstructionAndSpeak(
      "Let's try finding all the letters again! Start with letter A."
    );
  }

  double getProgressPercentage() =>
      allCollectedLetters.length / targetLetters.length;

  int getRemainingLetters() =>
      targetLetters.length - allCollectedLetters.length;

  String getCurrentTargetProgress() =>
      "${currentIndex.value + 1}/${targetLetters.length}";

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }

  /// Wrap feedback so we can track when it's playing
  void _playFeedback(Future<void> Function() playFn) async {
    if (isFeedbackPlaying.value) return;
    isFeedbackPlaying.value = true;
    await playFn();
    isFeedbackPlaying.value = false;
  }
}
