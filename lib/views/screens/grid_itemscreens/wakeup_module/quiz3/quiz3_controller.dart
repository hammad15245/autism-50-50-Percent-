import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BreakfastSortingController extends GetxController {
  final audioService = AudioInstructionService.to;
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var selectedItems = <Map<String, dynamic>>[].obs;
  var currentFoodItems = <Map<String, dynamic>>[].obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var score = 0.obs;
  var totalQuestions = 3.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Select the healthy breakfast foods for a strong start!",
      "audio": "breakfast_questionaudio1", 
      "options": [
        {"id": "milk", "name": "Milk", "icon": "lib/assets/quiz_wakeup/milk.png", "isHealthy": true},
        {"id": "cereal", "name": "Cereal", "icon": "lib/assets/quiz_wakeup/cereal.png", "isHealthy": true},
        {"id": "donut", "name": "Donut", "icon": "lib/assets/quiz_wakeup/donut.png", "isHealthy": false},
        {"id": "chips", "name": "Chips", "icon": "lib/assets/quiz_wakeup/chips.png", "isHealthy": false},
      ]
    },
    {
      "question": "Pick the right foods to stay active in school!",
      "audio": "breakfast_questionaudio2",
      "options": [
        {"id": "eggs", "name": "Eggs", "icon": "lib/assets/quiz_wakeup/egg.png", "isHealthy": true},
        {"id": "fruit", "name": "Fruit", "icon": "lib/assets/quiz_wakeup/fruits.png", "isHealthy": true},
        {"id": "cookie", "name": "Cookie", "icon": "lib/assets/quiz_wakeup/cookie.png", "isHealthy": false},
        {"id": "soda", "name": "Soda", "icon": "lib/assets/quiz_wakeup/soda.png", "isHealthy": false},
      ]
    },
    {
      "question": "Choose breakfast foods that help you grow healthy and strong!",
      "audio": "breakfast_questionaudio3", 
      "options": [
        {"id": "oatmeal", "name": "Oatmeal", "icon": "lib/assets/quiz_wakeup/oatmeal.png", "isHealthy": true},
        {"id": "yogurt", "name": "Yogurt", "icon": "lib/assets/quiz_wakeup/yogurt.png", "isHealthy": true},
        {"id": "candy", "name": "Candy", "icon": "lib/assets/quiz_wakeup/candy.png", "isHealthy": false},
        {"id": "icecream", "name": "Ice Cream", "icon": "lib/assets/quiz_wakeup/icecream.png", "isHealthy": false},
      ]
    },
  ];

  @override
  void onInit() {
    super.onInit();
    // Play intro instruction first
    audioService.setInstructionAndSpeak(
      "Kiddos! lets start final quiz and it is about choosing healthy items for breakfast.",
      "goingbed_audios/breakfast_audio.mp3", 
    ).then((_) {
      // AFTER intro audio finishes, load first question
      Future.delayed(const Duration(seconds: 1), () {
        loadCurrentQuestion();
      });
    });
  }

  void loadCurrentQuestion() {
    selectedItems.clear();
    showFeedback.value = false;
    currentFoodItems.assignAll(
      List<Map<String, dynamic>>.from(questions[currentQuestionIndex.value]["options"]),
    );
    
    // Play question audio AFTER a short delay to avoid conflict
    Future.delayed(const Duration(milliseconds: 500), () {
      playQuestionAudio();
    });
  }

  void playQuestionAudio() {
    final currentAudio = questions[currentQuestionIndex.value]["audio"];
    audioService.playAudioFromPath(currentAudio);
  }

  void toggleSelection(Map<String, dynamic> food) {
    if (selectedItems.contains(food)) {
      selectedItems.remove(food);
    } else {
      selectedItems.add(food);
    }
  }

  void checkAnswer() {
    final selectedAreHealthy = selectedItems.every((item) => item["isHealthy"] == true);
    isCorrect.value = selectedItems.isNotEmpty && selectedAreHealthy;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      loadCurrentQuestion();
    } else {
      showFeedback.value = false;
      // Wait a bit before playing completion audio
      Future.delayed(const Duration(seconds: 1), () {
        audioService.setInstructionAndSpeak(
          "Great job! You finished all breakfast questions!",
          "goingbed_audios/quiz_complete.mp3",
        );
      });
    }
  }

  void resetQuiz() {
    score.value = 0;
    currentQuestionIndex.value = 0;
    
    // Play reset instruction first
    audioService.setInstructionAndSpeak(
      "Let's start over! Choose healthy breakfast foods.",
      "goingbed_audios/breakfast_reset.mp3",
    ).then((_) {
      // AFTER reset audio finishes, load question
      Future.delayed(const Duration(seconds: 1), () {
        loadCurrentQuestion();
      });
    });
  }

  double get progress => (currentQuestionIndex.value + 1) / questions.length;
}