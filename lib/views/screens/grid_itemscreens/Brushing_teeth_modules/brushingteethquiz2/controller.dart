import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BrushingTeethQuiz2Controller extends GetxController {
  final audioService = AudioInstructionService.to;
  final brushingTeethController = Get.find<BrushingTeethModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var hasAnswered = false.obs;
  var selectedIndex = (-1).obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var retries = 0.obs;

  final List<String> options = [
    'Eating Breakfast',
    'Brushing his teeth',
    'Playing with toys',
    'Sleeping',
  ];
  final String correctAnswer = 'Brushing his teeth';
  int correctIndex = 0;

  @override
  void onInit() {
    super.onInit();
    correctIndex = options.indexOf(correctAnswer);

    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Great! Now look at this picture. What is the boy doing?",
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
        "Yes! He is brushing his teeth!",
      );

      brushingTeethController.recordQuizResult(
        quizId: "quiz2",
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
        quizId: "quiz2",
        wrongAnswer: options[index],
        correctAnswer: correctAnswer,
      );

      audioService.setInstructionAndSpeak(
        "Oops! He is actually brushing his teeth. Try again!",
      );

      Future.delayed(const Duration(seconds: 3), () {
        resetAnswer();
      });
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

  bool isButtonDisabled(int index) {
    return hasAnswered.value;
  }

  void retryQuiz() {
    retries.value++;
    initializeQuiz();

    audioService.setInstructionAndSpeak(
      "Let's try again! What is the boy doing?",

    );
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
