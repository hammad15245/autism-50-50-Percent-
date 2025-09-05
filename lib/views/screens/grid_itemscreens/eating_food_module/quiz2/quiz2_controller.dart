import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz3/quiz3_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FoodGroupController extends GetxController {
  var score = 0.obs;
  var totalItems = 0.obs;
  var placedItems = 0.obs;
  var showCompletion = false.obs;

  FlutterTts flutterTts = FlutterTts();
  var isTtsReady = false.obs;

  // Make groups reactive
var foodGroups = <Map<String, dynamic>>[].obs; 

  // Food items to sort
  var availableFoods = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    initializeTts();
    resetGame();
  }

  Future<void> initializeTts() async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);

      isTtsReady.value = true;
      speakInstructions();
    } catch (e) {
      print("Error initializing TTS: $e");
      isTtsReady.value = false;
    }
  }

  Future<void> speakInstructions() async {
    if (!isTtsReady.value) return;
    await flutterTts.speak(
      "Drag each food to its correct group. Fruits, vegetables, proteins, grains, and dairy.",
    );
  }

  Future<void> speakMessage(String message) async {
    if (!isTtsReady.value) return;
    await flutterTts.speak(message);
  }
void resetGame() {
  score.value = 0;
  placedItems.value = 0;
  showCompletion.value = false;

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
    {
      "name": "Grains",
      "icon": "🍞",
      "color": Colors.amber[300]!,
      "items": <String>[],
      "correctItems": ["Bread", "Rice"]
    },
  ]);

  availableFoods.clear();
  for (var group in foodGroups) {
    for (var food in group["correctItems"]) {
      availableFoods.add({
        "name": food,
        "correctGroup": group["name"],
        "icon": group["icon"],
      });
    }
  }

  availableFoods.shuffle();
  totalItems.value = availableFoods.length;

  speakInstructions();
}

  void placeFood(String groupName, String foodName) {
    final group = foodGroups.firstWhere((g) => g["name"] == groupName);

    if (!(group["items"] as List<String>).contains(foodName)) {
      (group["items"] as List<String>).add(foodName);
      availableFoods.removeWhere((food) => food["name"] == foodName);
      placedItems.value++;
    }

    if ((group["correctItems"] as List<String>).contains(foodName)) {
      score.value++;
      speakMessage("Good job! $foodName belongs to ${group["name"]}");
    } else {
      speakMessage("Oops! $foodName does not belong to ${group["name"]}");
    }

    checkCompletion();
    foodGroups.refresh(); // refresh reactive list
  }

  void removeFood(String groupName, String foodName) {
    final group = foodGroups.firstWhere((g) => g["name"] == groupName);
    if ((group["items"] as List<String>).contains(foodName)) {
      (group["items"] as List<String>).remove(foodName);
      availableFoods.add({
        "name": foodName,
        "correctGroup": groupName,
        "icon": group["icon"],
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

      final correctCount = score.value;
      final total = totalItems.value;

      if (correctCount == total) {
        speakMessage("Perfect! You sorted all $total foods correctly!");
      } else {
        speakMessage(
          "Good try! You got $correctCount out of $total correct. Let's move to another test",
        );
      }
    }
  }

  void resetFood(String foodName) {
    for (var group in foodGroups) {
      if ((group["items"] as List<String>).contains(foodName)) {
        removeFood(group["name"], foodName);
        break;
      }
    }
  }

    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      Get.to(() => const HealthyChoicesscreen());
      

    
}

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }
}
