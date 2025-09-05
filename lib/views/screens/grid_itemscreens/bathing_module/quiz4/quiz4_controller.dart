import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz5/quiz5_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SensoryController extends GetxController {
  var sensations = [
  {"id": "smooth", "name": "Smooth", "icon": "lib/assets/quiz4_sensations/smooth.png", "isDragging": false},
  {"id": "soft", "name": "Soft", "icon": "lib/assets/quiz4_sensations/soft.png", "isDragging": false},
  {"id": "wet", "name": "Wet", "icon": "lib/assets/quiz4_sensations/wet.png", "isDragging": false},
  {"id": "fluffy", "name": "Fluffy", "icon": "lib/assets/quiz4_sensations/fluffy.png", "isDragging": false},
  {"id": "slippery", "name": "Slippery", "icon": "lib/assets/quiz4_sensations/slippery.png", "isDragging": false},
  {"id": "warm", "name": "Warm", "icon": "lib/assets/quiz4_sensations/warm.png", "isDragging": false},
].obs;

var items = [
  {
    "id": "soap",
    "name": "Soap",
    "icon": "lib/assets/quiz4_sensations/soap.png",
    "acceptedSensations": ["smooth", "slippery"],
    "placedSensations": <String>[],
  },
  {
    "id": "towel",
    "name": "Towel",
    "icon": "lib/assets/quiz4_sensations/towel.png",
    "acceptedSensations": ["soft", "fluffy"],
    "placedSensations": <String>[],
  },
  {
    "id": "water",
    "name": "Water",
    "icon": "lib/assets/quiz4_sensations/water.png",
    "acceptedSensations": ["wet", "warm"],
    "placedSensations": <String>[],
  },
].obs;


  var totalMatches = 6.obs;
  var completedMatches = 0.obs;
  var showCompletion = false.obs;

  @override
  void onInit() {
    super.onInit();
    resetQuiz();
  }

  void resetQuiz() {
    for (var sensation in sensations) {
      sensation["isDragging"] = false;
    }
    for (var item in items) {
      item["placedSensations"] = <String>[];
    }
    completedMatches.value = 0;
    showCompletion.value = false;
    sensations.refresh();
    items.refresh();
  }

bool canAcceptSensation(String itemId, String sensationId) {
  final item = items.firstWhere((item) => item["id"] == itemId);
  final placedSensations = (item["placedSensations"] as List).cast<String>();
  return (item["acceptedSensations"] as List).contains(sensationId) &&
      !placedSensations.contains(sensationId);
}


  void placeSensation(String itemId, String sensationId) {
    final item = items.firstWhere((item) => item["id"] == itemId);
    final sensation = sensations.firstWhere((s) => s["id"] == sensationId);
    final placedSensations = item["placedSensations"] as List<String>;

    if (canAcceptSensation(itemId, sensationId)) {
      placedSensations.add(sensationId);
      sensation["isDragging"] = false;
      completedMatches.value++;

      if (completedMatches.value >= totalMatches.value) {
        showCompletion.value = true;
        Get.snackbar(
          "Awesome! 🎉",
          "You matched all the sensations!",
          backgroundColor: Colors.green.shade300,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }

      items.refresh();
      sensations.refresh();
    }
  }

  void removeSensation(String itemId, String sensationId) {
    final item = items.firstWhere((item) => item["id"] == itemId);
    final placedSensations = item["placedSensations"] as List<String>;

    if (placedSensations.contains(sensationId)) {
      placedSensations.remove(sensationId);
      completedMatches.value--;
      items.refresh();
    }
  }

void checkAnswerAndNavigate() {
  if (completedMatches.value >= totalMatches.value) {
    showCompletion.value = true;
    Get.snackbar(
      "Awesome! 🎉",
      "You matched all the sensations!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    Future.delayed(const Duration(seconds: 5), () {
      // Navigate to the next screen
      Get.to(() => const afterbathscreen());
      

    });
  } else {
    int remaining = totalMatches.value - completedMatches.value;
    Get.snackbar(
      "Keep going!",
      "Find $remaining more matches",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

  Map<String, dynamic> getSensation(String sensationId) {
    return sensations.firstWhere((s) => s["id"] == sensationId);
  }

  Map<String, dynamic> getItem(String itemId) {
    return items.firstWhere((item) => item["id"] == itemId);
  }
}
