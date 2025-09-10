import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class Quiz4matchingController extends GetxController {
  // Images for left and right columns

  // Correct answers mapping: key = leftIndex, value = rightIndex
  final Map<int, int> correctPairs = {
    0: 0,
    1: 4,
    2: 3,
    3: 2,
    4: 1,
  };

  // User selected matches: key = leftIndex, value = rightIndex
  var userPairs = <int, int>{}.obs;

  // For feedback: 0 = no feedback, 1 = correct, -1 = incorrect
  var feedback = <int, int>{}.obs;

  // Correct answers count
  var correctCount = 0.obs;

  // Progress tracking
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;
  var totalPairs = 5.obs;

  // Audio service
  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var isChecking = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Match the letters with their correct pairs! Drag and connect matching items.",
        "goingbed_audios/matching_intro.mp3",
      );
    });
  }

  void selectMatch(int leftIndex, int rightIndex) {
    if (hasSubmitted.value) return; // Don't allow changes after submission
    
    userPairs[leftIndex] = rightIndex;
    
    // Play selection sound
    // audioService.playSoundEffect("abc_audios/selection.mp3");
  }

  void checkAnswers() {
    if (hasSubmitted.value) return;
    
    isChecking.value = true;
    correctCount.value = 0;
    feedback.clear();
    wrongAttempts.value = 0;

    userPairs.forEach((left, right) {
      if (correctPairs[left] == right) {
        feedback[left] = 1; // Correct
        correctCount.value++;
        
        // Play correct feedback for each correct pair
        audioService.playCorrectFeedback();
      } else {
        feedback[left] = -1; // Incorrect
        wrongAttempts.value++;
        
        // Record wrong answer
        abcModuleController.recordWrongAnswer(
          quizId: "quiz4",
          questionId: "Matching pair ${left + 1}",
          wrongAnswer: "Incorrect match selection",
          correctAnswer: "Should match with correct pair",
        );
        
        // Play incorrect feedback
        audioService.playIncorrectFeedback();
      }
    });

    // Check if all pairs are correct
    if (correctCount.value == totalPairs.value) {
      completeQuiz();
    } else {
      // Provide feedback for incomplete or incorrect matches
      if (userPairs.length < totalPairs.value) {
        audioService.setInstructionAndSpeak(
          "You matched ${correctCount.value} out of $totalPairs. Complete all pairs!",
          "abc_audios/matching_incomplete.mp3",
        );
      } else {
        audioService.setInstructionAndSpeak(
          "You got ${correctCount.value} correct! Try to fix the incorrect matches.",
          "abc_audios/matching_some_wrong.mp3",
        );
      }
    }

    isChecking.value = false;
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Perfect matching! You connected all pairs correctly!",
      "abc_audios/matching_complete.mp3",
    );
    
    // Record quiz result
    abcModuleController.recordQuizResult(
      quizId: "quiz4",
      score: correctCount.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
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
      "abc_audios/matching_retry.mp3",
    );
  }

  void submitAndNavigate() {
    if (userPairs.length < totalPairs.value) {
      audioService.playIncorrectFeedback();
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
    
    if (correctCount.value == totalPairs.value) {
      // Navigate to next screen after a delay
      Future.delayed(const Duration(seconds: 2), () {
        // Get.to(() => NextScreen()); // Uncomment and add your next screen
      });
    }
  }

  // Get progress percentage
  double getProgressPercentage() {
    return userPairs.length / totalPairs.value;
  }

  // Get correct matches percentage
  double getCorrectPercentage() {
    return correctCount.value / totalPairs.value;
  }

  // Get remaining pairs count
  int getRemainingPairs() {
    return totalPairs.value - userPairs.length;
  }

  // Check if a left item is matched
  bool isLeftItemMatched(int leftIndex) {
    return userPairs.containsKey(leftIndex);
  }

  // Check if a right item is matched
  bool isRightItemMatched(int rightIndex) {
    return userPairs.containsValue(rightIndex);
  }

  // Allow screen to call .answers.length
  Map<int, int> get answers => userPairs;

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}