import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz3/quiz3_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BathingSequenceController extends GetxController {
  final List<String> correctStepOrder = [
    "Turn on water",
    "Get undressed",
    "Get in tub",
    "Wash with soap",
    "Rinse off",
    "Dry with towel",
    "Get dressed"
  ].obs;

  var stepData = [
    {"step": "Turn on water", "description": "Start with warm water"},
    {"step": "Get undressed", "description": "Take off clothes"},
    {"step": "Get in tub", "description": "Step into bathtub"},
    {"step": "Wash with soap", "description": "Use soap to clean body"},
    {"step": "Rinse off", "description": "Wash off all soap"},
    {"step": "Dry with towel", "description": "Dry yourself completely"},
    {"step": "Get dressed", "description": "Put on clean clothes"}
  ].obs;

  var currentSequence = <Map<String, String>>[].obs;
  var isSequenceCorrect = false.obs;
  var showCompletion = false.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
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
        "Great! Let's arrange the bathing steps in the correct order! Drag and drop the bathing steps to sequence them properly."
      );
    });

    _initializeSequences();
  }

  void _initializeSequences() {
    currentSequence.assignAll(List.from(stepData)..shuffle());
  }

  void shuffleSequence() {
    currentSequence.assignAll(List.from(stepData)..shuffle());
    isSequenceCorrect.value = false;
    showCompletion.value = false;
    hasSubmitted.value = false;

    audioService.speakText("Steps shuffled. Try arranging them again!");
  }

  void checkallanswerandnavigate() {
    if (hasSubmitted.value) return;

    if (!_areSequencesValid()) return;

    _performSequenceCheck();
  }

  bool _areSequencesValid() {
    if (correctStepOrder.isEmpty) {
      _showErrorSnackbar("Configuration error: No sequence data available");
      return false;
    }

    if (currentSequence.isEmpty) {
      _showErrorSnackbar("Please arrange the steps first");
      return false;
    }

    if (currentSequence.length != correctStepOrder.length) {
      _showErrorSnackbar("Please complete all steps in the sequence");
      return false;
    }

    return true;
  }

  void _showErrorSnackbar(String message) {
    audioService.playIncorrectFeedback();
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _performSequenceCheck() {
    hasSubmitted.value = true;

    List<String> currentStepOrder = currentSequence
        .map((step) => (step["step"] ?? "").trim().toLowerCase())
        .toList();

    List<String> correctOrder = correctStepOrder
        .map((e) => e.trim().toLowerCase())
        .toList();

    bool isCorrect = listEquals(currentStepOrder, correctOrder);
    isSequenceCorrect.value = isCorrect;
    showCompletion.value = true;

    if (isCorrect) {
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Perfect! You arranged all bathing steps in the correct order!"
      );

      bathingModuleController.recordQuizResult(
        quizId: "quiz2",
        score: 1,
        retries: retries.value,
        isCompleted: true,
        wrongAnswersCount: wrongAttempts.value,
      );

      bathingModuleController.syncModuleProgress();

      Future.delayed(const Duration(seconds: 3), () {
        Get.off(() => CleanDirtyScreen());
      });
    } else {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();

      bathingModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Bathing sequence",
        wrongAnswer: currentStepOrder.join(" → "),
        correctAnswer: correctOrder.join(" → "),
      );

      audioService.setInstructionAndSpeak(
        "Almost there! Try again to get the bathing order right."
      );

      Get.snackbar(
        "Almost there!",
        "Try again to get the order right",
        backgroundColor: Colors.orange.shade300,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= currentSequence.length ||
        newIndex < 0 ||
        newIndex > currentSequence.length) return;

    if (oldIndex < newIndex) newIndex -= 1;
    final item = currentSequence.removeAt(oldIndex);
    currentSequence.insert(newIndex, item);

    print("Reordered. New sequence: ${currentSequence.map((e) => e["step"]).toList()}");
  }

  void manualCheckSequence() {
    checkallanswerandnavigate();
  }

  void retrySequence() {
    retries.value++;
    hasSubmitted.value = false;
    showCompletion.value = false;
    isSequenceCorrect.value = false;
    shuffleSequence();

    audioService.setInstructionAndSpeak(
      "Let's try the bathing sequence again!"
    );
  }

  void speakStepDescription(int index) {
    if (index < currentSequence.length) {
      final step = currentSequence[index];
      final description = step["description"] ?? "";
      audioService.speakText(description);
    }
  }

  double getCompletionProgress() {
    if (!hasSubmitted.value) return 0.0;
    return isSequenceCorrect.value ? 1.0 : 0.5;
  }

  bool get allStepsCorrect => isSequenceCorrect.value;

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
