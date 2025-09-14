import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BathingItemsController extends GetxController {
  var currentIndex = 0.obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var hasSubmitted = false.obs;

  final audioService = AudioInstructionService.to;
  final bathingModuleController = Get.find<BathingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var bathingItems = [
    {
      "question": "What do we use to wash our body?",
      "options": ["Soap", "Toothbrush", "Comb", "Towel"],
      "correctAnswer": "Soap",
      "image": "lib/assets/quiz1_bathing/soap.png",
      "audio": "bathing_audios/wash_body.mp3"
    },
    {
      "question": "What do we use to dry ourselves?",
      "options": ["Soap", "Shampoo", "Towel", "Toothpaste"],
      "correctAnswer": "Towel",
      "image": "lib/assets/quiz1_bathing/towel.png",
      "audio": "bathing_audios/dry_ourselves.mp3"
    },
    {
      "question": "What do we use to wash our hair?",
      "options": ["Comb", "Shampoo", "Soap", "Towel"],
      "correctAnswer": "Shampoo",
      "image": "lib/assets/quiz1_bathing/shampoo.png",
      "audio": "bathing_audios/wash_hair.mp3"
    },
    {
      "question": "What do we use to comb our hair?",
      "options": ["Brush", "Comb", "Towel", "Soap"],
      "correctAnswer": "Comb",
      "image": "lib/assets/quiz1_bathing/comb.png",
      "audio": "bathing_audios/comb_hair.mp3"
    },
    {
      "question": "Where do we take a bath?",
      "options": ["Bathtub", "Bed", "Table", "Chair"],
      "correctAnswer": "Bathtub",
      "image": "lib/assets/quiz1_bathing/bathtub.png",
      "audio": "bathing_audios/where_bath.mp3"
    }
  ].obs;

  var selectedAnswer = RxString("");
  var isCorrect = false.obs;
  var showFeedback = false.obs;
  var completedQuestions = 0.obs;
  var totalQuestions = 5;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey Kiddos! Let's learn about bathing items! Choose the correct answer for each question.",
      ).then((_) => _speakCurrentQuestion());
    });
  }

  void _speakCurrentQuestion() {
    if (currentIndex.value < bathingItems.length) {
      final currentItem = bathingItems[currentIndex.value];
      final question = currentItem["question"] as String;
      final audioPath = currentItem["audio"] as String?;

      audioService.setInstructionAndSpeak(
        question,

      );
    }
  }

  void checkAnswer(String selectedOption) {
    if (hasSubmitted.value) return;

    selectedAnswer.value = selectedOption;
    showFeedback.value = true;
    hasSubmitted.value = true;

    final currentItem = bathingItems[currentIndex.value];
    final correctAnswer = currentItem["correctAnswer"] as String?;

    if (correctAnswer != null) {
      isCorrect.value = selectedOption == correctAnswer;

      if (isCorrect.value) {
        score.value++;
        completedQuestions.value++;
        audioService.playCorrectFeedback();
        audioService.setInstructionAndSpeak(
          "Great job! That's the right answer!",
        );
      } else {
        wrongAnswersCount.value++;
        audioService.playIncorrectFeedback();

        bathingModuleController.recordWrongAnswer(
          quizId: "quiz1",
          questionId: currentItem["question"] as String,
          wrongAnswer: selectedOption,
          correctAnswer: correctAnswer,
        );

        audioService.setInstructionAndSpeak(
          "That's not quite right. The correct answer is: $correctAnswer",
        );
      }

      Future.delayed(const Duration(seconds: 3), nextQuestion);
    }
  }

  void nextQuestion() {
    if (currentIndex.value < bathingItems.length - 1) {
      currentIndex.value++;
      selectedAnswer.value = "";
      isCorrect.value = false;
      showFeedback.value = false;
      hasSubmitted.value = false;
      _speakCurrentQuestion();
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    final isPassed = score.value >= bathingItems.length * 0.7;

    bathingModuleController.recordQuizResult(
      quizId: "quiz1",
      score: score.value,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );

    bathingModuleController.syncModuleProgress();

    if (score.value == bathingItems.length) {
      audioService.setInstructionAndSpeak(
        "Perfect! You got all ${bathingItems.length} questions correct!",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $score out of ${bathingItems.length} correct.",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "You got $score out of ${bathingItems.length}. Let's practice more!",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    currentIndex.value = 0;
    score.value = 0;
    wrongAnswersCount.value = 0;
    completedQuestions.value = 0;
    selectedAnswer.value = "";
    isCorrect.value = false;
    showFeedback.value = false;
    hasSubmitted.value = false;

    audioService.setInstructionAndSpeak(
      "Let's try the bathing quiz again!",
    ).then((_) => _speakCurrentQuestion());
  }

  void checkAnswerAndNavigate() {
    if (selectedAnswer.value.isNotEmpty) {
      Get.to(() => const BathingSequenceScreen());
    } else {
      audioService.setInstructionAndSpeak(
        "Please answer this question first",
      );
      audioService.playIncorrectFeedback();

      Get.snackbar(
        "Answer required",
        "Please answer this question first",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
    }
  }

  void manualNextQuestion() {
    Get.to(() => const BathingSequenceScreen());
  }

  void replayQuestion() => _speakCurrentQuestion();

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
