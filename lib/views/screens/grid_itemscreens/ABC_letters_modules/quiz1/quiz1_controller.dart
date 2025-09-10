import 'package:audioplayers/audioplayers.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class AlphabetQuizController extends GetxController {
  // Quiz state
  var hasAnswered = false.obs;
  var selectedIndex = (-1).obs;
  var correctIndex = 0.obs; // index of correct answer
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  // Options for the quiz
  final List<String> options = ['A', 'B', 'C', 'D'];
  final String correctAnswer = 'A';

  // Audio players
  final AudioPlayer _audioPlayer = AudioPlayer();
  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    // Initialize correct index based on correct answer
    correctIndex.value = options.indexOf(correctAnswer);
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddos Lets learn the letter A! Tap the correct letter.",
        "goingbed_audios/letter_a_intro.mp3",
      );
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    audioService.stopSpeaking();
    super.onClose();
  }

  // Handle answer selection
  void selectAnswer(int index) {
    if (!hasAnswered.value && !hasSubmitted.value) {
      selectedIndex.value = index;
      hasAnswered.value = true;
      
      final isCorrect = index == correctIndex.value;
      
      if (isCorrect) {
        // Play correct feedback
        audioService.playCorrectFeedback();
        audioService.setInstructionAndSpeak(
          "Great job! That's the letter A!",
          "abc_audios/letter_a_correct.mp3",
        );
        
        // Complete the quiz
        completeQuiz();
      } else {
        // Play incorrect feedback
        audioService.playIncorrectFeedback();
        wrongAttempts.value++;
        
        // Record wrong answer
        abcModuleController.recordWrongAnswer(
          quizId: "quiz1",
          questionId: "Letter A identification",
          wrongAnswer: "Selected ${options[index]}",
          correctAnswer: "Should select A",
        );
        
        audioService.setInstructionAndSpeak(
          "Try again! Find the letter A.",
          "abc_audios/letter_a_try_again.mp3",
        );
      }
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

  // Play letter A audio specifically
  void playLetterA() {
    playLetter(AssetSource("abc_audios/letter_a_sound.mp3"));
  }

  // Complete the quiz
  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    // Record quiz result
    abcModuleController.recordQuizResult(
      quizId: "quiz1",
      score: 1, // 1 point for correct answer
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    abcModuleController.syncModuleProgress();
    
    Get.snackbar(
      "Excellent! 🎉",
      "You found the letter A!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Reset quiz state
  void resetQuiz() {
    hasAnswered.value = false;
    selectedIndex.value = -1;
    hasSubmitted.value = false;
    showCompletion.value = false;
    retries.value++;
    
    audioService.setInstructionAndSpeak(
      "Let's try finding the letter A again!",
      "abc_audios/letter_a_retry.mp3",
    );
  }

  // Check if user can proceed (for navigation)
  bool canProceed() {
    return hasSubmitted.value && selectedIndex.value == correctIndex.value;
  }

  // Get progress percentage (for UI)
  double getProgress() {
    return hasSubmitted.value ? 1.0 : 0.0;
  }
}