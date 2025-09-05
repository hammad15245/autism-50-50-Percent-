import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FoodIdentificationController extends GetxController {
  // Game state
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentQuestion = 1.obs;
  var showCompletion = false.obs;
  var isAnswering = false.obs;

  // Answer tracking
  var selectedIndex = (-1).obs;
  var correctIndex = (-1).obs;
  var isAnswered = false.obs;

  // TTS controller
  FlutterTts flutterTts = FlutterTts();
  var isTtsReady = false.obs;

  // Food items database
  final List<Map<String, dynamic>> allFoods = [
    {
      "name": "Apple",
      "image": "lib/assets/quiz1_food/apple.png",
      "category": "Fruit",
      "options": ["Orange", "Banana", "Apple", "Grapes"]
    },
    {
      "name": "Bread",
      "image": "lib/assets/quiz1_food/bread.png",
      "category": "Grains",
      "options": ["Bread", "Cake", "Cookie", "Cracker"]
    },
    {
      "name": "Milk",
      "image": "lib/assets/quiz1_food/milk.png",
      "category": "Dairy",
      "options": ["Juice", "Milk", "Water", "Soda"]
    },
    {
      "name": "Carrot",
      "image": "lib/assets/quiz1_food/carrot.png",
      "category": "Vegetable",
      "options": ["Potato", "Broccoli", "Carrot", "Tomato"]
    },
    {
      "name": "Chicken",
      "image": "lib/assets/quiz1_food/chicken.png",
      "category": "Protein",
      "options": ["Chicken", "Fish", "Beef", "Egg"]
    },
    {
      "name": "Cheese",
      "image": "lib/assets/quiz1_food/cheese.png",
      "category": "Dairy",
      "options": ["Ice Cream", "Butter", "Yogurt", "Cheese"]
    },
    {
      "name": "Banana",
      "image": "lib/assets/quiz1_food/banana.png",
      "category": "Fruit",
      "options": ["Banana", "Apple", "Pear", "Peach"]
    },
    {
      "name": "Rice",
      "image": "lib/assets/quiz1_food/rice.png",
      "category": "Grains",
      "options": ["Pasta", "Rice", "Cereal", "Oats"]
    }
  ];

  var currentQuestionData = {}.obs;
  var questions = [].obs;

  @override
  void onInit() {
    super.onInit();
    initializeTts();
    resetQuiz();
  }

  Future<void> initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);

      isTtsReady.value = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("Error initializing TTS: $e");
      isTtsReady.value = false;
    }
  }

  Future<void> speak(String text, {int delayMs = 500}) async {
    if (!isTtsReady.value) return;

    try {
      await Future.delayed(Duration(milliseconds: delayMs));
      await flutterTts.speak(text);
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  void resetQuiz() {
    score.value = 0;
    questions.value = List.from(allFoods)..shuffle();
    questions.value = questions.take(5).toList();
    totalQuestions.value = questions.length;
    currentQuestion.value = 1;
    showCompletion.value = false;
    isAnswering.value = false;
    selectedIndex.value = -1;
    correctIndex.value = -1;
    isAnswered.value = false;

    loadQuestion(0);
  }

  void loadQuestion(int index) {
    if (index < questions.length) {
      currentQuestionData.value = questions[index];
      selectedIndex.value = -1;
      correctIndex.value = -1;
      isAnswered.value = false;
      speakInstructions();
    } else {
      showCompletion.value = true;
    }
  }

  Future<void> speakInstructions() async {
    if (!isTtsReady.value) return;

    // await speak("Look at the food picture");
    await speak("What is this food?");
    // await speak("Tap the correct name");
  }

  void checkAnswer(String option, int index) {
    if (isAnswered.value) return;

    selectedIndex.value = index;

    final correctAnswer = currentQuestionData["name"];
    final options = List<String>.from(currentQuestionData["options"] ?? []);

    correctIndex.value = options.indexOf(correctAnswer);
    isAnswered.value = true;

    // Update score and feedback
    if (option == correctAnswer) {
      score.value++;
      speak("Great job! That is a $correctAnswer");
    } else {
      speak("Oops! That was not correct. The correct answer is $correctAnswer");
    }

    Future.delayed(const Duration(seconds: 5), () {
      nextQuestion();
    });
  }

  Color getButtonColor(int index) {
    if (!isAnswered.value) {
      return const Color(0xFF0E83AD); 
    }

    if (index == correctIndex.value) {
      return Colors.green; 
    }

    if (index == selectedIndex.value && selectedIndex.value != correctIndex.value) {
      return Colors.red; 
    }

    return const Color(0xFF0E83AD); 
  }

  void nextQuestion() {
    if (currentQuestion.value < totalQuestions.value) {
      currentQuestion.value++;
      loadQuestion(currentQuestion.value - 1);
    } else {
      showCompletion.value = true;
    }
  }

  void repeatQuestion() {
    speakInstructions();
  }
  void checkAnswerAndNavigate() {
     Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen
      Get.to(() => const Foodgroupscreen());
      

    });
}

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
