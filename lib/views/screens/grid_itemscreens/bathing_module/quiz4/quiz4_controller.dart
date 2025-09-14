import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz5/quiz5_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';

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
      "placedSensations": <String>[]
    },
    {
      "id": "towel",
      "name": "Towel",
      "icon": "lib/assets/quiz4_sensations/towel.png",
      "acceptedSensations": ["soft", "fluffy"],
      "placedSensations": <String>[]
    },
    {
      "id": "water",
      "name": "Water",
      "icon": "lib/assets/quiz4_sensations/water.png",
      "acceptedSensations": ["wet", "warm"],
      "placedSensations": <String>[]
    },
  ].obs;

  var totalMatches = 6.obs;
  var completedMatches = 0.obs;
  var showCompletion = false.obs;
  var retries = 0.obs;
  var wrongPlacements = 0.obs;
  var hasSubmitted = false.obs;

  final audioService = AudioInstructionService.to;
  final bathingModuleController = Get.find<BathingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Great! Let's match sensations to bathing items! Drag and drop sensations to the correct items."
      );
    });

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
    hasSubmitted.value = false;
    wrongPlacements.value = 0;

    sensations.refresh();
    items.refresh();

    audioService.setInstructionAndSpeak("Match the sensations to the correct bathing items!");
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

      audioService.playCorrectFeedback();
      // audioService.speakText(sensation["name"]); // speak sensation name only

      if (completedMatches.value >= totalMatches.value) {
        completeQuiz();
      }

      items.refresh();
      sensations.refresh();
    } else {
      audioService.playIncorrectFeedback();
      wrongPlacements.value++;

      bathingModuleController.recordWrongAnswer(
        quizId: "quiz4",
        questionId: "Sensation matching",
        wrongAnswer: "Placed ${sensation["name"]} on ${item["name"]}",
        correctAnswer: "${item["acceptedSensations"]} are correct for ${item["name"]}",
      );
    }
  }

  void removeSensation(String itemId, String sensationId) {
    final item = items.firstWhere((item) => item["id"] == itemId);
    final placedSensations = item["placedSensations"] as List<String>;

    if (placedSensations.contains(sensationId)) {
      placedSensations.remove(sensationId);
      completedMatches.value--;
      items.refresh();
      audioService.speakText("Removed ${getSensation(sensationId)["name"]}");
    }
  }

  void checkAnswerAndNavigate() {
    if (completedMatches.value >= totalMatches.value) {
      showCompletion.value = true;
      audioService.playCorrectFeedback();

      Future.delayed(const Duration(seconds: 2), () {
        Get.to(() => const afterbathscreen());
      });
    } else {
      int remaining = totalMatches.value - completedMatches.value;

      audioService.playIncorrectFeedback();
      audioService.setInstructionAndSpeak("Find $remaining more matches to continue.");

      Get.snackbar(
        "Almost there!",
        "Find $remaining more matches",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;

    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak("Excellent! You matched all the sensations correctly!");

    bathingModuleController.recordQuizResult(
      quizId: "quiz4",
      score: completedMatches.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongPlacements.value,
    );

    bathingModuleController.syncModuleProgress();

    Get.snackbar(
      "Amazing! 🎉",
      "You matched all sensations perfectly!",
      backgroundColor: Colors.green.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Map<String, dynamic> getSensation(String sensationId) {
    return sensations.firstWhere((s) => s["id"] == sensationId);
  }

  Map<String, dynamic> getItem(String itemId) {
    return items.firstWhere((item) => item["id"] == itemId);
  }

  void playItemAudio(String itemId) {
    final item = getItem(itemId);
    audioService.speakText(item["name"]);
  }

  void playSensationAudio(String sensationId) {
    final sensation = getSensation(sensationId);
    audioService.speakText(sensation["name"]);
  }

  double getProgressPercentage() => completedMatches.value / totalMatches.value;
  int getRemainingMatches() => totalMatches.value - completedMatches.value;

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
