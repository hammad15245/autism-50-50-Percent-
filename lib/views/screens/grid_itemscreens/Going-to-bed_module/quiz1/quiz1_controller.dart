import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BedtimeController extends GetxController {
  final audioService = AudioInstructionService.to;

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

  @override
  void onInit() {
    super.onInit();

    // Safe delayed call to avoid build-phase update issues
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddo! Welcome to this module, let's start quiz1.",
        "goingbed_audios/quiz1.mp3",
      );
    });
  }

  // ---------------- QUIZ LOGIC ---------------- //

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
      audioService.playIncorrectFeedback();
    }

    return isCorrect;
  }


    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      Get.to(() => const Emotionscreeen());
      

    
}
  void resetQuiz() {
    currentSequence.clear();
    audioService.setInstructionAndSpeak(
      "The quiz has been reset. Try again and arrange your bedtime steps correctly.",
      "audio/kid_voice_reset.mp3",
    );
  }
}