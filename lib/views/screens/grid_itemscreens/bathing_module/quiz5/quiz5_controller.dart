import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AfterBathController extends GetxController {
  final correctSequence = [
    {
      "id": "dry",
      "name": "Dry with towel",
      "icon": "lib/assets/afterbath/towel.png",
      "description": "Dry your body completely"
    },
    {
      "id": "lotion",
      "name": "Apply lotion",
      "icon": "lib/assets/afterbath/lotion.png",
      "description": "Moisturize your skin"
    },
    {
      "id": "dress",
      "name": "Put on clothes",
      "icon": "lib/assets/afterbath/clean_clothes.png",
      "description": "Get dressed in clean clothes"
    },
    {
      "id": "comb",
      "name": "Comb hair",
      "icon": "lib/assets/afterbath/comb.png",
      "description": "Comb your hair neatly"
    },
    {
      "id": "slippers",
      "name": "Wear slippers",
      "icon": "lib/assets/afterbath/slippers.png",
      "description": "Put on comfortable slippers"
    },
    {
      "id": "clean",
      "name": "Clean area",
      "icon": "lib/assets/afterbath/cleanbath.png",
      "description": "Tidy up the bathroom"
    },
  ];

  var currentSequence = <Map<String, String>>[].obs; 
  var availableSteps = <Map<String, String>>[].obs;

  var isSequenceCorrect = false.obs;
  var showCompletion = false.obs;
  var totalSteps = 6.obs;

  var _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    // Only reset if not already initialized
    if (!_isInitialized) {
      resetQuiz();
      _isInitialized = true;
    }
  }

  void resetQuiz() {
    availableSteps.clear();
    availableSteps.addAll(List.from(correctSequence)..shuffle());
    currentSequence.clear();
    isSequenceCorrect.value = false;
    showCompletion.value = false;
  }

  void addStepToSequence(Map<String, String> step) {
    if (currentSequence.length < totalSteps.value) {
      currentSequence.add(step);
      availableSteps.remove(step);
    }
  }

  void removeStepFromSequence(int index) {
    if (index < currentSequence.length) {
      var step = currentSequence.removeAt(index);
      availableSteps.add(step);
    }
  }

  void checkSequence() {
    bool correct = true;
    for (int i = 0; i < correctSequence.length; i++) {
      if (i >= currentSequence.length ||
          currentSequence[i]["id"] != correctSequence[i]["id"]) {
        correct = false;
        break;
      }
    }
    isSequenceCorrect.value = correct;
    if (correct && currentSequence.length == totalSteps.value) {
      showCompletion.value = true;
      Get.snackbar(
        "Perfect! 🎉",
        "You got the after-bath routine right!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

void moveToSequence(int availableIndex, int targetIndex) {
  if (availableIndex < availableSteps.length) {
    final step = availableSteps[availableIndex];
    
    // Remove the step from available first
    availableSteps.removeAt(availableIndex);
    
    // Insert at the target position if valid, otherwise append
    if (targetIndex >= 0 && targetIndex <= currentSequence.length) {
      currentSequence.insert(targetIndex, step);
    } else {
      currentSequence.add(step);
    }
    
    update();
  }
}

  void moveToAvailable(int sequenceIndex) {
    if (sequenceIndex < currentSequence.length) {
      removeStepFromSequence(sequenceIndex);
    }
  }

  void checkAnswerAndNavigate() {
    // Check the sequence only when the user clicks "Check"
    checkSequence();
    
    if (isSequenceCorrect.value) {
      Get.snackbar(
        "Great job!",
        "You completed the after-bath routine!",
        backgroundColor: Colors.blue.shade300,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Almost there!",
        "Please arrange all steps correctly",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
      );
    }
  }
}