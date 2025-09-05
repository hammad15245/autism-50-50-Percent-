import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz2/quiz2_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CountingController extends GetxController {
  // Current state variables
  var currentCount = 0.obs;
  var targetNumber = 0.obs;
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentQuestion = 1.obs;
  var showCompletion = false.obs;
  
  // Bath items with their assets - updated path to quiz1_counting
  final List<Map<String, dynamic>> bathItems = [
    {
      "name": "Soap",
      "icon": "lib/assets/quiz1_counting/soap.png",
    },
    {
      "name": "Towel",
      "icon": "lib/assets/quiz1_counting/towel.png",
    },
    {
      "name": "Rubber Duck",
      "icon": "lib/assets/quiz1_counting/duck.png",
    },
    {
      "name": "Shampoo",
      "icon": "lib/assets/quiz1_counting/shampoo.png",
    },
    {
      "name": "Bubble Bath",
      "icon": "lib/assets/quiz1_counting/bubble_bath.png",
    },
    {
      "name": "Sponge",
      "icon": "lib/assets/quiz1_counting/sponge.png",
    },
  ];

  // Questions pool - Updated to include 6 items with repetitions
  final List<Map<String, dynamic>> questions = [
    {
      "question": "Count the soaps",
      "targetItem": "Soap",
      "targetCount": 3,
      "items": ["Soap", "Towel", "Shampoo", "Soap", "Rubber Duck", "Soap"]
    },
    {
      "question": "Count the towels",
      "targetItem": "Towel",
      "targetCount": 2,
      "items": ["Towel", "Towel", "Soap", "Shampoo", "Bubble Bath", "Sponge"]
    },
    {
      "question": "Count the rubber ducks",
      "targetItem": "Rubber Duck",
      "targetCount": 4,
      "items": ["Rubber Duck", "Soap", "Rubber Duck", "sponge", "Soap", "Rubber Duck"]
    },
    {
      "question": "Count the shampoo bottles",
      "targetItem": "Shampoo",
      "targetCount": 3,
      "items": ["Shampoo", "sponge", "Shampoo", "Towel", "Shampoo", "Rubber Duck"]
    },
    {
      "question": "Count the sponges",
      "targetItem": "Sponge",
      "targetCount": 5,
      "items": ["Sponge", "Sponge", "Sponge", "Sponge", "Sponge", "Towel"]
    },
  ];

  var currentQuestionData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    resetQuiz();
  }

  void resetQuiz() {
    currentCount.value = 0;
    score.value = 0;
    totalQuestions.value = questions.length;
    currentQuestion.value = 1;
    showCompletion.value = false;
    loadQuestion(0);
  }

  void loadQuestion(int index) {
    if (index < questions.length) {
      currentQuestionData.value = questions[index];
      targetNumber.value = questions[index]["targetCount"];
      currentCount.value = 0;
    } else {
      showCompletion.value = true;
    }
  }

  void incrementCount() {
    if (currentCount < targetNumber.value) {
      currentCount.value++;
    }
  }

  void decrementCount() {
    if (currentCount > 0) {
      currentCount.value--;
    }
  }

  void checkAnswer() {
    if (currentCount.value == targetNumber.value) {
      score.value++;
      Get.snackbar(
        "Correct! 🎉",
        "You counted ${currentCount.value} ${currentQuestionData["targetItem"]}s correctly!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        "Try Again",
        "You counted ${currentCount.value}, but there are ${targetNumber.value} ${currentQuestionData["targetItem"]}s",
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    // Move to next question after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestion.value < totalQuestions.value) {
        currentQuestion.value++;
        loadQuestion(currentQuestion.value - 1);
      } else {
        showCompletion.value = true;
        Get.snackbar(
          "Quiz Completed! 🎓",
          "Your score: $score/${totalQuestions.value}",
          backgroundColor: Colors.blue.shade300,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });
  }

  
void checkAnswerAndNavigate() {
     Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen
      Get.to(() => const DuckCollectionscreen());
      

    });
}

  // Get exactly 6 items for the grid (with repetitions as needed)
  List<Map<String, dynamic>> getCurrentItems() {
    final dynamic items = currentQuestionData["items"];
    
    if (items is List<String> && items.length >= 6) {
      // Return first 6 items if available
      return items.take(6).map((itemName) => getItemByName(itemName)).toList();
    } else if (items is List<dynamic> && items.length >= 6) {
      // Handle case where it's List<dynamic>
      return items.take(6).map((item) {
        final itemName = item.toString();
        return getItemByName(itemName);
      }).toList();
    }
    
    // Fallback: Return 6 default items if something goes wrong
    return List.generate(6, (index) => getItemByName("Soap"));
  }

  // Get item by name with proper error handling
  Map<String, dynamic> getItemByName(String name) {
    try {
      return bathItems.firstWhere((item) => item["name"] == name);
    } catch (e) {
      // Return the first item as default if not found
      return bathItems[0];
    }
  }
}