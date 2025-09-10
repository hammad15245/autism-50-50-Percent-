import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz5/quiz5_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';

class SensoryController extends GetxController {
  var sensations = [
    {"id": "smooth", "name": "Smooth", "icon": "lib/assets/quiz4_sensations/smooth.png", "isDragging": false, "audio": "bathing_audios/smooth.mp3"},
    {"id": "soft", "name": "Soft", "icon": "lib/assets/quiz4_sensations/soft.png", "isDragging": false, "audio": "bathing_audios/soft.mp3"},
    {"id": "wet", "name": "Wet", "icon": "lib/assets/quiz4_sensations/wet.png", "isDragging": false, "audio": "bathing_audios/wet.mp3"},
    {"id": "fluffy", "name": "Fluffy", "icon": "lib/assets/quiz4_sensations/fluffy.png", "isDragging": false, "audio": "bathing_audios/fluffy.mp3"},
    {"id": "slippery", "name": "Slippery", "icon": "lib/assets/quiz4_sensations/slippery.png", "isDragging": false, "audio": "bathing_audios/slippery.mp3"},
    {"id": "warm", "name": "Warm", "icon": "lib/assets/quiz4_sensations/warm.png", "isDragging": false, "audio": "bathing_audios/warm.mp3"},
  ].obs;

  var items = [
    {
      "id": "soap",
      "name": "Soap",
      "icon": "lib/assets/quiz4_sensations/soap.png",
      "acceptedSensations": ["smooth", "slippery"],
      "placedSensations": <String>[],
      "audio": "bathing_audios/soap.mp3"
    },
    {
      "id": "towel",
      "name": "Towel",
      "icon": "lib/assets/quiz4_sensations/towel.png",
      "acceptedSensations": ["soft", "fluffy"],
      "placedSensations": <String>[],
      "audio": "bathing_audios/towel.mp3"
    },
    {
      "id": "water",
      "name": "Water",
      "icon": "lib/assets/quiz4_sensations/water.png",
      "acceptedSensations": ["wet", "warm"],
      "placedSensations": <String>[],
      "audio": "bathing_audios/water.mp3"
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
        "Great Let's match sensations to bathing items! Drag and drop sensations to the correct items.",
        "goingbed_audios/sensations_intro.mp3",
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
    
    audioService.setInstructionAndSpeak(
      "Match the sensations to the correct bathing items!",
      "bathing_audios/sensations_retry.mp3",
    );
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

      // Play correct feedback and sensation audio
      audioService.playCorrectFeedback();
      final sensationAudio = sensation["audio"] as String?;
      if (sensationAudio != null) {
        // audioService.playSoundEffect(sensationAudio);
      }

      if (completedMatches.value >= totalMatches.value) {
        completeQuiz();
      }

      items.refresh();
      sensations.refresh();
    } else {
      // Play incorrect feedback for wrong placement
      audioService.playIncorrectFeedback();
      wrongPlacements.value++;
      
      // Record wrong answer
      final itemName = item["name"] as String;
      final sensationName = sensation["name"] as String;
      bathingModuleController.recordWrongAnswer(
        quizId: "quiz4",
        questionId: "Sensation matching",
        wrongAnswer: "Placed $sensationName on $itemName",
        correctAnswer: "${item["acceptedSensations"]} are correct for $itemName",
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
      
      // Play removal sound
      // audioService.playSoundEffect("bathing_audios/remove.mp3");
    }
  }

  void checkAnswerAndNavigate() {
    if (completedMatches.value >= totalMatches.value) {
      showCompletion.value = true;
      audioService.playCorrectFeedback();
      
      Future.delayed(const Duration(seconds: 2), () {
        // Navigate to the next screen
        Get.to(() => const afterbathscreen());
      });
    } else {
      int remaining = totalMatches.value - completedMatches.value;
      
      audioService.playIncorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Find $remaining more matches to continue.",
        "bathing_audios/more_matches_needed.mp3",
      );
      
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
    audioService.setInstructionAndSpeak(
      "Excellent! You matched all the sensations correctly!",
      "bathing_audios/all_sensations_matched.mp3",
    );
    
    // Record quiz result
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

  // ADD BACK THE MISSING METHOD
  Map<String, dynamic> getSensation(String sensationId) {
    return sensations.firstWhere((s) => s["id"] == sensationId);
  }

  Map<String, dynamic> getItem(String itemId) {
    return items.firstWhere((item) => item["id"] == itemId);
  }

  void playItemAudio(String itemId) {
    final item = items.firstWhere((item) => item["id"] == itemId);
    final itemAudio = item["audio"] as String?;
    // if (itemAudio != null) {
    //   audioService.playSoundEffect(itemAudio);
    // } else {
    //   audioService.speak(item["name"] as String);
    // }
  }

  void playSensationAudio(String sensationId) {
    final sensation = sensations.firstWhere((s) => s["id"] == sensationId);
    final sensationAudio = sensation["audio"] as String?;
    // if (sensationAudio != null) {
    //   audioService.playSoundEffect(sensationAudio);
    // } else {
    //   audioService.speak(sensation["name"] as String);
    // }
  }

  // Get progress percentage
  double getProgressPercentage() {
    return completedMatches.value / totalMatches.value;
  }

  // Get remaining matches count
  int getRemainingMatches() {
    return totalMatches.value - completedMatches.value;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}