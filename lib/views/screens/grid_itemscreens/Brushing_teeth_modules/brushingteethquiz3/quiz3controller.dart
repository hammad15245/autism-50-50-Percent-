import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class Quiz3answer extends GetxController {
  final Map<String, String> answers = {
    "tooth_rush": "b",
    "M_orning": "o",
    "rin_e": "s",
    "t_eth": "e",
    "tooth_aste": "p",
  };

  final Map<String, String> images = {
    "tooth_rush": "lib/assets/quiz3_icon/toothbrush.png",
    "M_orning": "lib/assets/quiz3_icon/morning.png",
    "rin_e": "lib/assets/quiz3_icon/rinse.png",
    "t_eth": "lib/assets/quiz3_icon/teeth.png",
    "tooth_aste": "lib/assets/quiz3_icon/toothpaste.png",
  };

  var userAnswers = <String, String>{}.obs;
  var resultMap = <String, RxInt>{}.obs;
  var savedAnswersWithResult = <String, Map<String, dynamic>>{}.obs;
  var correctCount = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var hasSubmitted = false.obs;

  late final Set<String> preFilledQuestions;

  final audioService = AudioInstructionService.to;
  final brushingTeethController = Get.find<BrushingTeethModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    preFilledQuestions = answers.keys.take(2).toSet();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Ok kiddos lets Fill in the missing letters to complete the brushing teeth words!",
        "goingbed_audios/missing_letters_quiz3.mp3",
      );
    });
  }

  void updateAnswer(String question, String value) {
    userAnswers[question] = value;
    
    // Play typing sound for user feedback
    // audioService.playSoundEffect("brushing_teeth_audios/typing.mp3");
  }
void checkAllAnswers() {
  hasSubmitted.value = true;
  resultMap.clear();
  savedAnswersWithResult.clear();
  int correct = 0;
  wrongAnswersCount.value = 0;

  answers.forEach((question, correctAnswer) {
    String userAnswer = userAnswers[question] ?? '';

    if (preFilledQuestions.contains(question)) {
      resultMap[question] = 1.obs;
      correct++;
      savedAnswersWithResult[question] = {
        "answer": userAnswer,
        "isCorrect": true
      };
    } else {
      bool isCorrect = userAnswer.toLowerCase().trim() ==
          correctAnswer.toLowerCase().trim();
      resultMap[question] = isCorrect ? 1.obs : 0.obs;
      if (isCorrect) {
        correct++;
      } else {
        wrongAnswersCount.value++;
        
        // Record wrong answer
        brushingTeethController.recordWrongAnswer(
          quizId: "quiz3",
          questionId: question,
          wrongAnswer: userAnswer,
          correctAnswer: correctAnswer,
        );
      }
      savedAnswersWithResult[question] = {
        "answer": userAnswer,
        "isCorrect": isCorrect
      };
    }
  });

  correctCount.value = correct;
  
  // Play feedback sound
  if (correct == answers.length) {
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Perfect! You got all ${answers.length} answers correct!",
      "brushing_teeth_audios/quiz3_perfect.mp3",
    );
    
    // Record quiz result
    _recordQuizResult();
    
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => const Quiz4Screen());
    });
    
  } else if (correct >= answers.length * 0.7) {
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak(
      "Good job! You got $correct out of ${answers.length} correct.",
      "brushing_teeth_audios/quiz3_good.mp3",
    );
    
    // Record quiz result
    _recordQuizResult();
    
  } else {
    audioService.playIncorrectFeedback();
    audioService.setInstructionAndSpeak(
      "You got $correct out of ${answers.length}. Let's try again!",
      "brushing_teeth_audios/quiz3_try_again.mp3",
    );
    
    retries.value++;
  }
}


  void _recordQuizResult() {
    final isCompleted = correctCount.value >= answers.length * 0.7;
    
    brushingTeethController.recordQuizResult(
      quizId: "quiz3",
      score: correctCount.value,
      retries: retries.value,
      isCompleted: isCompleted,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    brushingTeethController.syncModuleProgress();
  }

  void retryQuiz() {
    retries.value++;
    userAnswers.clear();
    resultMap.clear();
    savedAnswersWithResult.clear();
    correctCount.value = 0;
    wrongAnswersCount.value = 0;
    hasSubmitted.value = false;
    
    audioService.setInstructionAndSpeak(
      "Let's try filling the missing letters again!",
      "brushing_teeth_audios/quiz3_retry.mp3",
    );
  }

  void resetQuiz() {
    retries.value = 0;
    userAnswers.clear();
    resultMap.clear();
    savedAnswersWithResult.clear();
    correctCount.value = 0;
    wrongAnswersCount.value = 0;
    hasSubmitted.value = false;
  }

}