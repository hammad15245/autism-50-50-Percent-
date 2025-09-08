import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/counting_module_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class SequenceController extends GetxController {
  // Game state
  var numbers = <int>[].obs;
  var selectedNumbers = <int>[].obs;
  var isCorrect = false.obs;
  var showCompletion = false.obs;
  var currentLevel = 1.obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  
  final audioService = AudioInstructionService.to;
  final countingModuleController = Get.find<CountingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;
  
  // Levels with different number sequences
  final List<Map<String, dynamic>> levels = [
    {
      "numbers": [1, 2, 3, 4],
      "instruction": "Arrange the numbers in order from smallest to largest",
      "audio": "counting_audios/sequence_level1.mp3"
    },
    {
      "numbers": [1, 3, 5, 7],
      "instruction": "Arrange the odd numbers in order",
      "audio": "counting_audios/sequence_level2.mp3"
    },
    {
      "numbers": [2, 4, 6, 8],
      "instruction": "Arrange the even numbers in order",
      "audio": "counting_audios/sequence_level3.mp3"
    },
    {
      "numbers": [5, 4, 3, 2],
      "instruction": "Arrange the numbers in reverse order",
      "audio": "counting_audios/sequence_level4.mp3"
    },
    {
      "numbers": [1, 2, 4, 8],
      "instruction": "Arrange the numbers in doubling order",
      "audio": "counting_audios/sequence_level5.mp3"
    },
  ];

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "kiddos! Let's learn number sequences! Arrange the numbers in the correct order.",
        "goingbed_audios/sequence_intro.mp3",
      );
    });
    
    resetGame();
  }

  void resetGame() {
    final levelData = levels[currentLevel.value - 1];
    final originalNumbers = List<int>.from(levelData["numbers"]);
    
    // Shuffle numbers for the game
    numbers.value = List<int>.from(originalNumbers)..shuffle();
    selectedNumbers.clear();
    isCorrect.value = false;
    showCompletion.value = false;
    
    // Speak instructions when game resets
    speakInstructions();
  }

  Future<void> speakInstructions() async {
    final levelData = levels[currentLevel.value - 1];
    final instruction = levelData["instruction"];
    
    if (levelData.containsKey("audio")) {
      audioService.setInstructionAndSpeak(
        instruction,
        levelData["audio"],
      );
    } else {
      // audioService.speak(instruction);
    }
  }

  void selectNumber(int number) {
    if (selectedNumbers.contains(number)) return;
    
    selectedNumbers.add(number);
    checkSequence();
  }

  void removeNumber(int number) {
    selectedNumbers.remove(number);
    isCorrect.value = false;
  }

  void checkSequence() {
    if (selectedNumbers.length != numbers.length) return;
    
    // Check if selected numbers are in correct order
    final correctSequence = List<int>.from(levels[currentLevel.value - 1]["numbers"]);
    bool correct = true;
    
    for (int i = 0; i < selectedNumbers.length; i++) {
      if (selectedNumbers[i] != correctSequence[i]) {
        correct = false;
        break;
      }
    }
    
    isCorrect.value = correct;
    
    if (correct) {
      score.value++;
      showCompletion.value = true;
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Excellent! You arranged the numbers $correctSequence correctly!",
        "counting_audios/sequence_correct.mp3",
      );
      
      Get.snackbar(
        "Perfect! 🎉",
        "You arranged the numbers in correct sequence!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Complete level after delay
      Future.delayed(const Duration(seconds: 3), () {
        completeLevel();
      });
    } else {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      countingModuleController.recordWrongAnswer(
        quizId: "quiz3",
        questionId: "Level ${currentLevel.value} sequence",
        wrongAnswer: selectedNumbers.join(", "),
        correctAnswer: correctSequence.join(", "),
      );
      
      audioService.setInstructionAndSpeak(
        "That's not quite right. Try again to arrange $correctSequence",
        "counting_audios/sequence_incorrect.mp3",
      );
    }
  }

  void completeLevel() {
    final isLevelCompleted = isCorrect.value;
    final levelScore = isLevelCompleted ? 1 : 0; // 1 point per completed level
    
    // Record level result
    countingModuleController.recordQuizResult(
      quizId: "quiz3_level${currentLevel.value}",
      score: levelScore,
      retries: retries.value,
      isCompleted: isLevelCompleted,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    if (currentLevel.value == levels.length) {
      // All levels completed - sync progress and show final completion
      countingModuleController.syncModuleProgress();
      
      audioService.setInstructionAndSpeak(
        "Congratulations! You completed all sequencing levels with $score out of ${levels.length} correct!",
        "counting_audios/sequence_all_complete.mp3",
      );
      
      Get.snackbar(
        "All Levels Completed! 🏆",
        "You mastered number sequencing! Score: $score/${levels.length}",
        backgroundColor: Colors.blue.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } else {
      // Move to next level
      nextLevel();
    }
  }

  void nextLevel() {
    if (currentLevel.value < levels.length) {
      currentLevel.value++;
      wrongAttempts.value = 0; // Reset wrong attempts for new level
      resetGame();
    }
  }

  void previousLevel() {
    if (currentLevel.value > 1) {
      currentLevel.value--;
      wrongAttempts.value = 0; // Reset wrong attempts for previous level
      resetGame();
    }
  }

  void retryLevel() {
    retries.value++;
    wrongAttempts.value = 0;
    resetGame();
    
    audioService.setInstructionAndSpeak(
      "Let's try this level again! Remember the correct sequence.",
      "counting_audios/sequence_retry.mp3",
    );
  }

  void checkAnswerAndNavigate() {
    if (currentLevel.value == levels.length && showCompletion.value) {
      // Sync final progress before navigating
      countingModuleController.syncModuleProgress();
      
      Future.delayed(const Duration(seconds: 3), () {
        // Get.to(() => const NextScreen());
      });
    }
  }

  List<int> getCorrectSequence() {
    return List<int>.from(levels[currentLevel.value - 1]["numbers"]);
  }

  // Get current level progress
  double getLevelProgress() {
    return currentLevel.value / levels.length;
  }

  // Speak individual number
  void speakNumber(int number) {
    // audioService.speak("$number");
  }

  // Replay instructions
  void replayInstructions() {
    speakInstructions();
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}