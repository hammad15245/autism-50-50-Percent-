import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/counting_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/quiz3_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class NumberMatchController extends GetxController {
  // Game state
  var currentNumber = 0.obs;
  var score = 0.obs;
  var totalQuestions = 0.obs;
  var currentQuestion = 1.obs;
  var showCompletion = false.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  
  final audioService = AudioInstructionService.to;
  final countingModuleController = Get.find<CountingModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;
  
  // Questions pool
  final List<Map<String, dynamic>> questions = [
    {
      "number": 3,
      "options": [
        {"count": 2, "image": "lib/assets/RiverGame/star_2.png", "correct": false},
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": true},
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": false},
      ],
      "audio": "counting_audios/number_3.mp3"
    },
    {
      "number": 5,
      "options": [
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": false},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": true},
        {"count": 6, "image": "lib/assets/RiverGame/star_6.png", "correct": false},
      ],
      "audio": "counting_audios/number_5.mp3"
    },
    {
      "number": 2,
      "options": [
        {"count": 2, "image": "lib/assets/RiverGame/star_2.png", "correct": true},
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": false},
        {"count": 1, "image": "lib/assets/RiverGame/star_1.png", "correct": false},
      ],
      "audio": "counting_audios/number_2.mp3"
    },
    {
      "number": 4,
      "options": [
        {"count": 3, "image": "lib/assets/RiverGame/star_3.png", "correct": false},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": false},
        {"count": 4, "image": "lib/assets/RiverGame/star_4.png", "correct": true},
      ],
      "audio": "counting_audios/number_4.mp3"
    },
    {
      "number": 6,
      "options": [
        {"count": 6, "image": "lib/assets/RiverGame/star_6.png", "correct": true},
        {"count": 5, "image": "lib/assets/RiverGame/star_5.png", "correct": false},
        {"count": 7, "image": "lib/assets/RiverGame/star_7.png", "correct": false},
      ],
      "audio": "counting_audios/number_6.mp3"
    },
  ];

  var currentQuestionData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Ok Kiddos lets Match the number with the correct group of items! Listen to the number and find the matching group.",
      );
    });
    
    resetQuiz();
  }

  void resetQuiz() {
    score.value = 0;
    totalQuestions.value = questions.length;
    currentQuestion.value = 1;
    showCompletion.value = false;
    wrongAnswersCount.value = 0;
    loadQuestion(0);
  }

  void loadQuestion(int index) {
    if (index < questions.length) {
      currentQuestionData.value = questions[index];
      currentNumber.value = questions[index]["number"];
      
      // Speak the number using audio service
      if (currentQuestionData.containsKey("audio")) {
        audioService.setInstructionAndSpeak(
          "Find $currentNumber",
        );
      } else {
        // audioService.speak("Find $currentNumber");
      }
    } else {
      showCompletion.value = true;
    }
  }

  void checkAnswer(int optionIndex) {
    final options = List<Map<String, dynamic>>.from(currentQuestionData["options"]);
    
    if (optionIndex < options.length && options[optionIndex]["correct"] == true) {
      score.value++;
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Correct! You matched number $currentNumber!",
      );

      // Move to next question after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (currentQuestion.value < totalQuestions.value) {
          currentQuestion.value++;
          loadQuestion(currentQuestion.value - 1);
        } else {
          completeQuiz();
        }
      });
    } else {
      wrongAnswersCount.value++;
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      final selectedCount = options[optionIndex]["count"];
      countingModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Match number $currentNumber",
        wrongAnswer: selectedCount.toString(),
        correctAnswer: currentNumber.value.toString(),
      );
      
      audioService.setInstructionAndSpeak(
        "That group has $selectedCount items. Find the group with $currentNumber items.",
      );
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    
    final earnedScore = score.value;
    final total = totalQuestions.value;
    final isPassed = earnedScore >= (total * 0.7); // 70% to pass

    // Record quiz result
    countingModuleController.recordQuizResult(
      quizId: "quiz2",
      score: earnedScore,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    countingModuleController.syncModuleProgress();

    if (earnedScore == total) {
      audioService.setInstructionAndSpeak(
        "Perfect! You matched all $total numbers correctly! You're a number matching expert!",

      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $earnedScore out of $total correct. Great number matching!",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "Good try! You got $earnedScore out of $total correct. Let's practice more number matching together.",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    resetQuiz();
    
    audioService.setInstructionAndSpeak(
      "Let's try matching numbers again! Listen carefully to the number.",
    );
  }

  void checkAnswerAndNavigate() {
    if (showCompletion.value) {
      Future.delayed(const Duration(seconds: 3), () {
        Get.to(() => const countingsequence());
      });
    }
  }

  void nextQuestion() {
    if (currentQuestion.value < totalQuestions.value) {
      currentQuestion.value++;
      loadQuestion(currentQuestion.value - 1);
    } else {
      completeQuiz();
    }
  }

  // // Replay the current number
  // void replayNumber() {
  //   if (currentQuestionData.containsKey("audio")) {
  //     audioService.playSoundEffect(currentQuestionData["audio"]);
  //   } else {
  //     audioService.speak("$currentNumber");
  //   }
  // }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}