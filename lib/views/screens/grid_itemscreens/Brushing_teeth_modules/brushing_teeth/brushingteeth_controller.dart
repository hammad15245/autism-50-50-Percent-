import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BrushingTeethQuiz1Controller extends GetxController {
  final audioService = AudioInstructionService.to;
  final brushingTeethController = Get.find<BrushingTeethModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var hasAnswered = false.obs;
  var selectedIndex = (-1).obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var retries = 0.obs;

  final List<String> options = ['Toothbrush', 'Spoon', 'Comb', 'Towel'];
  final String correctAnswer = 'Toothbrush';
  int correctIndex = 0;

  @override
  void onInit() {
    super.onInit();
    correctIndex = options.indexOf(correctAnswer);
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddos! Welcome to this module. Let's learn about brushing teeth! What do we use for brushing our teeth?"
      );
    });
  }

  void initializeQuiz() {
    hasAnswered.value = false;
    selectedIndex.value = -1;
    showFeedback.value = false;
    isCorrect.value = false;
  }

  void selectAnswer(int index) {
    if (hasAnswered.value) return;

    selectedIndex.value = index;
    hasAnswered.value = true;
    showFeedback.value = true;

    final isAnswerCorrect = index == correctIndex;
    isCorrect.value = isAnswerCorrect;

    if (isAnswerCorrect) {
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Correct! We use a toothbrush for brushing teeth!"
      );

      brushingTeethController.recordQuizResult(
        quizId: "quiz1",
        score: 1,
        retries: retries.value,
        isCompleted: true,
        wrongAnswersCount: 0,
      );

      brushingTeethController.syncModuleProgress();
    } else {
      retries.value++;
      audioService.playIncorrectFeedback();

      brushingTeethController.recordWrongAnswer(
        quizId: "quiz1",
        wrongAnswer: options[index],
        correctAnswer: correctAnswer,
      );

      audioService.setInstructionAndSpeak(
        "That's not quite right. We use a toothbrush for brushing teeth."
      );

      Future.delayed(const Duration(seconds: 3), resetAnswer);
    }
  }

  void resetAnswer() {
    hasAnswered.value = false;
    selectedIndex.value = -1;
    showFeedback.value = false;
    isCorrect.value = false;
  }

  Color getButtonColor(int index) {
    if (!hasAnswered.value) return const Color(0xFF0E83AD);

    if (index == selectedIndex.value) {
      return index == correctIndex ? Colors.green : Colors.red;
    }

    if (hasAnswered.value && index == correctIndex) {
      return Colors.green;
    }

    return const Color(0xFF0E83AD);
  }

  bool isButtonDisabled(int index) => hasAnswered.value;

  void retryQuiz() {
    retries.value++;
    initializeQuiz();
    audioService.setInstructionAndSpeak(
      "Let's try again! What do we use for brushing teeth?"
    );
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
