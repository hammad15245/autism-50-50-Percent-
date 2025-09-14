import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';

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
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;

  final audioService = AudioInstructionService.to;
  final bathingModuleController = Get.find<BathingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Let's arrange the after-bath steps in the correct order!"
      );
    });
    
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
    hasSubmitted.value = false;
    retries.value++;
    
    audioService.setInstructionAndSpeak(
      "Arrange the after-bath steps in the correct sequence!"
    );
  }

  void addStepToSequence(Map<String, String> step) {
    if (currentSequence.length < totalSteps.value) {
      currentSequence.add(step);
      availableSteps.remove(step);
      audioService.speakText("Added step: ${step["name"]}");
    }
  }

  void removeStepFromSequence(int index) {
    if (index < currentSequence.length) {
      var step = currentSequence.removeAt(index);
      availableSteps.add(step);
      audioService.speakText("Removed step: ${step["name"]}");
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
      hasSubmitted.value = true;
      
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Excellent! You arranged the after-bath routine perfectly!"
      );
      
      bathingModuleController.recordQuizResult(
        quizId: "quiz5",
        score: totalSteps.value,
        retries: retries.value,
        isCompleted: true,
        wrongAnswersCount: wrongAttempts.value,
      );
      
      bathingModuleController.syncModuleProgress();
      
      Get.snackbar(
        "Perfect! 🎉",
        "You got the after-bath routine right!",
        backgroundColor: Colors.green.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (currentSequence.length == totalSteps.value) {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      
      bathingModuleController.recordWrongAnswer(
        quizId: "quiz5",
        questionId: "After-bath sequence",
        wrongAnswer: "Incorrect sequence order",
        correctAnswer: "Correct sequence: ${correctSequence.map((s) => s["name"]).join(" → ")}",
      );
    }
  }

  void moveToSequence(int availableIndex, int targetIndex) {
    if (availableIndex < availableSteps.length) {
      final step = availableSteps[availableIndex];
      availableSteps.removeAt(availableIndex);
      
      if (targetIndex >= 0 && targetIndex <= currentSequence.length) {
        currentSequence.insert(targetIndex, step);
      } else {
        currentSequence.add(step);
      }
      
      audioService.speakText("Placed: ${step["name"]}");
      update();
    }
  }

  void moveToAvailable(int sequenceIndex) {
    if (sequenceIndex < currentSequence.length) {
      removeStepFromSequence(sequenceIndex);
    }
  }

  void checkAnswerAndNavigate() {
    checkSequence();
    
    if (isSequenceCorrect.value) {
      audioService.playCorrectFeedback();
      Get.snackbar(
        "Great job!",
        "You completed the after-bath routine!",
        backgroundColor: Colors.blue.shade300,
        colorText: Colors.white,
      );
    } else {
      audioService.playIncorrectFeedback();
      Get.snackbar(
        "Almost there!",
        "Please arrange all steps correctly",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
      );
    }
  }

  void playStepAudio(Map<String, String> step) {
    audioService.speakText(step["description"] ?? step["name"] ?? "");
  }

  double getProgressPercentage() {
    return currentSequence.length / totalSteps.value;
  }

  int getRemainingSteps() {
    return totalSteps.value - currentSequence.length;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
