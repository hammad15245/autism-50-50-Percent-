import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class Quiz4Controller extends GetxController {
  // Images for left and right columns
  // Correct answers mapping: key = leftIndex, value = rightIndex
  final Map<int, int> correctPairs = {
    0: 3,
    1: 0,
    2: 1,
    3: 2,
    4: 4,
  };

  // User selected matches: key = leftIndex, value = rightIndex
  var userPairs = <int, int>{}.obs;

  // For feedback: 0 = no feedback, 1 = correct, -1 = incorrect
  var feedback = <int, int>{}.obs;

  // Correct answers count
  var correctCount = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var hasSubmitted = false.obs;
  var isChecking = false.obs;

  final audioService = AudioInstructionService.to;
  final brushingTeethController = Get.find<BrushingTeethModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Great now lets Match the items correctly! Drag from left to right to make pairs.",

      );
    });
  }

  void selectMatch(int leftIndex, int rightIndex) {
    userPairs[leftIndex] = rightIndex;
    
    // Play selection sound
    // audioService.playSoundEffect("brushing_teeth_audios/selection.mp3");
  }

  void checkAnswers() {
    isChecking.value = true;
    hasSubmitted.value = true;
    correctCount.value = 0;
    wrongAnswersCount.value = 0;
    feedback.clear();

    userPairs.forEach((left, right) {
      if (correctPairs[left] == right) {
        feedback[left] = 1; // Correct
        correctCount.value++;
      } else {
        feedback[left] = -1; // Incorrect
        wrongAnswersCount.value++;
        
        // Record wrong answer
        brushingTeethController.recordWrongAnswer(
          quizId: "quiz4",
          questionId: "Pair $left",
          wrongAnswer: "Matched with $right",
          correctAnswer: "Should match with ${correctPairs[left]}",
        );
      }
    });

    // Play feedback based on results
    if (correctCount.value == correctPairs.length) {
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Perfect! You matched all ${correctPairs.length} pairs correctly!",
      );
      
      _recordQuizResult();
      
      Future.delayed(const Duration(seconds: 3), () {
        Get.to(() =>  Quiz5Screen());
      });
      
    } else if (correctCount.value >= correctPairs.length * 0.7) {
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Good job! You got ${correctCount.value} out of ${correctPairs.length} pairs correct.",
      );
      
      // Record quiz result
      _recordQuizResult();
      
    } else {
      audioService.playIncorrectFeedback();
      audioService.setInstructionAndSpeak(
        "You got ${correctCount.value} out of ${correctPairs.length}. Let's try again!",
      );
      
      retries.value++;
    }

    isChecking.value = false;
  }

  void _recordQuizResult() {
    final isCompleted = correctCount.value >= correctPairs.length * 0.7;
    
    brushingTeethController.recordQuizResult(
      quizId: "quiz4",
      score: correctCount.value,
      retries: retries.value,
      isCompleted: isCompleted,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    brushingTeethController.syncModuleProgress();
  }

  void resetQuiz() {
    userPairs.clear();
    feedback.clear();
    correctCount.value = 0;
    wrongAnswersCount.value = 0;
    hasSubmitted.value = false;
    retries.value++;
    
    audioService.setInstructionAndSpeak(
      "Let's try matching again!",
    );
  }

  // Get completion percentage
  double getCompletionPercentage() {
    return correctCount.value / correctPairs.length;
  }

  // Check if all pairs are matched
  bool get allPairsMatched {
    return userPairs.length == correctPairs.length;
  }

  // Get feedback color for a specific left item
  Color getFeedbackColor(int leftIndex) {
    if (!feedback.containsKey(leftIndex)) return Colors.transparent;
    
    switch (feedback[leftIndex]) {
      case 1:
        return Colors.green.shade100;
      case -1:
        return Colors.red.shade100;
      default:
        return Colors.transparent;
    }
  }

  // Get feedback icon for a specific left item
  IconData? getFeedbackIcon(int leftIndex) {
    if (!feedback.containsKey(leftIndex)) return null;
    
    switch (feedback[leftIndex]) {
      case 1:
        return Icons.check;
      case -1:
        return Icons.close;
      default:
        return null;
    }
  }

  Color getFeedbackIconColor(int leftIndex) {
    if (!feedback.containsKey(leftIndex)) return Colors.transparent;
    
    switch (feedback[leftIndex]) {
      case 1:
        return Colors.green;
      case -1:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}