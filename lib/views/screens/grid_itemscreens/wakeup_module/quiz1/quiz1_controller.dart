import 'package:autism_fyp/views/screens/grid_itemscreens/wakeup_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class WakeUpController extends GetxController {
  
  final audioService = AudioInstructionService.to;

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  // CORRECT sequence (for validation)
  final List<Map<String, String>> correctSequence = [
    {
      "id": "wake",
      "name": "Wake Up",
      "icon": "lib/assets/quiz_wakeup/wakeup.png"
    },
    {
      "id": "stretch", 
      "name": "Stretch",
      "icon": "lib/assets/quiz_wakeup/stretch.png"
    },
    {
      "id": "wash",
      "name": "Wash Face", 
      "icon": "lib/assets/quiz_wakeup/wash.png"
    },
    {
      "id": "brush",
      "name": "Brush Teeth",
      "icon": "lib/assets/quiz_wakeup/toothbrush.png"
    },
    {
      "id": "dress",
      "name": "Get Dressed",
      "icon": "lib/assets/quiz_wakeup/dress.png"
    },
    {
      "id": "breakfast",
      "name": "Eat Breakfast",
      "icon": "lib/assets/quiz_wakeup/breakfast.png"
    },
  ];

  var currentSequence = <Map<String, String>>[].obs;
  var displayedItems = <Map<String, String>>[].obs; // SHUFFLED version for display
  
  // NEW: Feedback variables
  var lastAnswerCorrect = false.obs;
  var hasFeedback = false.obs;

  @override
  void onInit() {
    super.onInit();
    shuffleItems();
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Hey kiddo! welcome to this quiz lets start sequencing the morning routine.",
        "goingbed_audios/wakeup_audio.mp3",
      );
    });
  }

  void shuffleItems() {
    displayedItems.clear();
    displayedItems.addAll(List.from(correctSequence)..shuffle());
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

    // NEW: Set feedback states
    lastAnswerCorrect.value = isCorrect;
    hasFeedback.value = true;

    if (isCorrect) {
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }

    return isCorrect;
  }

  void resetQuiz() {
    currentSequence.clear();
    // NEW: Reset feedback states
    hasFeedback.value = false;
    shuffleItems(); // Reshuffle when resetting
    audioService.setInstructionAndSpeak(
      "Hey kiddo! welcome to this quiz lets start sequencing the morning routine.",
      "goingbed_audios/wakeup_audio.mp3",
    );
  }
  
    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      Get.to(() => const matchsoundscreen());
      

    
}
}