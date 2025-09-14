import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class Quiz4matchingController extends GetxController {
  final Map<int, int> correctPairs = {
    0: 0,
    1: 4,
    2: 3,
    3: 2,
    4: 1,
  };

  var userPairs = <int, int>{}.obs;
  var feedback = <int, int>{}.obs;
  var correctCount = 0.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;
  var totalPairs = 5.obs;
  var isChecking = false.obs;

  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // Separate flag for short feedback sounds
  var isFeedbackPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Match the letters with their correct pairs! Drag and connect matching items.",
      );
    });
  }

  void selectMatch(int leftIndex, int rightIndex) {
    if (hasSubmitted.value) return;
    userPairs[leftIndex] = rightIndex;
  }

  void checkAnswers() async {
    if (hasSubmitted.value) return;

    isChecking.value = true;
    correctCount.value = 0;
    feedback.clear();
    wrongAttempts.value = 0;

    for (final entry in userPairs.entries) {
      final left = entry.key;
      final right = entry.value;

      if (correctPairs[left] == right) {
        feedback[left] = 1;
        correctCount.value++;

        _playFeedback(() async {
          await audioService.playCorrectFeedback();
        });
      } else {
        feedback[left] = -1;
        wrongAttempts.value++;

        abcModuleController.recordWrongAnswer(
          quizId: "quiz4",
          questionId: "Matching pair ${left + 1}",
          wrongAnswer: "Incorrect match selection",
          correctAnswer: "Should match with correct pair",
        );

        _playFeedback(() async {
          await audioService.playIncorrectFeedback();
        });
      }
    }

    if (correctCount.value == totalPairs.value) {
      completeQuiz();
    } else {
      // Only update main instruction text once, after checking all pairs
      if (userPairs.length < totalPairs.value) {
        audioService.setInstructionAndSpeak(
          "You matched ${correctCount.value} out of ${totalPairs.value}. Complete all pairs!",
        );
      } else {
        audioService.setInstructionAndSpeak(
          "You got ${correctCount.value} correct! Try to fix the incorrect matches.",
        );
      }
    }

    isChecking.value = false;
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;

    _playFeedback(() async {
      await audioService.playCorrectFeedback();
    });

    audioService.setInstructionAndSpeak(
      "Perfect matching! You connected all pairs correctly!",
    );

    abcModuleController.recordQuizResult(
      quizId: "quiz4",
      score: correctCount.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );

    abcModuleController.syncModuleProgress();

    Get.snackbar(
      "Excellent! 🎉",
      "You matched all pairs perfectly!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void resetQuiz() {
    userPairs.clear();
    feedback.clear();
    correctCount.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;
    retries.value++;
    wrongAttempts.value = 0;

    audioService.setInstructionAndSpeak(
      "Let's try matching again! Drag items to their correct pairs.",
    );
  }

  void submitAndNavigate() {
    if (userPairs.length < totalPairs.value) {
      _playFeedback(() async {
        await audioService.playIncorrectFeedback();
      });

      Get.snackbar(
        "Incomplete",
        "Please match all pairs before submitting.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
      );
      return;
    }

    checkAnswers();
  }

  double getProgressPercentage() => userPairs.length / totalPairs.value;
  double getCorrectPercentage() => correctCount.value / totalPairs.value;
  int getRemainingPairs() => totalPairs.value - userPairs.length;
  bool isLeftItemMatched(int leftIndex) => userPairs.containsKey(leftIndex);
  bool isRightItemMatched(int rightIndex) => userPairs.containsValue(rightIndex);
  Map<int, int> get answers => userPairs;

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }

  /// Helper to prevent overlapping feedback audio
  void _playFeedback(Future<void> Function() playFn) async {
    if (isFeedbackPlaying.value) return;
    isFeedbackPlaying.value = true;
    await playFn();
    isFeedbackPlaying.value = false;
  }
}
