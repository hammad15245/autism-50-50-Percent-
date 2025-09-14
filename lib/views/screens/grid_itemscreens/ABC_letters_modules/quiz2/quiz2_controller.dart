import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BubbleQuizController extends GetxController {
  var options = ['A', 'B', '1', '2', 'C', '3'].obs;
  var answers = <bool?>[null, null, null, null, null, null].obs;
  final List<bool> correctAnswers = [true, true, false, false, true, false];

  var retries = 0.obs;
  var wrongSelections = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Great! Now let's find all the letters. Tap on the letters and avoid numbers."
      );
    });

    initializeAnswers();
  }

  void initializeAnswers() {
    answers.value = [null, null, null, null, null, null];
  }

  void checkAnswerAndNavigate() {
    if (answers.contains(true)) {
      final correctCount = answers.where((answer) => answer == true).length;
      final wrongCount = answers.where((answer) => answer == false).length;

      completeQuiz(correctCount, wrongCount);

      Get.to(() => const SoundRecognitionScreen());
    } else {
      audioService.playIncorrectFeedback();
      Get.snackbar(
        "Incomplete",
        "Please select at least one letter before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void selectAnswer(int index) {
    if (answers[index] != null || hasSubmitted.value) return;

    final isCorrect = correctAnswers[index];
    answers[index] = isCorrect;

    if (isCorrect) {
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
      wrongSelections.value++;

      abcModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Bubble item ${index + 1}",
        wrongAnswer: "Selected ${options[index]} (number)",
        correctAnswer: "Should select letters only",
      );
    }
  }

  void completeQuiz(int correctCount, int wrongCount) {
    showCompletion.value = true;
    hasSubmitted.value = true;

    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Great job! You found $correctCount letters!"
    );

    abcModuleController.recordQuizResult(
      quizId: "quiz2",
      score: correctCount,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongCount,
    );

    abcModuleController.syncModuleProgress();

    Get.snackbar(
      "Well done! 🎉",
      "You found $correctCount letters!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void resetQuiz() {
    initializeAnswers();
    retries.value++;
    wrongSelections.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;

    audioService.setInstructionAndSpeak(
      "Let's try finding the letters again! Remember, letters are A, B, C — not numbers."
    );
  }

  bool isAnswered(int index) => answers[index] != null;

  bool isCorrectAnswer(int index) => correctAnswers[index];

  double getProgressPercentage() {
    final answeredCount = answers.where((answer) => answer != null).length;
    return answeredCount / answers.length;
  }

  int getCorrectAnswersCount() {
    return answers.where((answer) => answer == true).length;
  }

  int getRemainingLetters() {
    final totalLetters = correctAnswers.where((isLetter) => isLetter).length;
    return totalLetters - getCorrectAnswersCount();
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
