import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubbleQuizController extends GetxController {
  // Quiz options
  var options = ['A', 'B', '1', '2', 'C', '3'].obs;

  // Track answers: null = not answered, true = correct, false = incorrect
  var answers = <bool?>[null, null, null, null, null, null].obs;

  // Track correct answers (only letters are correct)
  final List<bool> correctAnswers = [true, true, false, false, true, false];

  void initializeAnswers() {
    answers.value = [null, null, null, null, null, null];
  }

void checkAnswerAndNavigate() {
  // Check if any answer is selected
  if (answers.contains(true)) {
    // Navigate if attempted
    Get.to(() => const Quiz3Screen());
  } else {
    // Show snackbar if not attempted
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
    if (answers[index] != null) return;

    answers[index] = correctAnswers[index];
  }

  bool isAnswered(int index) {
    return answers[index] != null;
  }

  bool isCorrectAnswer(int index) {
    return correctAnswers[index];
  }
}
