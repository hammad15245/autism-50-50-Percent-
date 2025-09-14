import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/counting_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
class CountingController extends GetxController {
  // Current state variables
  var currentCount = 0.obs;
  var targetNumber = 0.obs;
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

  // Bath items with their assets - updated path to quiz1_counting
  final List<Map<String, dynamic>> bathItems = [
    {
      "name": "Soap",
      "icon": "lib/assets/quiz1_counting/soap.png",
      "audio": "counting_audios/soap.mp3"
    },
    {
      "name": "Towel",
      "icon": "lib/assets/quiz1_counting/towel.png",
      "audio": "counting_audios/towel.mp3"
    },
    {
      "name": "Rubber Duck",
      "icon": "lib/assets/quiz1_counting/duck.png",
      "audio": "counting_audios/duck.mp3"
    },
    {
      "name": "Shampoo",
      "icon": "lib/assets/quiz1_counting/shampoo.png",
      "audio": "counting_audios/shampoo.mp3"
    },
    {
      "name": "Bubble Bath",
      "icon": "lib/assets/quiz1_counting/bubble_bath.png",
      "audio": "counting_audios/bubble_bath.mp3"
    },
    {
      "name": "Sponge",
      "icon": "lib/assets/quiz1_counting/sponge.png",
      "audio": "counting_audios/sponge.mp3"
    },
  ];

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Count the soaps",
      "targetItem": "Soap",
      "targetCount": 3,
      "items": ["Soap", "Towel", "Shampoo", "Soap", "Rubber Duck", "Soap"],
      "audio": "counting_audios/count_soaps.mp3"
    },
    {
      "question": "Count the towels",
      "targetItem": "Towel",
      "targetCount": 2,
      "items": ["Towel", "Towel", "Soap", "Shampoo", "Bubble Bath", "Sponge"],
      "audio": "counting_audios/count_towels.mp3"
    },
    {
      "question": "Count the rubber ducks",
      "targetItem": "Rubber Duck",
      "targetCount": 3,
      "items": ["Rubber Duck", "Soap", "Rubber Duck", "Sponge", "Soap", "Rubber Duck"],
      "audio": "counting_audios/count_ducks.mp3"
    },
    {
      "question": "Count the shampoo bottles",
      "targetItem": "Shampoo",
      "targetCount": 3,
      "items": ["Shampoo", "Sponge", "Shampoo", "Towel", "Shampoo", "Rubber Duck"],
      "audio": "counting_audios/count_shampoo.mp3"
    },
    {
      "question": "Count the sponges",
      "targetItem": "Sponge",
      "targetCount": 5,
      "items": ["Sponge", "Sponge", "Sponge", "Sponge", "Sponge", "Towel"],
      "audio": "counting_audios/count_sponges.mp3"
    },
  ];

  var currentQuestionData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddos! Let's practice counting! Look at the items and count how many of each type you see.",
      );
    });
    
    resetQuiz();
  }

  void resetQuiz() {
    currentCount.value = 0;
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
      targetNumber.value = questions[index]["targetCount"];
      currentCount.value = 0;
      
      // Speak the question
      if (currentQuestionData.containsKey("audio")) {
        audioService.setInstructionAndSpeak(
          currentQuestionData["question"],
        );
      } else {
        // audioService.speak(currentQuestionData["question"]);
      }
    } else {
      showCompletion.value = true;
    }
  }

  void incrementCount() {
      currentCount.value++;
      // audioService.playSoundEffect("counting_audios/count_up.mp3");
  
  }

  void decrementCount() {
    if (currentCount > 0) {
      currentCount.value--;
      // audioService.playSoundEffect("counting_audios/count_down.mp3");
    }
  }

  void checkAnswer() {
    final isCorrect = currentCount.value == targetNumber.value;
    
    if (isCorrect) {
      score.value++;
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Correct! You counted ${currentCount.value} ${currentQuestionData["targetItem"]}s correctly!",
      );
    } else {
      wrongAnswersCount.value++;
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      countingModuleController.recordWrongAnswer(
        quizId: "quiz1",
        questionId: currentQuestionData["question"],
        wrongAnswer: currentCount.value.toString(),
        correctAnswer: targetNumber.value.toString(),
      );
      
      audioService.setInstructionAndSpeak(
        "You counted ${currentCount.value}, but there are ${targetNumber.value} ${currentQuestionData["targetItem"]}s. Let's try again!",
      );
    }

    // Move to next question after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (currentQuestion.value < totalQuestions.value) {
        currentQuestion.value++;
        loadQuestion(currentQuestion.value - 1);
      } else {
        completeQuiz();
      }
    });
  }

  void completeQuiz() {
    showCompletion.value = true;
    
    final earnedScore = score.value;
    final total = totalQuestions.value;
    final isPassed = earnedScore >= (total * 0.7); // 70% to pass

    // Record quiz result
    countingModuleController.recordQuizResult(
      quizId: "quiz1",
      score: earnedScore,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    countingModuleController.syncModuleProgress();

    if (earnedScore == total) {
      audioService.setInstructionAndSpeak(
        "Perfect! You got all $total questions correct! You're a counting expert!",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $earnedScore out of $total correct. Great counting!",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "Good try! You got $earnedScore out of $total correct. Let's practice more counting together.",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    resetQuiz();
    
    audioService.setInstructionAndSpeak(
      "Let's try counting again! Remember to look carefully at each item.",
    );
  }

  void checkAnswerAndNavigate() {
    if (showCompletion.value) {
      Future.delayed(const Duration(seconds: 3), () {
        Get.to(() => const DuckCollectionscreen());
      });
    }
  }

  // Get exactly 6 items for the grid (with repetitions as needed)
  List<Map<String, dynamic>> getCurrentItems() {
    final dynamic items = currentQuestionData["items"];
    
    if (items is List<String> && items.length >= 6) {
      return items.take(6).map((itemName) => getItemByName(itemName)).toList();
    } else if (items is List<dynamic> && items.length >= 6) {
      return items.take(6).map((item) {
        final itemName = item.toString();
        return getItemByName(itemName);
      }).toList();
    }
    
    return List.generate(6, (index) => getItemByName("Soap"));
  }

  // Get item by name with proper error handling
  Map<String, dynamic> getItemByName(String name) {
    try {
      return bathItems.firstWhere((item) => item["name"] == name);
    } catch (e) {
      return bathItems[0];
    }
  }

  // Play sound for item when tapped
  void playItemSound(String itemName) {
    try {
      final item = bathItems.firstWhere((item) => item["name"] == itemName);
      if (item.containsKey("audio")) {
        // audioService.playSoundEffect(item["audio"]);
      }
    } catch (e) {
      // Ignore if audio not found
    }
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}