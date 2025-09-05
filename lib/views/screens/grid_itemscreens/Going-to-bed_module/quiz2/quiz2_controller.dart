import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class EmotionChoiceQuizController extends GetxController {
  final audioService = AudioInstructionService.to;
  RxString get instructionText => audioService.instructionText;

  final RxInt currentQuestionIndex = 0.obs;
  final RxString selectedOptionId = "".obs;
  final RxList<String> selectedAnswers = <String>[].obs;

  final RxBool showFeedback = false.obs;
  final RxBool lastAnswerCorrect = false.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What is the best time to sleep?",
      "audio": "quiz2_q1", // Remove .mp3 extension here
      "options": [
        {
          "id": "morning",
          "image": "lib/assets/quiz_goingtobed/day.png",
          "text": "Day",
          "isCorrect": false,
        },
        {
          "id": "night",
          "image": "lib/assets/quiz_goingtobed/night.png",
          "text": "Night",
          "isCorrect": true,
        },
      ],
    },
    {
      "question": "Which bedroom is more clean?",
      "audio": "quiz2_q2", // Remove .mp3 extension here
      "options": [
        {
          "id": "clean",
          "image": "lib/assets/quiz_goingtobed/clean_bed.png",
          "text": "Clean Bed",
          "isCorrect": true,
        },
        {
          "id": "messy",
          "image": "lib/assets/quiz_goingtobed/dirty_bed.png",
          "text": "Dirty Bed",
          "isCorrect": false,
        },
      ],
    },
    {
      "question": "What do we need to do before sleep?",
      "audio": "quiz2_q3", // Remove .mp3 extension here
      "options": [
        {
          "id": "book",
          "image": "lib/assets/quiz_goingtobed/book.png",
          "text": "Read Book",
          "isCorrect": true,
        },
        {
          "id": "phone",
          "image": "lib/assets/quiz_goingtobed/phone.png",
          "text": "Use Mobile phone",
          "isCorrect": false,
        },
      ],
    },
  ];

@override
void onInit() {
  super.onInit();

  Future.delayed(Duration.zero, () {
    audioService.setInstructionAndSpeak(
      "Ok now Let's learn about good bedtime habits! Choose the best option for each question.",
      "goingbed_audios/quiz2.mp3", 
    );
  });
  
  Future.delayed(const Duration(seconds: 9), () {
    playQuestionInstruction();
  });
}
  void playQuestionInstruction() {
    final audioPath = questions[currentQuestionIndex.value]["audio"];
    if (audioPath != null && audioPath.isNotEmpty) {
      audioService.playAudioFromPath(audioPath);
    }
  }

  void selectOption(String optionId) {
    final current = questions[currentQuestionIndex.value];
    final selected = current["options"].firstWhere((opt) => opt["id"] == optionId);

    selectedOptionId.value = optionId;
    showFeedback.value = true;
    lastAnswerCorrect.value = selected["isCorrect"];

    selected["isCorrect"]
        ? audioService.playCorrectFeedback()
        : audioService.playIncorrectFeedback();

    Future.delayed(const Duration(seconds: 2), () { // Increased delay to 2 seconds
      if (!isLastQuestion) {
        currentQuestionIndex.value++;
        selectedOptionId.value = "";
        showFeedback.value = false;
        
        Future.delayed(const Duration(milliseconds: 500), () {
          playQuestionInstruction();
        });
      }
    });
  }
    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      // Get.to(() => const Emotionscreeen());
      

    
}
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
}