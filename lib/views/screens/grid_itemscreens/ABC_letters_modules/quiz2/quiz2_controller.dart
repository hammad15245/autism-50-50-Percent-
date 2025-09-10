import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BubbleQuizController extends GetxController {
  // Quiz options
  var options = ['A', 'B', '1', '2', 'C', '3'].obs;

  // Track answers: null = not answered, true = correct, false = incorrect
  var answers = <bool?>[null, null, null, null, null, null].obs;

  // Track correct answers (only letters are correct)
  final List<bool> correctAnswers = [true, true, false, false, true, false];

  // Progress tracking
  var retries = 0.obs;
  var wrongSelections = 0.obs;
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
        "Great Now lets Find all the letters! Tap on the letters and avoid numbers.",
        "goingbed_audios/bubble_quiz_intro.mp3",
      );
    });
    
    initializeAnswers();
  }

  void initializeAnswers() {
    answers.value = [null, null, null, null, null, null];
  }

  void checkAnswerAndNavigate() {
    // Check if any answer is selected
    if (answers.contains(true)) {
      // Calculate score
      final correctCount = answers.where((answer) => answer == true).length;
      final wrongCount = answers.where((answer) => answer == false).length;
      
      // Complete quiz
      completeQuiz(correctCount, wrongCount);
      
      // Navigate if attempted
      Get.to(() => const SoundRecognitionScreen());
    } else {
      // Show snackbar if not attempted
      audioService.playIncorrectFeedback();
      Get.snackbar(
        "Incomplete",
        "Please select an answer before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void selectAnswer(int index) {
    // If already answered, do nothing
    if (answers[index] != null || hasSubmitted.value) return;

    final isCorrect = correctAnswers[index];
    answers[index] = isCorrect;

    if (isCorrect) {
      // Play correct feedback
      audioService.playCorrectFeedback();
      // audioService.speak("Good! ${options[index]} is a letter!");
      
      // Play letter sound
      // playLetterSound(options[index]);
    } else {
      // Play incorrect feedback
      audioService.playIncorrectFeedback();
      wrongSelections.value++;
      
      // Record wrong answer
      abcModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Bubble item ${index + 1}",
        wrongAnswer: "Selected ${options[index]} (number)",
        correctAnswer: "Should select letters only",
      );
      
      // audioService.speak("${options[index]} is a number, not a letter!");
    }
  }

  // void playLetterSound(String letter) {
  //   switch (letter) {
  //     case 'A':
  //       audioService.playSoundEffect(AssetSource("abc_audios/letter_a_sound.mp3"));
  //       break;
  //     case 'B':
  //       audioService.playSoundEffect(AssetSource("abc_audios/letter_b_sound.mp3"));
  //       break;
  //     case 'C':
  //       audioService.playSoundEffect(AssetSource("abc_audios/letter_c_sound.mp3"));
  //       break;
  //     default:
  //       audioService.speak(letter);
  //   }
  // }

  void completeQuiz(int correctCount, int wrongCount) {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Great job! You found $correctCount letters!",
      "abc_audios/bubble_quiz_complete.mp3",
    );
    
    // Record quiz result
    abcModuleController.recordQuizResult(
      quizId: "quiz2",
      score: correctCount,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongCount,
    );
    
    // Sync progress
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
      "Let's try finding letters again! Remember, letters are A, B, C, not numbers.",
      "abc_audios/bubble_quiz_retry.mp3",
    );
  }

  bool isAnswered(int index) {
    return answers[index] != null;
  }

  bool isCorrectAnswer(int index) {
    return correctAnswers[index];
  }

  // Get progress percentage
  double getProgressPercentage() {
    final answeredCount = answers.where((answer) => answer != null).length;
    return answeredCount / answers.length;
  }

  // Get correct answers count
  int getCorrectAnswersCount() {
    return answers.where((answer) => answer == true).length;
  }

  // Get remaining letters to find
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