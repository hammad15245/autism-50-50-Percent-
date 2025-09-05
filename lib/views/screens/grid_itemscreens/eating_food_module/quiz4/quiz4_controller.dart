import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HealthyTreatController extends GetxController {
  var currentQuestionIndex = 0.obs;
  var userAnswer = "".obs;
  var feedbackMessage = "".obs;
  var showCompletion = false.obs;

  final FlutterTts tts = FlutterTts();

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Which one is more healthier?",
      "healthy": {"name": "apple", "icon": "lib/assets/quiz3_cleansorting/apple.png"},
      "treat": {"name": "candies", "icon": "lib/assets/quiz3_cleansorting/candy.png"}
    },
    {
      "question": "Which one helps you grow?",
      "healthy": {"name": "carrot", "icon": "lib/assets/quiz3_cleansorting/carrot.png"},
      "treat": {"name": "cookie", "icon": "lib/assets/quiz3_cleansorting/cookie.png"}
    },
    {
      "question": "Which food gives you energy?",
      "healthy": {"name": "chicken", "icon": "lib/assets/quiz3_cleansorting/chicken.png"},
      "treat": {"name": "chips", "icon": "lib/assets/quiz3_cleansorting/chips.png"}
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _speakQuestion(); // Speak first question on start
  }

  void _speakQuestion() async {
    var current = questions[currentQuestionIndex.value];
    String questionText = current["question"].toString();
    await tts.setLanguage("en-US");
     await tts.setPitch(1.0);
      await tts.setSpeechRate(0.5);
      await tts.setVolume(1.0);
    await tts.speak(questionText);
  }

  void checkAnswer() async {
    var current = questions[currentQuestionIndex.value];
    Map<String, dynamic> healthy = current["healthy"] as Map<String, dynamic>;
    String correctAnswer = healthy["name"].toString().toLowerCase();
    String input = userAnswer.value.trim().toLowerCase();

    if (input == correctAnswer) {
      feedbackMessage.value = "Correct! ✅";
      await tts.speak("Correct!");
      Future.delayed(const Duration(seconds: 4), () {
        nextQuestion();
      });
    } else {
      feedbackMessage.value = "Oops! Try again ❌";
      await tts.speak("Oops! Try again!");
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      userAnswer.value = "";
      feedbackMessage.value = "";
      _speakQuestion(); // Speak new question
    } else {
      showCompletion.value = true;
    }
  }

  void resetQuiz() {
    currentQuestionIndex.value = 0;
    userAnswer.value = "";
    feedbackMessage.value = "";
    showCompletion.value = false;
    _speakQuestion(); // Speak first question again
  }
}
