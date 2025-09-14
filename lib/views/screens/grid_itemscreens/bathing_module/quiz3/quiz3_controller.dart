import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class CleanDirtyController extends GetxController {
  var items = [
    {"image": "lib/assets/quiz3_cleanvsdirty/soap.png", "name": "Soap", "isClean": true, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/towel.png", "name": "Clean Towel", "isClean": true, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/shampoo.png", "name": "Shampoo", "isClean": true, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/mud.png", "name": "Mud", "isClean": false, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/dirty_clothes.png", "name": "Dirty Clothes", "isClean": false, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/trash.png", "name": "Trash", "isClean": false, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/clean_clothes.png", "name": "Clean Clothes", "isClean": true, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/toothbrush.png", "name": "Toothbrush", "isClean": true, "isSelected": false},
    {"image": "lib/assets/quiz3_cleanvsdirty/dirty_hands.png", "name": "Dirty Hands", "isClean": false, "isSelected": false},
  ].obs;

  var collectedCleanItems = 0.obs;
  var totalCleanItems = 0.obs;
  var showCompletion = false.obs;
  var retries = 0.obs;
  var wrongSelections = 0.obs;
  var hasSubmitted = false.obs;

  final audioService = AudioInstructionService.to;
  final bathingModuleController = Get.find<BathingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    totalCleanItems.value = items.where((item) => item["isClean"] == true).length;
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Ok kiddos! Find and select all the clean items! Tap on clean things you would use for bathing."
      );
    });
    shuffleItems();
  }

  void shuffleItems() {
    items.shuffle();
    for (var item in items) {
      item["isSelected"] = false;
    }
    collectedCleanItems.value = 0;
    showCompletion.value = false;
    hasSubmitted.value = false;
    audioService.setInstructionAndSpeak("Let's shuffle the items!");
  }

  void toggleItemSelection(int index) {
    if (showCompletion.value || hasSubmitted.value) return;

    bool wasSelected = items[index]["isSelected"] == true;
    items[index]["isSelected"] = !wasSelected;

    final itemName = items[index]["name"] as String;
    audioService.speakText(itemName);

    if (items[index]["isClean"] == true) {
      if (!wasSelected) {
        collectedCleanItems.value++;
        audioService.playCorrectFeedback();
      } else {
        collectedCleanItems.value--;
      }
    } else {
      if (!wasSelected) {
        wrongSelections.value++;
        audioService.playIncorrectFeedback();

        bathingModuleController.recordWrongAnswer(
          quizId: "quiz3",
          questionId: "Clean vs Dirty items",
          wrongAnswer: "Selected dirty item: $itemName",
          correctAnswer: "Should not select dirty items",
        );
      } else {
        wrongSelections.value--;
      }
    }

    items.refresh();

    if (collectedCleanItems.value >= totalCleanItems.value) {
      completeQuiz();
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak("Great job! You found all the clean items!");

    bathingModuleController.recordQuizResult(
      quizId: "quiz3",
      score: collectedCleanItems.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongSelections.value,
    );

    bathingModuleController.syncModuleProgress();

    Get.snackbar(
      "Great job! 🎉",
      "You found all the clean items!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void checkAnswerAndNavigate() {
    if (collectedCleanItems.value >= totalCleanItems.value) {
      Get.to(() => const sensoryscreen());
    } else {
      int remaining = totalCleanItems.value - collectedCleanItems.value;
      audioService.playIncorrectFeedback();
      audioService.setInstructionAndSpeak("Find $remaining more clean items to continue.");

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
    retries.value++;
    shuffleItems();
    wrongSelections.value = 0;
    audioService.setInstructionAndSpeak("Let's try finding clean items again!");
  }

  double getProgressPercentage() => collectedCleanItems.value / totalCleanItems.value;
  int getRemainingCleanItems() => totalCleanItems.value - collectedCleanItems.value;
  bool isItemSelected(int index) => items[index]["isSelected"] == true;

  Color getItemFeedbackColor(int index) {
    if (!isItemSelected(index)) return Colors.transparent;
    return items[index]["isClean"] == true ? Colors.green.shade100 : Colors.red.shade100;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
