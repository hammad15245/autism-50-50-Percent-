import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FindLetterController extends GetxController {
  // List of all target letters in sequence
  var targetLetters = ["A", "B", "C", "D", "E", "F"].obs;
  
  // Current target letter index
  var currentIndex = 0.obs;
  
  // The current target letter to find
  var targetLetter = "A".obs;

  // List of ALL letters collected by the user (persists across targets)
  var allCollectedLetters = <String>[].obs;
  
  // List of letters found for the CURRENT target only
  var currentCollectedLetters = <String>[].obs;

  // Track correctly collected letters
  var correctlyCollectedLetters = <String>[].obs;
  
  // Track temporarily incorrect letters (will reset after 2 seconds)
  var temporarilyIncorrectLetters = <String>[].obs;

  // To check if the answer is correct
  var isCorrect = false.obs;

  // Set the next target letter
  void nextLetter() {
    if (currentIndex.value < targetLetters.length - 1) {
      currentIndex.value++;
      targetLetter.value = targetLetters[currentIndex.value];
      currentCollectedLetters.clear(); // Only clear current, not all
      isCorrect.value = false;
    } else {
      // Quiz completed
      Get.snackbar(
        "Congratulations!",
        "You found all the letters! 🎉",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
      );
    }
  }

  // When user taps a letter in the picture
  void onLetterTapped(String letter) {
    if (allCollectedLetters.contains(letter)) return; // Already collected
    
    allCollectedLetters.add(letter);
    currentCollectedLetters.add(letter);

    if (letter == targetLetter.value) {
      correctlyCollectedLetters.add(letter); // Track correct collection
      isCorrect.value = true;
      Get.snackbar(
        "Correct!",
        "You found the letter $letter 🎉",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
      );
      
      // Automatically move to next letter after a delay
      Future.delayed(const Duration(seconds: 2), () {
        nextLetter();
      });
    } else {
      isCorrect.value = false;
      temporarilyIncorrectLetters.add(letter); // Add to temporary incorrect list
      
      Get.snackbar(
        "Try Again",
        "$letter is not the right letter. Look for ${targetLetter.value}",
        backgroundColor: Colors.red.shade300,
        colorText: Colors.white,
      );
      
      // Remove from incorrect list after 2 seconds
      Future.delayed(const Duration(seconds: 1), () {
        temporarilyIncorrectLetters.remove(letter);
      });
    }
  }

  // Check if all letters are collected and navigate
  void checkAnswerAndNavigate() {
    // Check if all target letters are collected
    if (allCollectedLetters.length >= targetLetters.length) {
      // Navigate if all letters are collected
      Get.to(() => const SoundRecognitionScreen());
    } else {
      // Show snackbar if not all letters are collected
      Get.snackbar(
        "Incomplete",
        "Please find all the letters before continuing.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}