import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class CleanDirtyController extends GetxController {
  var items = [
    {
      "image": "lib/assets/quiz3_cleanvsdirty/soap.png",
      "name": "Soap",
      "isClean": true,
      "isSelected": false,
      "audio": "bathing_audios/soap_clean.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/towel.png",
      "name": "Clean Towel",
      "isClean": true,
      "isSelected": false,
      "audio": "bathing_audios/towel_clean.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/shampoo.png",
      "name": "Shampoo",
      "isClean": true,
      "isSelected": false,
      "audio": "bathing_audios/shampoo_clean.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/mud.png",
      "name": "Mud",
      "isClean": false,
      "isSelected": false,
      "audio": "bathing_audios/mud_dirty.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/dirty_clothes.png",
      "name": "Dirty Clothes",
      "isClean": false,
      "isSelected": false,
      "audio": "bathing_audios/dirty_clothes.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/trash.png",
      "name": "Trash",
      "isClean": false,
      "isSelected": false,
      "audio": "bathing_audios/trash_dirty.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/clean_clothes.png",
      "name": "Clean Clothes",
      "isClean": true,
      "isSelected": false,
      "audio": "bathing_audios/clean_clothes.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/toothbrush.png",
      "name": "Toothbrush",
      "isClean": true,
      "isSelected": false,
      "audio": "bathing_audios/toothbrush_clean.mp3"
    },
    {
      "image": "lib/assets/quiz3_cleanvsdirty/dirty_hands.png",
      "name": "Dirty Hands",
      "isClean": false,
      "isSelected": false,
      "audio": "bathing_audios/dirty_hands.mp3"
    },
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
        "Ok kiddos Find and select all the clean items! Tap on clean things you would use for bathing.",
        "goingbed_audios/clean_dirty_intro.mp3",
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
    
    // audioService.playSoundEffect("bathing_audios/shuffle.mp3");
  }

  void toggleItemSelection(int index) {
    if (showCompletion.value || hasSubmitted.value) return; 
    
    bool wasSelected = items[index]["isSelected"] == true;
    items[index]["isSelected"] = !wasSelected;
    
    // Play selection sound
    // audioService.playSoundEffect("bathing_audios/selection.mp3");
    
    // Speak item name
    final itemName = items[index]["name"] as String;
    final itemAudio = items[index]["audio"] as String?;
    
    // if (itemAudio != null) {
    //   audioService.playSoundEffect(itemAudio);
    // } else {
    //   audioService.speak(itemName);
    // }
    
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
        
        // Record wrong selection
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
    audioService.setInstructionAndSpeak(
      "Great job! You found all the clean items!",
      "bathing_audios/all_clean_found.mp3",
    );
    
    // Record quiz result
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
      audioService.setInstructionAndSpeak(
        "Find $remaining more clean items to continue.",
        "bathing_audios/more_clean_needed.mp3",
      );
      
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
    
    audioService.setInstructionAndSpeak(
      "Let's try finding clean items again!",
      "bathing_audios/clean_dirty_retry.mp3",
    );
  }

  // Get progress percentage
  double getProgressPercentage() {
    return collectedCleanItems.value / totalCleanItems.value;
  }

  // Get remaining clean items count
  int getRemainingCleanItems() {
    return totalCleanItems.value - collectedCleanItems.value;
  }

  // Check if an item is currently selected
  bool isItemSelected(int index) {
    return items[index]["isSelected"] == true;
  }

  // Get feedback for item selection
  Color getItemFeedbackColor(int index) {
    if (!isItemSelected(index)) return Colors.transparent;
    
    if (items[index]["isClean"] == true) {
      return Colors.green.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}