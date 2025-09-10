import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BathingItemsController extends GetxController {
  // Current question index
  var currentIndex = 0.obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var hasSubmitted = false.obs;
  
  final audioService = AudioInstructionService.to;
  final bathingModuleController = Get.find<BathingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // List of bathing items with questions
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

  // Selected answer
  var selectedAnswer = RxString("");
  
  // Is answered correctly
  var isCorrect = false.obs;
  
  // Show feedback
  var showFeedback = false.obs;

  // Track completed questions
  var completedQuestions = 0.obs;
  var totalQuestions = 5;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey Kiddos! Let's learn about bathing items! Choose the correct answer for each question.",
        "goingbed_audios/bathing_intro.mp3",
      );
      _speakCurrentQuestion();
    });
  }

  void _speakCurrentQuestion() {
    if (currentIndex.value < bathingItems.length) {
      final currentItem = bathingItems[currentIndex.value];
      final question = currentItem["question"] as String;
      
      if (currentItem.containsKey("audio")) {
        audioService.setInstructionAndSpeak(
          question,
          currentItem["audio"] as String,
        );
      } else {
        // audioService.speak(question);
      }
    }
  }

  void checkAnswer(String selectedOption) {
    if (hasSubmitted.value) return;
    
    selectedAnswer.value = selectedOption;
    showFeedback.value = true;
    hasSubmitted.value = true;
    
    // Safer access with null checking
    var currentItem = bathingItems[currentIndex.value];
    String? correctAnswer = currentItem["correctAnswer"] as String?;
    
    if (correctAnswer != null) {
      isCorrect.value = (selectedOption == correctAnswer);
      
      if (isCorrect.value) {
        score.value++;
        completedQuestions.value++;
        audioService.playCorrectFeedback();
        audioService.setInstructionAndSpeak(
          "Great job! That's the right answer!",
          "bathing_audios/correct_answer.mp3",
        );
      } else {
        wrongAnswersCount.value++;
        audioService.playIncorrectFeedback();
        
        // Record wrong answer
        bathingModuleController.recordWrongAnswer(
          quizId: "quiz1",
          questionId: currentItem["question"] as String,
          wrongAnswer: selectedOption,
          correctAnswer: correctAnswer,
        );
        
        audioService.setInstructionAndSpeak(
          "That's not quite right. The correct answer is: $correctAnswer",
          "bathing_audios/incorrect_answer.mp3",
        );
      }
      
      // Auto-advance after a short delay, regardless of correct/incorrect
      Future.delayed(const Duration(seconds: 3), () {
        nextQuestion();
      });
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
      // Quiz completed
      completeQuiz();
    }
  }

  void completeQuiz() {
    final isPassed = score.value >= bathingItems.length * 0.7;
    
    // Record quiz result
    bathingModuleController.recordQuizResult(
      quizId: "quiz1",
      score: score.value,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    bathingModuleController.syncModuleProgress();

    if (score.value == bathingItems.length) {
      audioService.setInstructionAndSpeak(
        "Perfect! You got all ${bathingItems.length} questions correct!",
        "bathing_audios/quiz_perfect.mp3",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $score out of ${bathingItems.length} correct.",
        "bathing_audios/quiz_good.mp3",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "You got $score out of ${bathingItems.length}. Let's practice more!",
        "bathing_audios/quiz_practice.mp3",
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
      "bathing_audios/quiz_retry.mp3",
    );
    _speakCurrentQuestion();
  }

  void checkAnswerAndNavigate() {
    if (selectedAnswer.value.isNotEmpty) {
      // If answered, move to next quiz
      Get.to(() => const BathingSequenceScreen());
    } else {
      // Current question not answered
      audioService.playIncorrectFeedback();
      // audioService.speak("Please answer this question first");
      
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

  // Replay current question audio
  void replayQuestion() {
    _speakCurrentQuestion();
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}