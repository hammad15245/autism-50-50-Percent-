import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/goindbed_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';

class BedtimeController extends GetxController {
  final audioService = AudioInstructionService.to;
  final goingToBedController = Get.find<GoingToBedController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  final correctSequence = [
    {
      "id": "brush",
      "name": "Brush Teeth",
      "icon": "lib/assets/quiz_goingtobed/toothbrush.png"
    },
    {
      "id": "pajamas",
      "name": "Put on Pajamas",
      "icon": "lib/assets/quiz_goingtobed/pajamas.png"
    },
    {
      "id": "book",
      "name": "Read a Book",
      "icon": "lib/assets/quiz_goingtobed/book.png"
    },
    {
      "id": "sleep",
      "name": "Sleep",
      "icon": "lib/assets/quiz_goingtobed/sleep.png"
    },
  ];

  var currentSequence = <Map<String, String>>[].obs;
  var retries = 0.obs;
  final int totalScore = 5;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddo! Welcome to this module, let's start quiz 1.",
      );
    });
  }

  void addStep(Map<String, String> step) {
    if (!currentSequence.contains(step)) {
      currentSequence.add(step);
    }
  }

  void removeStep(Map<String, String> step) {
    currentSequence.remove(step);
  }

  bool checkAnswer() {
    final isCorrect = currentSequence.length == correctSequence.length &&
        List.generate(correctSequence.length,
                (i) => currentSequence[i]["id"] == correctSequence[i]["id"])
            .every((match) => match);

    if (isCorrect) {
      audioService.playCorrectFeedback();
    } else {
      retries.value++;
      audioService.playIncorrectFeedback();
    }

    return isCorrect;
  }

  Future<void> checkAnswerAndNavigate() async {
    final result = checkAnswer();

    if (result) {
      goingToBedController.recordQuizResult(
        quizId: "quiz1",
        score: totalScore,
        retries: retries.value,
        isCompleted: true,
      );

      await goingToBedController.syncModuleProgress();

      Get.to(() => const Emotionscreeen());
    } else {
      audioService.setInstructionAndSpeak(
        "Hmm, that order is not quite right. Try again!",
      );
    }
  }

  void resetQuiz() {
    currentSequence.clear();
    audioService.setInstructionAndSpeak(
      "The quiz has been reset. Try again and arrange your bedtime steps correctly.",
    );
  }
}
