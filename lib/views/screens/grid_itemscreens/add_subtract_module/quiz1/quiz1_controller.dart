import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/add_subtract_module_controller.dart';

class FruitMathController extends GetxController {
  final audioService = AudioInstructionService.to;
  final addSubtractModuleController = Get.find<AddSubtractModuleController>();
  
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var basketItems = <Map<String, dynamic>>[].obs;
  var availableFruits = <Map<String, dynamic>>[].obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "type": "addition",
      "instruction": "Collect the required fruits for your fruit salad!",
      "audio": "fruitmath_question1",
      "target": [
        {"type": "apple", "count": 2},
        {"type": "banana", "count": 1},
        {"type": "strawberry", "count": 1},
      ],
      "availableFruits": [
        {"type": "apple", "icon": "lib/assets/add_sub_quiz/apple.png", "name": "Apple"},
        {"type": "banana", "icon": "lib/assets/add_sub_quiz/banana.png", "name": "Banana"},
        {"type": "strawberry", "icon": "lib/assets/add_sub_quiz/stawbery.png", "name": "Strawberry"},
        {"type": "orange", "icon": "lib/assets/add_sub_quiz/orange.png", "name": "Orange"},
        {"type": "grape", "icon": "lib/assets/add_sub_quiz/grapes.png", "name": "Grape"},
        {"type": "watermelon", "icon": "lib/assets/add_sub_quiz/watermelon.png", "name": "Watermelon"},
      ]
    },
    {
      "type": "subtraction", 
      "instruction": "Remove these fruits from the basket!",
      "audio": "fruitmath_question2",
      "initialBasket": [
        {"type": "apple", "count": 4},
        {"type": "banana", "count": 2},
        {"type": "orange", "count": 2},
        {"type": "grape", "count": 1},
      ],
      "target": [
        {"type": "apple", "count": 2},
        {"type": "banana", "count": 1},
      ],
      "availableFruits": [
        {"type": "apple", "icon": "lib/assets/add_sub_quiz/apple.png", "name": "Apple"},
        {"type": "banana", "icon": "lib/assets/add_sub_quiz/banana.png", "name": "Banana"},
        {"type": "orange", "icon": "lib/assets/add_sub_quiz/orange.png", "name": "Orange"},
        {"type": "grape", "icon": "lib/assets/add_sub_quiz/grapes.png", "name": "Grape"},
      ]
    }
  ];

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "Hey kiddo welcome to this quiz. In this quiz we will learn to make salad by adding and subtracting fruits.",
      "goingbed_audios/fruitmath_intro.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void loadCurrentQuestion() {
    basketItems.clear();
    showFeedback.value = false;
    isCorrect.value = false;
    final currentQuestion = questions[currentQuestionIndex.value];
    
    availableFruits.assignAll(List.from(currentQuestion["availableFruits"]));
    
    if (currentQuestion["type"] == "subtraction") {
      final initialBasket = List<Map<String, dynamic>>.from(currentQuestion["initialBasket"]);
      for (var fruit in initialBasket) {
        for (int i = 0; i < fruit["count"]; i++) {
          basketItems.add({
            "type": fruit["type"],
            "icon": availableFruits.firstWhere((f) => f["type"] == fruit["type"])["icon"],
            "name": availableFruits.firstWhere((f) => f["type"] == fruit["type"])["name"],
          });
        }
      }
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      playQuestionAudio();
    });
  }

  void playQuestionAudio() {
    final currentAudio = questions[currentQuestionIndex.value]["audio"];
    audioService.playAudioFromPath(currentAudio);
  }

  void addToBasket(Map<String, dynamic> fruit) {
    if (hasSubmitted.value) return;
    basketItems.add(fruit);
  }

  void removeFromBasket(Map<String, dynamic> fruit) {
    if (hasSubmitted.value) return;
    basketItems.remove(fruit);
  }

  void checkAnswer() {
    if (hasSubmitted.value) return;
    
    final currentQuestion = questions[currentQuestionIndex.value];
    final target = List<Map<String, dynamic>>.from(currentQuestion["target"]);
    
    bool correct = true;
    
    for (var targetFruit in target) {
      final countInBasket = basketItems.where((item) => item["type"] == targetFruit["type"]).length;
      if (countInBasket != targetFruit["count"]) {
        correct = false;
        break;
      }
    }
    
    if (currentQuestion["type"] == "addition") {
      final allTypes = target.map((t) => t["type"]).toList();
      final hasExtraFruits = basketItems.any((item) => !allTypes.contains(item["type"]));
      if (hasExtraFruits) correct = false;
    }
    
    isCorrect.value = correct;
    showFeedback.value = true;

    if (correct) {
      score.value++;
      audioService.playCorrectFeedback();
      
      // Record successful question completion
      if (isLastQuestion) {
        completeQuiz();
      }
    } else {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      
      // Record wrong attempt
      addSubtractModuleController.recordWrongAnswer(
        quizId: "quiz1",
        questionId: "Question ${currentQuestionIndex.value + 1}",
        wrongAnswer: "Incorrect fruit selection",
        correctAnswer: "Target: ${target.map((t) => "${t['count']} ${t['type']}").join(', ')}",
      );
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      loadCurrentQuestion();
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Amazing! You completed the Fruit Math challenge!",
      "goingbed_audios/fruitmath_complete.mp3",
    );
    
    // Record quiz result
    addSubtractModuleController.recordQuizResult(
      quizId: "quiz1",
      score: score.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    addSubtractModuleController.syncModuleProgress();
  }

  void resetQuiz() {
    currentQuestionIndex.value = 0;
    basketItems.clear();
    showFeedback.value = false;
    isCorrect.value = false;
    score.value = 0;
    retries.value++;
    wrongAttempts.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try the fruit math again!",
      "goingbed_audios/fruitmath_reset.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void checkAnswerAndNavigate() {
    if (hasSubmitted.value && showCompletion.value) {
      // Navigate to the next screen
      Get.to(() => const NumberLinescreen());
    } else {
      checkAnswer();
    }
  }

  // Progress tracking methods
  double getProgressPercentage() {
    return (currentQuestionIndex.value + (showFeedback.value ? 1 : 0)) / questions.length;
  }

  int getRemainingQuestions() {
    return questions.length - (currentQuestionIndex.value + (showFeedback.value ? 1 : 0));
  }

  String getCurrentQuestionProgress() {
    return "Question ${currentQuestionIndex.value + 1}/${questions.length}";
  }

  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex.value];
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}