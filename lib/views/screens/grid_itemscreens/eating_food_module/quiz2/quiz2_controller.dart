import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/eating_food_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz3/quiz3_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class FoodGroupController extends GetxController {
  var score = 0.obs;
  var totalItems = 0.obs;
  var placedItems = 0.obs;
  var showCompletion = false.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;

  final audioService = AudioInstructionService.to;
  final eatingFoodController = Get.find<EatingFoodController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // Track locked items (foods that can't be moved until reset)
  var lockedItems = <String>[].obs;

  // Make groups reactive
  var foodGroups = <Map<String, dynamic>>[].obs; 

  // Food items to sort
  var availableFoods = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    resetGame();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Okay kiddos! Let's drag each food to its correct group.",
      );
    });
  }

  void resetGame() {
    score.value = 0;
    placedItems.value = 0;
    showCompletion.value = false;
    wrongAnswersCount.value = 0;
    lockedItems.clear(); // Clear locked items on reset

    foodGroups.clear();
    foodGroups.addAll([
      {
        "name": "Fruits",
        "icon": "🍎",
        "color": Colors.red[300]!,
        "items": <String>[],
        "correctItems": ["Apple", "Banana"]
      },
      {
        "name": "Vegetables",
        "icon": "🥦",
        "color": Colors.green[300]!,
        "items": <String>[],
        "correctItems": ["Carrot", "Broccoli"]
      },
      {
        "name": "Proteins",
        "icon": "🥩",
        "color": Colors.brown[300]!,
        "items": <String>[],
        "correctItems": ["Chicken", "Egg"]
      },
      // Removed Grains category to simplify
      {
        "name": "Dairy",
        "icon": "🥛",
        "color": Colors.blue[300]!,
        "items": <String>[],
        "correctItems": ["Milk", "Cheese"]
      },
    ]);

    availableFoods.clear();
    for (var group in foodGroups) {
      for (var food in group["correctItems"]) {
        availableFoods.add({
          "name": food,
          "correctGroup": group["name"],
          "icon": group["icon"],
          "isLocked": false, // Add locked status to each food
        });
      }
    }

    availableFoods.shuffle();
    totalItems.value = availableFoods.length;
  }

  void placeFood(String groupName, String foodName) {
    // Check if food is already locked (placed correctly)
    if (lockedItems.contains(foodName)) {
      return; // Don't allow moving locked items
    }

    final group = foodGroups.firstWhere((g) => g["name"] == groupName);

    if (!(group["items"] as List<String>).contains(foodName)) {
      (group["items"] as List<String>).add(foodName);
      
      // Remove from available foods
      availableFoods.removeWhere((food) => food["name"] == foodName);
      
      placedItems.value++;
    }

    final isCorrect = (group["correctItems"] as List<String>).contains(foodName);
    
    if (isCorrect) {
      score.value++;
      
      // Lock the item in place when placed correctly
      lockedItems.add(foodName);
      
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Good job! $foodName belongs to ${group["name"]}",
      );
    } else {
      wrongAnswersCount.value++;
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      eatingFoodController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: foodName,
        wrongAnswer: groupName,
        correctAnswer: _findCorrectGroupForFood(foodName),
      );
      
      audioService.setInstructionAndSpeak(
        "Oops! $foodName does not belong to ${group["name"]}",
      );
      
      // Return incorrect items to available foods after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (!lockedItems.contains(foodName)) { // Only return if not locked
          removeFood(groupName, foodName);
        }
      });
    }

    checkCompletion();
    foodGroups.refresh();
  }

  // Check if a food item is locked (can't be moved)
  bool isFoodLocked(String foodName) {
    return lockedItems.contains(foodName);
  }

  String _findCorrectGroupForFood(String foodName) {
    for (var group in foodGroups) {
      if ((group["correctItems"] as List<String>).contains(foodName)) {
        return group["name"];
      }
    }
    return "Unknown";
  }

  void removeFood(String groupName, String foodName) {
    // Don't remove locked items
    if (lockedItems.contains(foodName)) {
      return;
    }

    final group = foodGroups.firstWhere((g) => g["name"] == groupName);
    if ((group["items"] as List<String>).contains(foodName)) {
      (group["items"] as List<String>).remove(foodName);
      
      // Add back to available foods
      availableFoods.add({
        "name": foodName,
        "correctGroup": _findCorrectGroupForFood(foodName),
        "icon": "❓", // Use question mark for returned items
        "isLocked": false,
      });
      
      placedItems.value--;

      if ((group["correctItems"] as List<String>).contains(foodName)) {
        score.value--;
      }
      foodGroups.refresh();
    }
  }

  void checkCompletion() {
    if (placedItems.value >= totalItems.value) {
      showCompletion.value = true;
      completeQuiz();
    }
  }

  void completeQuiz() {
    final correctCount = score.value;
    final total = totalItems.value;

    // Calculate final score (each correct placement = 1 point)
    final earnedScore = correctCount;
    final isPassed = earnedScore >= (total * 0.7); // 70% to pass

    // Record quiz result
    eatingFoodController.recordQuizResult(
      quizId: "quiz2",
      score: earnedScore,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    eatingFoodController.syncModuleProgress();

    if (correctCount == total) {
      audioService.setInstructionAndSpeak(
        "Perfect! You sorted all $total foods correctly!",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $correctCount out of $total correct.",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "Good try! You got $correctCount out of $total correct. Let's practice more.",
      );
    }
  }

  void resetFood(String foodName) {
    // Only reset non-locked items
    if (!lockedItems.contains(foodName)) {
      for (var group in foodGroups) {
        if ((group["items"] as List<String>).contains(foodName)) {
          removeFood(group["name"], foodName);
          break;
        }
      }
    }
  }

  void retryQuiz() {
    retries.value++;
    resetGame();
    
    audioService.setInstructionAndSpeak(
      "Let's try again! Drag each food to its correct group.",
    );
  }

  void checkAnswerAndNavigate() {
    if (showCompletion.value) {
      Get.to(() => const HealthyChoicesscreen());
    }
  }

  // Get available foods that are not locked
  List<Map<String, dynamic>> getAvailableUnlockedFoods() {
    return availableFoods.where((food) => !lockedItems.contains(food["name"])).toList();
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}