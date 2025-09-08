import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/home_animal_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class AnimalShadowsController extends GetxController {
  final audioService = AudioInstructionService.to;
final homeAnimalsController = Get.find<HomeAnimalsController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentLevel = 0.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var matchedAnimals = <String, bool>{}.obs;

  var lastDragResult = RxString('');
  var lastDraggedAnimalId = RxString('');
  var lastTargetAnimalId = RxString('');

  final int totalScorePerQuiz = 5;
  var earnedScore = 0.obs;
  var retries = 0.obs;

  final String quizid = "2";

  final List<Map<String, dynamic>> levels = [
    {
      "pairs": [
        {
          "animal": {
            "id": "dog",
            "name": "Dog",
            "icon": "lib/assets/home_animals/dog.png",
            "shadow": "lib/assets/home_animals/dog_shadow.png"
          }
        },
        {
          "animal": {
            "id": "cat",
            "name": "Cat",
            "icon": "lib/assets/home_animals/cat.png",
            "shadow": "lib/assets/home_animals/cat_shadow.png"
          }
        },
        {
          "animal": {
            "id": "rabbit",
            "name": "Rabbit",
            "icon": "lib/assets/home_animals/rabbit.png",
            "shadow": "lib/assets/home_animals/rabbit_shadow.png"
          }
        },
        {
          "animal": {
            "id": "bird",
            "name": "Bird",
            "icon": "lib/assets/home_animals/bird.png",
            "shadow": "lib/assets/home_animals/bird_shadow.png"
          }
        }
      ]
    }
  ];

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "Okay kiddos lets start matching the shadows with animals.",
      "goingbed_audios/shadows_intro.mp3",
    );
  }

  void handleDrag(String draggedAnimalId, String targetAnimalId) {
    lastDraggedAnimalId.value = draggedAnimalId;
    lastTargetAnimalId.value = targetAnimalId;

    if (draggedAnimalId == targetAnimalId) {
      lastDragResult.value = 'correct';
      checkMatch(draggedAnimalId);
    } else {
      lastDragResult.value = 'wrong';
      retries.value++;
      Future.delayed(const Duration(milliseconds: 1000), () {
        lastDragResult.value = '';
      });
    }
  }

  void checkMatch(String animalId) {
    matchedAnimals[animalId] = true;
    if (matchedAnimals.length == levels[currentLevel.value]["pairs"].length) {
      isCorrect.value = true;
      showFeedback.value = true;

      earnedScore.value = totalScorePerQuiz;
      updateProgress();

      audioService.playCorrectFeedback();
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      lastDragResult.value = '';
    });
  }

  Future<void> updateProgress() async {
    try {
      homeAnimalsController.recordQuizResult(
        quizId: quizid,
        score: earnedScore.value,
        retries: retries.value,
        isCompleted: true,
      );
      await homeAnimalsController.syncModuleProgress();
    } catch (e) {
      print("❌ Error updating progress: $e");
    }
  }

  void resetLevel() {
    matchedAnimals.clear();
    showFeedback.value = false;
    lastDragResult.value = '';
    lastDraggedAnimalId.value = '';
    lastTargetAnimalId.value = '';
  }

  void nextLevel() {
    if (currentLevel.value < levels.length - 1) {
      currentLevel.value++;
      resetLevel();
    } else {
      audioService.setInstructionAndSpeak(
        "Excellent shadow matching! You're a pattern expert!",
        "assets/goingbed_audios/shadows_complete.mp3",
      );
    }
  }

  bool shouldShowFeedback(String targetAnimalId) {
    return lastDragResult.value.isNotEmpty &&
        lastTargetAnimalId.value == targetAnimalId;
  }

  Color getBorderColor(String targetAnimalId) {
    if (!shouldShowFeedback(targetAnimalId)) {
      return matchedAnimals[targetAnimalId] == true
          ? Colors.green
          : Colors.grey[300]!;
    }
    return lastDragResult.value == 'correct' ? Colors.green : Colors.red;
  }

  Map<String, dynamic> get currentLevelData => levels[currentLevel.value];
  bool get isLastLevel => currentLevel.value == levels.length - 1;

  double get progressPercentage {
    return matchedAnimals.length / levels[currentLevel.value]["pairs"].length;
  }
}
