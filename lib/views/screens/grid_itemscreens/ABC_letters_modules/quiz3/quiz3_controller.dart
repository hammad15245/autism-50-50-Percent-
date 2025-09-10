import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class FindLetterController extends GetxController {
  // List of all target letters in sequence
  var targetLetters = ["A", "B", "C", "D", "E", "F"].obs;
  
  var currentIndex = 0.obs;
  
  // The current target letter to find
  var targetLetter = "A".obs;

  // List of ALL letters collected by the user (persists across targets)
  var allCollectedLetters = <String>[].obs;
  
  // List of letters found for the CURRENT target only
  var currentCollectedLetters = <String>[].obs;

  // Track correctly collected letters
  var correctlyCollectedLetters = <String>[].obs;
  
  // Track temporarily incorrect letters (will reset after 2 seconds)
  var temporarilyIncorrectLetters = <String>[].obs;

  // To check if the answer is correct
  var isCorrect = false.obs;

  // Progress tracking
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  // Audio service
  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Ok kiddos Let's find hidden letters! Tap on the letter ${targetLetter.value}.",
        "goingbed_audios/find_letter_intro.mp3",
      );
    });
  }

  // Set the next target letter
  void nextLetter() {
    if (currentIndex.value < targetLetters.length - 1) {
      currentIndex.value++;
      targetLetter.value = targetLetters[currentIndex.value];
      currentCollectedLetters.clear(); // Only clear current, not all
      isCorrect.value = false;
      
      // Play next letter instruction
      audioService.setInstructionAndSpeak(
        "Great! Now find the letter ${targetLetter.value}.",
        "abc_audios/next_letter_instruction.mp3",
      );
    } else {
      // Quiz completed
      completeQuiz();
    }
  }

  // When user taps a letter in the picture
  void onLetterTapped(String letter) {
    if (allCollectedLetters.contains(letter)) return; // Already collected
    
    allCollectedLetters.add(letter);
    currentCollectedLetters.add(letter);

    if (letter == targetLetter.value) {
      correctlyCollectedLetters.add(letter); // Track correct collection
      isCorrect.value = true;
      
      // Play correct feedback and letter sound
      audioService.playCorrectFeedback();
      playLetterSound(letter);
      
      audioService.setInstructionAndSpeak(
        "Excellent! You found $letter!",
        "abc_audios/letter_found_correct.mp3",
      );
      
      Get.snackbar(
        "Correct!",
        "You found the letter $letter 🎉",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
      );
      
      // Automatically move to next letter after a delay
      Future.delayed(const Duration(seconds: 2), () {
        nextLetter();
      });
    } else {
      isCorrect.value = false;
      wrongAttempts.value++;
      temporarilyIncorrectLetters.add(letter); // Add to temporary incorrect list
      
      // Play incorrect feedback
      audioService.playIncorrectFeedback();
      audioService.setInstructionAndSpeak(
        "$letter is not correct. Look for ${targetLetter.value}.",
        "abc_audios/letter_incorrect.mp3",
      );
      
      // Record wrong answer
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
      
      // Remove from incorrect list after 2 seconds
      Future.delayed(const Duration(seconds: 1), () {
        temporarilyIncorrectLetters.remove(letter);
      });
    }
  }

  // Play letter sound
  void playLetterSound(String letter) {
    final audioFile = "abc_audios/letter_${letter.toLowerCase()}_sound.mp3";
    // audioService.playSoundEffect(AssetSource(audioFile));
  }

  // Complete the quiz
  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Amazing! You found all the letters from A to F!",
      "abc_audios/all_letters_found.mp3",
    );
    
    // Record quiz result
    abcModuleController.recordQuizResult(
      quizId: "quiz3",
      score: correctlyCollectedLetters.length,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    abcModuleController.syncModuleProgress();
    
    Get.snackbar(
      "Congratulations!",
      "You found all the letters! 🎉",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
    );
  }

  // Check if all letters are collected and navigate
  void checkAnswerAndNavigate() {
    // Check if all target letters are collected
    if (allCollectedLetters.length >= targetLetters.length) {
      completeQuiz();
      // Navigate if all letters are collected
      Get.to(() => const SoundRecognitionScreen());
    } else {
      // Show snackbar if not all letters are collected
      audioService.playIncorrectFeedback();
      Get.snackbar(
        "Incomplete",
        "Please find all the letters before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // Reset quiz
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
      "Let's try finding all the letters again! Start with letter A.",
      "abc_audios/find_letter_retry.mp3",
    );
  }

  // Get progress percentage
  double getProgressPercentage() {
    return allCollectedLetters.length / targetLetters.length;
  }

  // Get remaining letters count
  int getRemainingLetters() {
    return targetLetters.length - allCollectedLetters.length;
  }

  // Get current target progress
  String getCurrentTargetProgress() {
    return "${currentIndex.value + 1}/${targetLetters.length}";
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}