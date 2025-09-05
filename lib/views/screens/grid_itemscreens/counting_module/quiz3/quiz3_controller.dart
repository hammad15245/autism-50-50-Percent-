import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class SequenceController extends GetxController {
  // Game state
  var numbers = <int>[].obs;
  var selectedNumbers = <int>[].obs;
  var isCorrect = false.obs;
  var showCompletion = false.obs;
  var currentLevel = 1.obs;
  
  // TTS controller
  FlutterTts flutterTts = FlutterTts();
  var isTtsReady = false.obs;
  
  // Levels with different number sequences
  final List<Map<String, dynamic>> levels = [
    {
      "numbers": [1, 2, 3, 4],
      "instruction": "Arrange the numbers in order from smallest to largest"
    },
  
  ];

  @override
  void onInit() {
    super.onInit();
    initializeTts();
    resetGame();
  }

  Future<void> initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.7);
      await flutterTts.setVolume(1.0);
      
      isTtsReady.value = true;
      // Speak initial instructions
      speakInstructions();
    } catch (e) {
      print("Error initializing TTS: $e");
      isTtsReady.value = false;
    }
  }

  Future<void> speakInstructions() async {
    if (!isTtsReady.value) return;
    
    final instruction = levels[currentLevel.value - 1]["instruction"];
    await flutterTts.speak(instruction);
  }

  Future<void> speakMessage(String message) async {
    if (!isTtsReady.value) return;
    
    await flutterTts.speak(message);
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
      showCompletion.value = true;
      speakMessage("Excellent! You arranged the numbers correctly!");
      
      Get.snackbar(
        "Perfect! 🎉",
        "You arranged the numbers in correct sequence!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

    void checkAnswerAndNavigate() {
     Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen
      // Get.to(() => const countingsequence());
      

    });
}

  void nextLevel() {
    if (currentLevel.value < levels.length) {
      currentLevel.value++;
      resetGame();
    } else {
      // All levels completed
      speakMessage("Congratulations! You completed all sequencing levels!");
      Get.snackbar(
        "All Levels Completed! 🏆",
        "You mastered number sequencing!",
        backgroundColor: Colors.blue.shade300,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  void previousLevel() {
    if (currentLevel.value > 1) {
      currentLevel.value--;
      resetGame();
    }
  }

  List<int> getCorrectSequence() {
    return List<int>.from(levels[currentLevel.value - 1]["numbers"]);
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}