import 'package:autism_fyp/views/screens/grid_itemscreens/wakeup_module/quiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class MatchSoundController extends GetxController {
  final audioService = AudioInstructionService.to;

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  final List<Map<String, dynamic>> quizQuestions = [
    {
      "id": 1,
      "soundFile": "alarm", // just file name, no extension
      "correctAnswer": "alarm",
      "options": [
        {"id": "alarm", "name": "Alarm Clock", "icon": "lib/assets/quiz_wakeup/clock.png"},
        {"id": "phone", "name": "Phone", "icon": "lib/assets/quiz_wakeup/phone.png"}
      ]
    },
    {
      "id": 2,
      "soundFile": "rooster",
      "correctAnswer": "rooster",
      "options": [
        {"id": "rooster", "name": "Rooster", "icon": "lib/assets/quiz_wakeup/rooster.png"},
        {"id": "bird", "name": "Bird", "icon": "lib/assets/quiz_wakeup/bird.png"}
      ]
    },
  ];

  var currentQuestionIndex = 0.obs;
  var selectedAnswer = RxString('');
  var showFeedback = false.obs;
  var isCorrect = false.obs;

  @override
  void onInit() {
    super.onInit();
    setInstruction("listen to the sound carefully and tap the picture that belongs to sound.",
     "goingbed_audios/matchsound_audio.mp3");
     Future.delayed(const Duration(seconds: 7), () {
         loadQuestion();

    });
  }

  void playSound() {
    final currentSound = quizQuestions[currentQuestionIndex.value]["soundFile"];
    audioService.playAudioFromPath(currentSound);
  }

  void loadQuestion() {
    selectedAnswer.value = '';
    showFeedback.value = false;

    Future.delayed(const Duration(milliseconds: 800), () {
      playSound();
    });
  }

  void checkAnswer(String answerId) {
    selectedAnswer.value = answerId;
    final currentQuestion = quizQuestions[currentQuestionIndex.value];
    final isAnswerCorrect = answerId == currentQuestion["correctAnswer"];

    isCorrect.value = isAnswerCorrect;
    showFeedback.value = true;

    if (isAnswerCorrect) {
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < quizQuestions.length - 1) {
      currentQuestionIndex.value++;
      loadQuestion();
    } else {
     
      Get.to(() => const BreakfastSortingscreen());
      

    
    }
  }



  void setInstruction(String text, String audioPath) {
    audioService.setInstructionAndSpeak(text, audioPath);
  }

  Map<String, dynamic> get currentQuestion => quizQuestions[currentQuestionIndex.value];

  bool get isLastQuestion => currentQuestionIndex.value == quizQuestions.length - 1;
  bool get hasSelectedAnswer => selectedAnswer.value.isNotEmpty;
}
