import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/quiz3_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NumberMatchController extends GetxController {
  // Game state
  var currentNumber = 0.obs;
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentQuestion = 1.obs;
  var showCompletion = false.obs;
  
  // TTS controller
  FlutterTts flutterTts = FlutterTts();
  var isTtsReady = false.obs;
  
  // Questions pool
  final List<Map<String, dynamic>> questions = [
    {
      "number": 3,
      "options": [
        {"count": 2, "image": "lib/assets/RiverGame/star_2.png", "correct": false},
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": true},
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": false},
      ]
    },
    {
      "number": 5,
      "options": [
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": false},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": true},
        {"count": 6, "image": "lib/assets/RiverGame/star_6.png", "correct": false},
      ]
    },
    {
      "number": 2,
      "options": [
        {"count": 2, "image": "lib/assets/RiverGame/star_2.png", "correct": true},
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": false},
        {"count": 1, "image": "lib/assets/RiverGame/star_1.png", "correct": false},
      ]
    },
    {
      "number": 4,
      "options": [
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": false},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": false},
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": true},
      ]
    },
    {
      "number": 6,
      "options": [
        {"count": 6, "image": "lib/assets/RiverGame/star_6.png", "correct": true},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": false},
        {"count": 7, "image": "lib/assets/RiverGame/star_7.png", "correct": false},
      ]
    },
  ];

  var currentQuestionData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    initializeTts();
    resetQuiz();
  }

  Future<void> initializeTts() async {
    try {
      // Set TTS settings
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.6); // Slower speed for kids
      await flutterTts.setVolume(2.0);
      
      isTtsReady.value = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
      isTtsReady.value = false;
    }
  }

  Future<void> speakNumber(int number) async {
    if (!isTtsReady.value) return;
    
    try {
      // await flutterTts.stop(); // Stop any previous speech
      await flutterTts.speak("$number");
      print("Speaking: $number");
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  Future<void> speakWithDelay(String text, {int delayMs = 500}) async {
    if (!isTtsReady.value) return;
    
    await Future.delayed(Duration(milliseconds: delayMs));
    await flutterTts.speak(text);
  }

  void resetQuiz() {
    score.value = 0;
    totalQuestions.value = questions.length;
    currentQuestion.value = 1;
    showCompletion.value = false;
    loadQuestion(0);
  }

  void loadQuestion(int index) {
    if (index < questions.length) {
      currentQuestionData.value = questions[index];
      currentNumber.value = questions[index]["number"];
      
      speakNumber(currentNumber.value);
    } else {
      showCompletion.value = true;
    }
  }

  void checkAnswer(int optionIndex) {
    final options = List<Map<String, dynamic>>.from(currentQuestionData["options"]);
    
    if (optionIndex < options.length && options[optionIndex]["correct"] == true) {
      score.value++;
      
      // Speak success message
      speakWithDelay("Correct!");
      
      Get.snackbar(
        "Correct! 🎉",
        "You matched number $currentNumber correctly!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      // Move to next question after delay
      Future.delayed(Duration(seconds: 2), () {
        if (currentQuestion.value < totalQuestions.value) {
          currentQuestion.value++;
          loadQuestion(currentQuestion.value - 1);
        } else {
          showCompletion.value = true;
          
          // Speak completion message
          speakWithDelay("Quiz completed! Your score is $score out of $totalQuestions");
          
          Get.snackbar(
            "Quiz Completed! 🎓",
            "Your score: $score/${totalQuestions.value}",
            backgroundColor: Colors.blue.shade300,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      });
    } else {
      speakWithDelay("Try again.");
      
      Get.snackbar(
        "Try Again",
        "Find the group with $currentNumber items",
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }
  void checkAnswerAndNavigate() {
     Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen
      Get.to(() => const countingsequence());
      

    });
}


  void nextQuestion() {
    if (currentQuestion.value < totalQuestions.value) {
      currentQuestion.value++;
      loadQuestion(currentQuestion.value - 1);
    } else {
      showCompletion.value = true;
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}