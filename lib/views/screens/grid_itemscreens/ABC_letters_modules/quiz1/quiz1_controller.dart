import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AlphabetQuizController extends GetxController {
  // Quiz state
  var hasAnswered = false.obs;
  var selectedIndex = (-1).obs;
  var correctIndex = 0.obs; // index of correct answer

  // Options for the quiz
  final List<String> options = ['A', 'B', 'C', 'D'];
  final String correctAnswer = 'A';

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    // Initialize correct index based on correct answer
    correctIndex.value = options.indexOf(correctAnswer);
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  // Handle answer selection
  void selectAnswer(int index) {
    if (!hasAnswered.value) {
      selectedIndex.value = index;
      hasAnswered.value = true;
    }
  }

  // Get color for each button
  Color getButtonColor(int index) {
    if (!hasAnswered.value) return const Color(0xFF0E83AD);

    if (index == selectedIndex.value) {
      return index == correctIndex.value ? Colors.green : Colors.red;
    }

    // Show correct answer green after selection
    if (hasAnswered.value && index == correctIndex.value) {
      return Colors.green;
    }

    return const Color(0xFF0E83AD); // default blue
  }

  // Play letter sound

  
  Future<void> playLetter(AssetSource source) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint("Error playing letter sound: $e");
    }
  }

  // Reset quiz state (optional)
  void resetQuiz() {
    hasAnswered.value = false;
    selectedIndex.value = -1;
  }
}



// Controller only for playing letter voice

