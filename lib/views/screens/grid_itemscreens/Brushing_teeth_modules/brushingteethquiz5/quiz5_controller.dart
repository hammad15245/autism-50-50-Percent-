import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz5Controller extends GetxController {
  var selectedTemplate = 0.obs; 
  var userAnswerCorrect = false.obs;
  var userAnswered = false.obs;

  // Store user's selected answers (index per template)
  var userAnswers = <int?>[].obs; 

  final templates = [
    'lib/assets/quiz5_icon/icon1.png',
    'lib/assets/quiz5_icon/icon2.png',
    'lib/assets/quiz5_icon/icon3.png',
  ];

  final templateOptions = [
    [
      'lib/assets/quiz5_icon/opt3_icon1.png', // correct one
      'lib/assets/quiz5_icon/opt1_icon1.png',
      'lib/assets/quiz5_icon/opt2_icon1.png',
    ],
    [
      'lib/assets/quiz5_icon/opt1_icon2.png',
      'lib/assets/quiz5_icon/opt3_icon2.png', // correct one
      'lib/assets/quiz5_icon/opt2_icon2.png',
    ],
    [
      'lib/assets/quiz5_icon/opt1_icon3.png',
      'lib/assets/quiz5_icon/opt2_icon3.png',
      'lib/assets/quiz5_icon/opt3_icon3.png', // correct one
    ],
  ];

  final correctAnswers = [0, 1, 2];

  @override
  void onInit() {
    super.onInit();
    // Initialize with nulls for all templates
    userAnswers.value = List.filled(templates.length, null);
  }

  void selectOption(int index) {
    userAnswered.value = true;
    userAnswerCorrect.value =
        index == correctAnswers[selectedTemplate.value];

    // Save user's selected answer
    userAnswers[selectedTemplate.value] = index;

    Future.delayed(const Duration(seconds: 1), () {
      if (selectedTemplate.value < templates.length - 1) {
        selectedTemplate.value++;
        userAnswered.value = false;
      }
    });
  }

  // Method to get total correct answers based on user input
  int getTotalCorrectAnswers() {
    int count = 0;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (userAnswers[i] == correctAnswers[i]) {
        count++;
      }
    }
    return count;
  }
}
