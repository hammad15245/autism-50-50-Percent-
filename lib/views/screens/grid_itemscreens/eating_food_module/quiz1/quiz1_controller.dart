import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/eating_food_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FoodIdentificationController extends GetxController {
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentQuestion = 1.obs;
  var showCompletion = false.obs;
  var isAnswering = false.obs;
  final audioService = AudioInstructionService.to;
  final eatingFoodController = Get.find<EatingFoodController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;
  var selectedIndex = (-1).obs;
  var correctIndex = (-1).obs;
  var isAnswered = false.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;

  final List<Map<String, dynamic>> allFoods = [
    {
      "name": "Apple",
      "image": "lib/assets/quiz1_food/apple.png",
      "category": "Fruit",
      "options": ["Orange", "Banana", "Apple", "Grapes"],
      "audio": "apple"
    },
    {
      "name": "Bread",
      "image": "lib/assets/quiz1_food/bread.png",
      "category": "Grains",
      "options": ["Bread", "Cake", "Cookie", "Cracker"],
      "audio": "bread"
    },
    {
      "name": "Milk",
      "image": "lib/assets/quiz1_food/milk.png",
      "category": "Dairy",
      "options": ["Juice", "Milk", "Water", "Soda"],
      "audio": "milk"
    },
    {
      "name": "Carrot",
      "image": "lib/assets/quiz1_food/carrot.png",
      "category": "Vegetable",
      "options": ["Potato", "Broccoli", "Carrot", "Tomato"],
      "audio": "carrot"
    },
    {
      "name": "Chicken",
      "image": "lib/assets/quiz1_food/chicken.png",
      "category": "Protein",
      "options": ["Chicken", "Fish", "Beef", "Egg"],
      "audio": "chicken"
    },
    {
      "name": "Cheese",
      "image": "lib/assets/quiz1_food/cheese.png",
      "category": "Dairy",
      "options": ["Ice Cream", "Butter", "Yogurt", "Cheese"],
      "audio": "cheese"
    },
    {
      "name": "Banana",
      "image": "lib/assets/quiz1_food/banana.png",
      "category": "Fruit",
      "options": ["Banana", "Apple", "Pear", "Peach"],
      "audio": "banana"
    },
    {
      "name": "Rice",
      "image": "lib/assets/quiz1_food/rice.png",
      "category": "Grains",
      "options": ["Pasta", "Rice", "Cereal", "Oats"],
      "audio": "rice"
    }
  ];

  var currentQuestionData = {}.obs;
  var questions = <Map<String, dynamic>>[].obs; // Explicitly type the list

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddo! Welcome to this quiz lets find the correct option for given pictures.",
        "goingbed_audios/food_identification_audio.mp3",
      );
    });
    resetQuiz();
  }

  void resetQuiz() {
    score.value = 0;
    
    // FIX: Create a new mutable list instead of using .take()
    List<Map<String, dynamic>> shuffledFoods = List.from(allFoods);
    shuffledFoods.shuffle();
    
    // Take first 5 and convert to regular growable list
    questions.value = shuffledFoods.take(5).toList(growable: true);
    
    totalQuestions.value = questions.length;
    currentQuestion.value = 1;
    showCompletion.value = false;
    isAnswering.value = false;
    selectedIndex.value = -1;
    correctIndex.value = -1;
    isAnswered.value = false;
    retries.value = 0;
    wrongAnswersCount.value = 0;

    if (questions.isNotEmpty) {
      loadQuestion(0);
    } else {
      showCompletion.value = true;
    }
  }

  void loadQuestion(int index) {
    if (index < questions.length) {
      currentQuestionData.value = questions[index];
      selectedIndex.value = -1;
      correctIndex.value = -1;
      isAnswered.value = false;
    } else {
      showCompletion.value = true;
    }
  }

  void checkAnswer(String option, int index) async {
    if (isAnswered.value) return;

    selectedIndex.value = index;
    final correctAnswer = currentQuestionData["name"];
    final options = List<String>.from(currentQuestionData["options"] ?? []);

    correctIndex.value = options.indexOf(correctAnswer);
    isAnswered.value = true;

    if (option == correctAnswer) {
      score.value++;
      await AudioInstructionService.to.playCorrectFeedback();
    } else {
      wrongAnswersCount.value++;
      
      // Record the specific wrong answer
      eatingFoodController.recordWrongAnswer(
        quizId: "quiz1",
        questionId: currentQuestionData["name"],
        wrongAnswer: option,
        correctAnswer: correctAnswer,
      );
      
      await AudioInstructionService.to.playIncorrectFeedback();
    }

    Future.delayed(const Duration(seconds: 2), () { // Reduced from 5 to 2 seconds
      nextQuestion();
    });
  }

  Color getButtonColor(int index) {
    if (!isAnswered.value) return const Color(0xFF0E83AD);
    if (index == correctIndex.value) return Colors.green;
    if (index == selectedIndex.value && selectedIndex.value != correctIndex.value) return Colors.red;
    return const Color(0xFF0E83AD);
  }

  void nextQuestion() {
    if (currentQuestion.value < totalQuestions.value) {
      currentQuestion.value++;
      loadQuestion(currentQuestion.value - 1);
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    
    // Record quiz result with wrong answers count
    eatingFoodController.recordQuizResult(
      quizId: "quiz1",
      score: score.value,
      retries: retries.value,
      isCompleted: score.value >= 3,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    eatingFoodController.syncModuleProgress();
  }

  void checkAnswerAndNavigate() {
    if (showCompletion.value) {
      Get.to(() => const Foodgroupscreen());
    }
  }

  void retryQuiz() {
    retries.value++;
    resetQuiz();
  }

  // Helper method to get current question options safely
  List<String> getCurrentOptions() {
    try {
      return List<String>.from(currentQuestionData["options"] ?? []);
    } catch (e) {
      print("Error getting options: $e");
      return [];
    }
  }

  // Helper method to get current question name safely
  String getCurrentQuestionName() {
    try {
      return currentQuestionData["name"]?.toString() ?? "Unknown";
    } catch (e) {
      print("Error getting question name: $e");
      return "Unknown";
    }
  }
}