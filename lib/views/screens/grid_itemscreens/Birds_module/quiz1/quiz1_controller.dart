import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/birds_module_controller.dart';

class birdcontroller extends GetxController {
  final audioService = AudioInstructionService.to;
  final birdsModuleController = Get.find<BirdsModuleController>();
  
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var selectedBird = RxString('');
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var score = 0.obs;

  // Progress tracking
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Listen carefully! Which bird makes this sound?",
      "correctBird": "sparrow",
      "audio": "sparrow", 
      "options": [
        {
          "id": "sparrow",
          "name": "Sparrow",
          "icon": "lib/assets/quiz1_birds/sparrow.png",
        },
        {
          "id": "eagle",
          "name": "Eagle",
          "icon": "lib/assets/quiz1_birds/eagle.png", 
        }
      ]
    },
    {
      "question": "Can you identify this bird sound?",
      "instruction": "Listen to the sound! Which bird is singing?",
      "correctBird": "owl",
      "audio": "owl",
      "options": [
        {
          "id": "robin",
          "name": "Robin",
          "icon": "lib/assets/quiz1_birds/robin.png",
        },
        {
          "id": "owl",
          "name": "Owl",
          "icon": "lib/assets/quiz1_birds/owl.png",
        }
      ]
    }
  ];

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "Hey kiddos! Welcome to Bird Sound Matching. Listen to the sounds and find the right bird.",
      "goingbed_audios/birds_intro.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void loadCurrentQuestion() {
    selectedBird.value = '';
    showFeedback.value = false;
    isCorrect.value = false;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      playQuestionSound();
    });
  }

  void playQuestionSound() {
    final currentAudio = questions[currentQuestionIndex.value]["audio"];
    audioService.playAudioFromPath(currentAudio);
  }

  void checkAnswer(String birdId) {
    if (hasSubmitted.value) return;
    
    selectedBird.value = birdId;
    final correctAnswer = questions[currentQuestionIndex.value]["correctBird"];
    isCorrect.value = birdId == correctAnswer;
    showFeedback.value = true;

    if (isCorrect.value) {
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
      birdsModuleController.recordWrongAnswer(
        quizId: "quiz1",
        questionId: "Question ${currentQuestionIndex.value + 1}",
        wrongAnswer: "Selected $birdId",
        correctAnswer: "Should select $correctAnswer",
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
      "Excellent! You identified all the bird sounds correctly!",
      "goingbed_audios/birds_complete.mp3",
    );
    
    // Record quiz result
    birdsModuleController.recordQuizResult(
      quizId: "quiz1",
      score: score.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    
    // Sync progress
    birdsModuleController.syncModuleProgress();
  }

  void retryQuestion() {
    showFeedback.value = false;
    selectedBird.value = '';
    playQuestionSound(); // Replay the sound for retry
  }

  void resetQuiz() {
    currentQuestionIndex.value = 0;
    selectedBird.value = '';
    showFeedback.value = false;
    isCorrect.value = false;
    score.value = 0;
    retries.value++;
    wrongAttempts.value = 0;
    hasSubmitted.value = false;
    showCompletion.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's listen to the bird sounds again!",
      "goingbed_audios/birds_reset.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadCurrentQuestion();
      });
    });
  }

  void checkAnswerAndNavigate() {
    if (hasSubmitted.value && showCompletion.value) {
      // Navigate to the next screen
      Get.to(() => const BirdHabitatscreen());
    } else {
      // If not completed, just check the answer
      if (selectedBird.value.isNotEmpty) {
        checkAnswer(selectedBird.value);
      }
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