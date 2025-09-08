import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class birdcontroller extends GetxController {
  final audioService = AudioInstructionService.to;
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var selectedBird = RxString('');
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var score = 0.obs;

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
    
    Future.delayed(const Duration(milliseconds: 500), () {
      playQuestionSound();
    });
  }

  void playQuestionSound() {
    final currentAudio = questions[currentQuestionIndex.value]["audio"];
    audioService.playAudioFromPath(currentAudio);
  }

  void checkAnswer(String birdId) {
    selectedBird.value = birdId;
    final correctAnswer = questions[currentQuestionIndex.value]["correctBird"];
    isCorrect.value = birdId == correctAnswer;
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
    } 
  }

  void retryQuestion() {
    showFeedback.value = false;
    selectedBird.value = '';
    playQuestionSound(); // Replay the sound for retry
  }

  // void resetQuiz() {
  //   score.value = 0;
  //   currentQuestionIndex.value = 0;
  //   audioService.setInstructionAndSpeak(
  //     "Let's listen to the bird sounds again!",
  //     "goingbed_audios/birds_reset.mp3",
  //   ).then((_) {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       loadCurrentQuestion();
  //     });
  //   });
  // }
   void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      Get.to(() => const BirdHabitatscreen());
      

    
}

  Map<String, dynamic> get currentQuestion => questions[currentQuestionIndex.value];
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
}

