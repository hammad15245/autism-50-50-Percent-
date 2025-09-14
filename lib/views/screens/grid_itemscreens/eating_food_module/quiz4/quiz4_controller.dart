import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/eating_food_controller.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class HealthyTreatController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var userAnswer = "".obs;
  var feedbackMessage = "".obs;
  var showCompletion = false.obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var totalQuestions = 0.obs;

  final audioService = AudioInstructionService.to;
  final eatingFoodController = Get.find<EatingFoodController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Which one is more healthier?",
      "healthy": {"name": "apple", "icon": "lib/assets/quiz3_cleansorting/apple.png"},
      "treat": {"name": "candies", "icon": "lib/assets/quiz3_cleansorting/candy.png"},
      "audio": "eating_food_audios/healthier_question.mp3"
    },
    {
      "question": "Which one helps you grow?",
      "healthy": {"name": "carrot", "icon": "lib/assets/quiz3_cleansorting/carrot.png"},
      "treat": {"name": "cookie", "icon": "lib/assets/quiz3_cleansorting/cookie.png"},
      "audio": "eating_food_audios/grow_question.mp3"
    },
    {
      "question": "Which food gives you energy?",
      "healthy": {"name": "chicken", "icon": "lib/assets/quiz3_cleansorting/chicken.png"},
      "treat": {"name": "chips", "icon": "lib/assets/quiz3_cleansorting/chips.png"},
      "audio": "eating_food_audios/energy_question.mp3"
    },
  ];

  @override
  void onInit() {
    super.onInit();
    totalQuestions.value = questions.length;
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Kiddos Lets learn about healthy foods! Choose the healthier option and type them for each question.",
      );
      _speakQuestion(); // Speak first question after intro
    });
  }

  void _speakQuestion() async {
    var current = questions[currentQuestionIndex.value];
    String questionText = current["question"].toString();
    
    // Speak the question using audio file if available, otherwise use TTS
    if (current.containsKey("audio") && current["audio"] != null) {
      audioService.setInstructionAndSpeak(
        questionText,
      );
    } else {
        // audioService.speak(questionText);
    }
  }

  void checkAnswer() async {
    var current = questions[currentQuestionIndex.value];
    Map<String, dynamic> healthy = current["healthy"] as Map<String, dynamic>;
    String correctAnswer = healthy["name"].toString().toLowerCase();
    String input = userAnswer.value.trim().toLowerCase();

    if (input == correctAnswer) {
      score.value++;
      feedbackMessage.value = "Correct! ✅";
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Great choice! ${healthy["name"]} is the healthier option.",
      );
      
      Future.delayed(const Duration(seconds: 3), () {
        nextQuestion();
      });
    } else {
      wrongAnswersCount.value++;
      feedbackMessage.value = "Oops! Try again ❌";
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      eatingFoodController.recordWrongAnswer(
        quizId: "quiz4",
        questionId: current["question"],
        wrongAnswer: userAnswer.value,
        correctAnswer: healthy["name"],
      );
      
      audioService.setInstructionAndSpeak(
        "${healthy["name"]} is the healthier choice. Let's try the next one!",
      );
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      userAnswer.value = "";
      feedbackMessage.value = "";
      _speakQuestion(); // Speak new question
    } else {
      completeQuiz();
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    
    final earnedScore = score.value;
    final total = totalQuestions.value;
    final isPassed = earnedScore >= (total * 0.7); // 70% to pass

    // Record quiz result
    eatingFoodController.recordQuizResult(
      quizId: "quiz4",
      score: earnedScore,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    eatingFoodController.syncModuleProgress();

    if (earnedScore == total) {
      audioService.setInstructionAndSpeak(
        "Perfect! You got all $total questions correct! You're a healthy eating expert!",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $earnedScore out of $total correct. You know your healthy foods!",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "Good try! You got $earnedScore out of $total correct. Let's learn more about healthy foods together.",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    currentQuestionIndex.value = 0;
    userAnswer.value = "";
    feedbackMessage.value = "";
    score.value = 0;
    wrongAnswersCount.value = 0;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try again! Remember to choose the healthier option.",
    );
    _speakQuestion();
  }

  void setUserAnswer(String answer) {
    userAnswer.value = answer;
    checkAnswer();
  }

  // Get current question data
  Map<String, dynamic> get currentQuestion {
    return questions[currentQuestionIndex.value];
  }

  // Get progress percentage
  double get progressPercentage {
    return (currentQuestionIndex.value + 1) / questions.length;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}