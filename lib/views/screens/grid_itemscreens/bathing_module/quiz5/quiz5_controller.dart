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
      "description": "Dry your body completely",
      "audio": "bathing_audios/dry_towel.mp3"
    },
    {
      "id": "lotion",
      "name": "Apply lotion",
      "icon": "lib/assets/afterbath/lotion.png",
      "description": "Moisturize your skin",
      "audio": "bathing_audios/apply_lotion.mp3"
    },
    {
      "id": "dress",
      "name": "Put on clothes",
      "icon": "lib/assets/afterbath/clean_clothes.png",
      "description": "Get dressed in clean clothes",
      "audio": "bathing_audios/put_clothes.mp3"
    },
    {
      "id": "comb",
      "name": "Comb hair",
      "icon": "lib/assets/afterbath/comb.png",
      "description": "Comb your hair neatly",
      "audio": "bathing_audios/comb_hair.mp3"
    },
    {
      "id": "slippers",
      "name": "Wear slippers",
      "icon": "lib/assets/afterbath/slippers.png",
      "description": "Put on comfortable slippers",
      "audio": "bathing_audios/wear_slippers.mp3"
    },
    {
      "id": "clean",
      "name": "Clean area",
      "icon": "lib/assets/afterbath/cleanbath.png",
      "description": "Tidy up the bathroom",
      "audio": "bathing_audios/clean_area.mp3"
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
        "Let's arrange the after-bath steps in the correct order!",
        "goingbed_audios/afterbath_intro.mp3",
      );
    });
    
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
    hasSubmitted.value = false;
    retries.value++;
    
    audioService.setInstructionAndSpeak(
      "Arrange the after-bath steps in the correct sequence!",
      "bathing_audios/afterbath_retry.mp3",
    );
  }

  void addStepToSequence(Map<String, String> step) {
    if (currentSequence.length < totalSteps.value) {
      currentSequence.add(step);
      availableSteps.remove(step);
      
      // Play placement sound
      // audioService.playSoundEffect("bathing_audios/step_placed.mp3");
    }
  }

  void removeStepFromSequence(int index) {
    if (index < currentSequence.length) {
      var step = currentSequence.removeAt(index);
      availableSteps.add(step);
      
      // Play removal sound
      // audioService.playSoundEffect("bathing_audios/step_removed.mp3");
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
        "Excellent! You arranged the after-bath routine perfectly!",
        "bathing_audios/afterbath_perfect.mp3",
      );
      
      // Record quiz result
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
      // All steps placed but incorrect order
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      
      // Record wrong attempt
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
      
      // Remove the step from available first
      availableSteps.removeAt(availableIndex);
      
      // Insert at the target position if valid, otherwise append
      if (targetIndex >= 0 && targetIndex <= currentSequence.length) {
        currentSequence.insert(targetIndex, step);
      } else {
        currentSequence.add(step);
      }
      
      // Play step audio
      final stepAudio = step["audio"];
      if (stepAudio != null) {
        // audioService.playSoundEffect(stepAudio);
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
    final stepAudio = step["audio"];
    // if (stepAudio != null) {
    //   audioService.playSoundEffect(stepAudio);
    // } else {
    //   audioService.speak(step["name"] ?? "");
    // }
  }

  // Get progress percentage
  double getProgressPercentage() {
    return currentSequence.length / totalSteps.value;
  }

  // Get remaining steps count
  int getRemainingSteps() {
    return totalSteps.value - currentSequence.length;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}