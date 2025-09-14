import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/goindbed_controller.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class EmotionChoiceQuizController extends GetxController {
  final audioService = AudioInstructionService.to;
  final goingToBedController = Get.find<GoingToBedController>();

  RxString get instructionText => audioService.instructionText;

  final RxInt currentQuestionIndex = 0.obs;
  final RxString selectedOptionId = "".obs;
  final RxList<String> selectedAnswers = <String>[].obs;

  final RxBool showFeedback = false.obs;
  final RxBool lastAnswerCorrect = false.obs;

  final RxInt correctAnswers = 0.obs;
  final RxInt wrongAnswers = 0.obs;
  final RxInt retries = 0.obs;

  final int totalScore = 5; // you can adjust

  final List<Map<String, dynamic>> questions = [
    {
      "question": "What is the best time to sleep?",
      "audio": "quiz2_q1",
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
      "audio": "quiz2_q2",
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
      "audio": "quiz2_q3",
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
      );
    });

    Future.delayed(const Duration(seconds: 9), () {
      playQuestionInstruction();
    });
  }

  void playQuestionInstruction() {
    final audioPath = questions[currentQuestionIndex.value]["audio"];
    if (audioPath != null && audioPath.isNotEmpty) {
    }
  }

  void selectOption(String optionId) {
    final current = questions[currentQuestionIndex.value];
    final selected = current["options"].firstWhere((opt) => opt["id"] == optionId);

    selectedOptionId.value = optionId;
    showFeedback.value = true;
    lastAnswerCorrect.value = selected["isCorrect"];

    if (selected["isCorrect"]) {
      correctAnswers.value++;
      audioService.playCorrectFeedback();
    } else {
      wrongAnswers.value++;
      retries.value++;
      audioService.playIncorrectFeedback();
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!isLastQuestion) {
        currentQuestionIndex.value++;
        selectedOptionId.value = "";
        showFeedback.value = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          playQuestionInstruction();
        });
      } else {
        saveProgress();
      }
    });
  }

  Future<void> saveProgress() async {
    try {
      goingToBedController.recordQuizResult(
        quizId: "quiz2",
        score: correctAnswers.value,
        retries: retries.value,
        isCompleted: true,
      );
      await goingToBedController.syncModuleProgress();
    } catch (e) {
      print("❌ Error saving Quiz2 progress: $e");
    }
  }


    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      // Get.to(() => const HealthyTreatscreen());
      

    
}
  bool get isLastQuestion => currentQuestionIndex.value == questions.length - 1;
}
