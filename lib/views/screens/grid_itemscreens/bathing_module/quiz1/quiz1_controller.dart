import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BathingItemsController extends GetxController {
  // Current question index
  var currentIndex = 0.obs;
  
  // List of bathing items with questions
  var bathingItems = [
    {
      "question": "What do we use to wash our body?",
      "options": ["Soap", "Toothbrush", "Comb", "Towel"],
      "correctAnswer": "Soap",
      "image": "lib/assets/quiz1_bathing/soap.jpg"
    },
    {
      "question": "What do we use to dry ourselves?",
      "options": ["Soap", "Shampoo", "Towel", "Toothpaste"],
      "correctAnswer": "Towel",
      "image": "lib/assets/quiz1_bathing/towel.jpg"
    },
    {
      "question": "What do we use to wash our hair?",
      "options": ["Comb", "Shampoo", "Soap", "Towel"],
      "correctAnswer": "Shampoo",
      "image": "lib/assets/quiz1_bathing/shampoo.jpg"
    },
    {
      "question": "What do we use to comb our hair?",
      "options": ["Brush", "Comb", "Towel", "Soap"],
      "correctAnswer": "Comb",
      "image": "lib/assets/quiz1_bathing/comb.jpg"
    },
    {
      "question": "Where do we take a bath?",
      "options": ["Bathtub", "Bed", "Table", "Chair"],
      "correctAnswer": "Bathtub",
      "image": "lib/assets/quiz1_bathing/bathtub.jpg"
    }
  ].obs;

  // Selected answer
  var selectedAnswer = RxString("");
  
  // Is answered correctly
  var isCorrect = false.obs;
  
  // Show feedback
  var showFeedback = false.obs;

  // Track completed questions
  var completedQuestions = 0.obs;
  var totalQuestions = 5;

  void checkAnswer(String selectedOption) {
    selectedAnswer.value = selectedOption;
    showFeedback.value = true;
    
    // Safer access with null checking
    var currentItem = bathingItems[currentIndex.value];
    String? correctAnswer = currentItem["correctAnswer"] as String?;
    
    if (correctAnswer != null) {
      isCorrect.value = (selectedOption == correctAnswer);
      
      if (isCorrect.value) {
        completedQuestions.value++;
        Get.snackbar(
          "Great job! 🎉",
          "That's the right answer!",
          backgroundColor: Colors.green.shade300,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "That's not quite right",
          "The correct answer is: $correctAnswer",
          backgroundColor: Colors.orange.shade300,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      
      // Auto-advance after a short delay, regardless of correct/incorrect
      Future.delayed(const Duration(seconds: 3), () {
        nextQuestion();
      });
    }
  }

  void nextQuestion() {
    if (currentIndex.value < bathingItems.length - 1) {
      currentIndex.value++;
      selectedAnswer.value = "";
      isCorrect.value = false;
      showFeedback.value = false;
    } else {
      // Quiz completed
      Get.snackbar(
        "Congratulations! 🎊",
        "You completed all the questions!",
        backgroundColor: Colors.blue.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

 void checkAnswerAndNavigate() {
  // Only check if current question is answered, regardless of position
  if (selectedAnswer.value.isNotEmpty) {
    // If answered, move to next quiz (user has already progressed through all questions)
    Get.to(() => const BathingSequenceScreen());
  } else {
    // Current question not answered
    Get.snackbar(
      "Answer required",
      "Please answer this question first",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
    );
  }
}

  // Manual next button (if you want to allow manual progression)
  void manualNextQuestion() {
   Get.to(()=> BathingSequenceScreen()) ;
  }
}