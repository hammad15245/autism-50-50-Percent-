import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CleanDirtyController extends GetxController {
  var items = [
    {
      "image": "lib/assets/quiz3_cleanvsdirty/soap.jpg",
      "name": "Soap",
      "isClean": true,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/towel.png",
      "name": "Clean Towel",
      "isClean": true,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/shampoo.png",
      "name": "Shampoo",
      "isClean": true,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/mud.png",
      "name": "Mud",
      "isClean": false,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/dirty_clothes.png",
      "name": "Dirty Clothes",
      "isClean": false,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/trash.png",
      "name": "Trash",
      "isClean": false,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/clean_clothes.png",
      "name": "Clean Clothes",
      "isClean": true,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/toothbrush.png",
      "name": "Toothbrush",
      "isClean": true,
      "isSelected": false,
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/dirty_hands.png",
      "name": "Dirty Hands",
      "isClean": false,
      "isSelected": false,
    },
  ].obs;

  var collectedCleanItems = 0.obs;
  var totalCleanItems = 0.obs;
  var showCompletion = false.obs;

  @override
  void onInit() {
    super.onInit();
    totalCleanItems.value = items.where((item) => item["isClean"] == true).length;
    shuffleItems();
  }

  void shuffleItems() {
    items.shuffle();
    for (var item in items) {
      item["isSelected"] = false;
    }
    collectedCleanItems.value = 0;
    showCompletion.value = false;
  }

  void toggleItemSelection(int index) {
    if (showCompletion.value) return; 
    
    bool wasSelected = items[index]["isSelected"] == true;
    items[index]["isSelected"] = !wasSelected;
    
    if (items[index]["isClean"] == true) {
      if (!wasSelected) {
        collectedCleanItems.value++;
      } else {
        collectedCleanItems.value--;
      }
    }
    
    items.refresh(); 
    
    if (collectedCleanItems.value >= totalCleanItems.value) {
      showCompletion.value = true;
      Get.snackbar(
        "Great job! 🎉",
        "You found all the clean items!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void checkAnswerAndNavigate() {
    if (collectedCleanItems.value >= totalCleanItems.value) {
      Get.to(() => const sensoryscreen()); 
    } else {
      int remaining = totalCleanItems.value - collectedCleanItems.value;
      Get.snackbar(
        "Keep looking!",
        "Find $remaining more clean items",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
    }
  }

  void resetQuiz() {
    shuffleItems();
    showCompletion.value = false;
  }
}