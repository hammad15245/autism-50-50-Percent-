import 'package:audioplayers/audioplayers.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class SoundRecognitionController extends GetxController {
  // Audio player instance
  final AudioPlayer audioPlayer = AudioPlayer();
  
  // Current sound to recognize
  var currentSound = "A".obs;
  
  // Current question index
  var currentIndex = 0.obs;
  var isPlayingSound = false.obs;

  // Track correctly answered questions
  var correctlyAnsweredQuestions = 0.obs;
  var totalQuestions = 6; // Since you have 6 sound objects

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

  // List of sound-object pairs
  var soundObjects = [
    {"sound": "A", "image": "lib/assets/quiz5_sounds/apple.png", "word": "Apple", "audio": "abc_audios/apple_sound.mp3"},
    {"sound": "B", "image": "lib/assets/quiz5_sounds/ball.png", "word": "Ball", "audio": "abc_audios/ball_sound.mp3"},
    {"sound": "C", "image": "lib/assets/quiz5_sounds/cat.png", "word": "Cat", "audio": "abc_audios/cat_sound.mp3"},
    {"sound": "D", "image": "lib/assets/quiz5_sounds/dog.png", "word": "Dog", "audio": "abc_audios/dog_sound.mp3"},
    {"sound": "E", "image": "lib/assets/quiz5_sounds/egg.png", "word": "Egg", "audio": "abc_audios/egg_sound.mp3"},
    {"sound": "F", "image": "lib/assets/quiz5_sounds/fish.png", "word": "Fish", "audio": "abc_audios/fish_sound.mp3"},
  ].obs;

  // Selected answer
  var selectedAnswer = RxString("");
  
  // Is answered correctly
  var isCorrect = false.obs;
  
  // Show feedback
  var showFeedback = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Listen to the sound and choose the picture that starts with that letter!",
        "goingbed_audios/sound_recognition_intro.mp3",
      );
    });
    
    loadNextQuestion();
  }

  @override
  void onClose() {
    audioPlayer.dispose(); // Clean up audio player
    audioService.stopSpeaking();
    super.onClose();
  }

  Future<void> playSound() async {
    if (isPlayingSound.value) return;
    try {
      isPlayingSound.value = true;
      
      await audioPlayer.play(AssetSource("sounds/${currentSound.value.toLowerCase()}_sound.mp3"));
      
      // Listen for playback completion to reset the playing state
      audioPlayer.onPlayerComplete.listen((event) {
        isPlayingSound.value = false;
      });
      
    } catch (e) {
      isPlayingSound.value = false;
      print("Error playing sound: $e");
      Get.snackbar(
        "Error",
        "Could not play sound",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void loadNextQuestion() {
    if (currentIndex.value < soundObjects.length - 1) {
      currentIndex.value++;
      currentSound.value = soundObjects[currentIndex.value]["sound"]!;
      selectedAnswer.value = "";
      isCorrect.value = false;
      showFeedback.value = false;
      
      // Play question instruction
      audioService.setInstructionAndSpeak(
        "What starts with the ${currentSound.value} sound?",
        "abc_audios/what_starts_with.mp3",
      );
    } else {
      // Quiz completed
      completeQuiz();
    }
  }

  void checkAnswer(String selectedImage) {
    if (hasSubmitted.value) return;
    
    selectedAnswer.value = selectedImage;
    showFeedback.value = true;
    
    String correctImage = soundObjects[currentIndex.value]["image"]!;
    isCorrect.value = (selectedImage == correctImage);
    
    if (isCorrect.value) {
      correctlyAnsweredQuestions.value++; // Track correct answers
      
      // Play correct feedback and word sound
      audioService.playCorrectFeedback();
      playWordSound(soundObjects[currentIndex.value]["word"]!);
      
      audioService.setInstructionAndSpeak(
        "Yes! ${soundObjects[currentIndex.value]["word"]} starts with ${currentSound.value}!",
        "abc_audios/correct_word_match.mp3",
      );

      Get.snackbar(
        "Correct!",
        "Yes! ${soundObjects[currentIndex.value]["word"]} starts with ${currentSound.value}",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Auto-advance after delay
      Future.delayed(const Duration(seconds: 3), () {
        loadNextQuestion();
      });
    } else {
      wrongAttempts.value++;
      
      // Play incorrect feedback
      audioService.playIncorrectFeedback();
      
      // Record wrong answer
      abcModuleController.recordWrongAnswer(
        quizId: "quiz5",
        questionId: "Sound ${currentSound.value} recognition",
        wrongAnswer: "Selected wrong image",
        correctAnswer: "Should select ${soundObjects[currentIndex.value]["word"]}",
      );
      
      audioService.setInstructionAndSpeak(
        "Try again! Listen for the ${currentSound.value} sound.",
        "abc_audios/try_again_sound.mp3",
      );

      Get.snackbar(
        "Try Again",
        "That doesn't start with ${currentSound.value} sound",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void playWordSound(String word) {
    final wordAudio = soundObjects[currentIndex.value]["audio"];
    if (wordAudio != null) {
      // audioService.playSoundEffect(AssetSource(wordAudio));
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Amazing! You recognized all the sounds correctly!",
      "abc_audios/all_sounds_recognized.mp3",
    );
    
    // Record quiz result
    abcModuleController.recordQuizResult(
      quizId: "quiz5",
      score: correctlyAnsweredQuestions.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    abcModuleController.syncModuleProgress();
    
    Get.snackbar(
      "Congratulations!",
      "You completed all sound questions! 🎉",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
    );
  }

  void checkAnswerAndNavigate() {
    // Check if all questions have been answered correctly
    if (correctlyAnsweredQuestions.value >= totalQuestions) {
      completeQuiz();
      // Navigate if all questions are answered correctly
      Get.to(() => const Quiz4matchingscreen());
    } else {
      // Show snackbar if not all questions are answered
      audioService.playIncorrectFeedback();
      Get.snackbar(
        "Incomplete",
        "Please complete all questions before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void skipQuestion() {
    loadNextQuestion();
  }

  void resetQuiz() {
    currentIndex.value = 0;
    currentSound.value = "A";
    selectedAnswer.value = "";
    isCorrect.value = false;
    showFeedback.value = false;
    correctlyAnsweredQuestions.value = 0;
    retries.value++;
    wrongAttempts.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try sound recognition again! Listen carefully to each sound.",
      "abc_audios/sound_recognition_retry.mp3",
    );
    
    loadNextQuestion();
  }

  // Get progress percentage
  double getProgressPercentage() {
    return correctlyAnsweredQuestions.value / totalQuestions;
  }

  // Get remaining questions count
  int getRemainingQuestions() {
    return totalQuestions - correctlyAnsweredQuestions.value;
  }

  // Get current question progress
  String getCurrentProgress() {
    return "${currentIndex.value + 1}/$totalQuestions";
  }
}