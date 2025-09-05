import 'package:audioplayers/audioplayers.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

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

  // List of sound-object pairs
  var soundObjects = [
    {"sound": "A", "image": "lib/assets/quiz5_sounds/apple.png", "word": "Apple"},
    {"sound": "B", "image": "lib/assets/quiz5_sounds/ball.png", "word": "Ball"},
    {"sound": "C", "image": "lib/assets/quiz5_sounds/cat.png", "word": "Cat"},
    {"sound": "D", "image": "lib/assets/quiz5_sounds/dog.png", "word": "Dog"},
    {"sound": "E", "image": "lib/assets/quiz5_sounds/egg.png", "word": "Egg"},
    {"sound": "F", "image": "lib/assets/quiz5_sounds/fish.png", "word": "Fish"},
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
    loadNextQuestion();
  }

  @override
  void onClose() {
    audioPlayer.dispose(); // Clean up audio player
    super.onClose();
  }

  void loadNextQuestion() {
    if (currentIndex.value < soundObjects.length - 1) {
      currentIndex.value++;
      currentSound.value = soundObjects[currentIndex.value]["sound"]!;
      selectedAnswer.value = "";
      isCorrect.value = false;
      showFeedback.value = false;
    } else {
      // Quiz completed
      Get.snackbar(
        "Congratulations!",
        "You completed all sound questions! 🎉",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
      );
    }
  }

  void checkAnswer(String selectedImage) {
    selectedAnswer.value = selectedImage;
    showFeedback.value = true;
    
    String correctImage = soundObjects[currentIndex.value]["image"]!;
    isCorrect.value = (selectedImage == correctImage);
    
    if (isCorrect.value) {
      correctlyAnsweredQuestions.value++; // Track correct answers
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
      Get.snackbar(
        "Try Again",
        "That doesn't start with ${currentSound.value} sound",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void checkAnswerAndNavigate() {
    // Check if all questions have been answered correctly
    if (correctlyAnsweredQuestions.value <= totalQuestions) {
      // Navigate if all questions are answered correctly
      Get.to(() => const Quiz4matchingscreen());
    } else {
      // Show snackbar if not all questions are answered
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
}