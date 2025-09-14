import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/birds_module_controller.dart';

class BirdHabitatController extends GetxController {
  final audioService = AudioInstructionService.to;
  final birdsModuleController = Get.find<BirdsModuleController>();
  
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var score = 0.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var draggedBird = RxString('');

  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Match birds to their homes!",
      "habitats": [
        {
          "type": "forest",
          "name": "Forest",
          "icon": "lib/assets/quiz1_birds/forest.png",
          "correctBirds": ["owl", "woodpecker"]
        },
        {
          "type": "water", 
          "name": "Water",
          "icon": "lib/assets/quiz1_birds/water.png",
          "correctBirds": ["duck", "swan"]
        },
        {
          "type": "city",
          "name": "City",
          "icon": "lib/assets/quiz1_birds/city.png", 
          "correctBirds": ["pigeon", "sparrow"]
        }
      ],
      "birds": [
        {"id": "owl", "name": "Owl", "icon": "lib/assets/quiz1_birds/owl.png", "correctHabitat": "forest"},
        {"id": "duck", "name": "Duck", "icon": "lib/assets/quiz1_birds/duck.png", "correctHabitat": "water"},
        {"id": "pigeon", "name": "Pigeon", "icon": "lib/assets/quiz1_birds/pigeon.png", "correctHabitat": "city"},
        {"id": "woodpecker", "name": "Woodpecker", "icon": "lib/assets/quiz1_birds/woodpecker.png", "correctHabitat": "forest"},
        {"id": "swan", "name": "Swan", "icon": "lib/assets/quiz1_birds/swan.png", "correctHabitat": "water"},
        {"id": "sparrow", "name": "Sparrow", "icon": "lib/assets/quiz1_birds/sparrow.png", "correctHabitat": "city"},
      ]
    }
  ];

  var forestBirds = <Map<String, dynamic>>[].obs;
  var waterBirds = <Map<String, dynamic>>[].obs;
  var cityBirds = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "Let's solve the quiz for Bird Habitat Matching! Drag birds to their homes."
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () => loadQuestion());
    });
  }

  void loadQuestion() {
    forestBirds.clear();
    waterBirds.clear();
    cityBirds.clear();
    showFeedback.value = false;
    draggedBird.value = '';
    isCorrect.value = false;
  }

  void addBirdToHabitat(String birdId, String habitatType) {
    if (hasSubmitted.value) return;
    final birds = currentQuestion["birds"] as List<Map<String, dynamic>>;
    final bird = birds.firstWhere((b) => b["id"] == birdId);
    
    forestBirds.removeWhere((b) => b["id"] == birdId);
    waterBirds.removeWhere((b) => b["id"] == birdId);
    cityBirds.removeWhere((b) => b["id"] == birdId);

    switch (habitatType) {
      case "forest": forestBirds.add(bird); break;
      case "water": waterBirds.add(bird); break;
      case "city": cityBirds.add(bird); break;
    }
  }

  void checkAnswer() {
    if (hasSubmitted.value) return;

    final q = currentQuestion;
    bool allCorrect = true;

    final forestCorrectIds = q["habitats"].firstWhere((h) => h["type"] == "forest")["correctBirds"];
    allCorrect = allCorrect &&
        forestBirds.length == forestCorrectIds.length &&
        forestBirds.every((b) => forestCorrectIds.contains(b["id"]));

    final waterCorrectIds = q["habitats"].firstWhere((h) => h["type"] == "water")["correctBirds"];
    allCorrect = allCorrect &&
        waterBirds.length == waterCorrectIds.length &&
        waterBirds.every((b) => waterCorrectIds.contains(b["id"]));

    final cityCorrectIds = q["habitats"].firstWhere((h) => h["type"] == "city")["correctBirds"];
    allCorrect = allCorrect &&
        cityBirds.length == cityCorrectIds.length &&
        cityBirds.every((b) => cityCorrectIds.contains(b["id"]));

    isCorrect.value = allCorrect;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
      completeQuiz();
    } else {
      wrongAttempts.value++;
      audioService.playIncorrectFeedback();
      birdsModuleController.recordWrongAnswer(
        quizId: "quiz2",
        questionId: "Bird Habitat Matching",
        wrongAnswer: "Incorrect habitat placements",
        correctAnswer: "Forest: owl, woodpecker | Water: duck, swan | City: pigeon, sparrow",
      );
    }
  }

  void completeQuiz() {
    showCompletion.value = true;
    hasSubmitted.value = true;
    audioService.playCorrectFeedback();
    audioService.setInstructionAndSpeak("Amazing! You helped all birds find their homes!");
    birdsModuleController.recordQuizResult(
      quizId: "quiz2",
      score: score.value,
      retries: retries.value,
      isCompleted: true,
      wrongAnswersCount: wrongAttempts.value,
    );
    birdsModuleController.syncModuleProgress();
  }

  void resetQuestion() {
    loadQuestion();
    retries.value++;
    audioService.setInstructionAndSpeak("Let's try again! Drag the birds to the correct homes.");
  }

  void checkAnswerAndNavigate() {
    if (hasSubmitted.value && showCompletion.value) {
      // Navigation handled outside
    } else {
      checkAnswer();
    }
  }

  double getProgressPercentage() {
    final totalBirds = currentQuestion["birds"].length;
    final placedBirds = forestBirds.length + waterBirds.length + cityBirds.length;
    return placedBirds / totalBirds;
  }

  int getRemainingBirds() {
    final totalBirds = currentQuestion["birds"].length;
    final placedBirds = forestBirds.length + waterBirds.length + cityBirds.length;
    return totalBirds - placedBirds;
  }

  String getProgressText() {
    final totalBirds = currentQuestion["birds"].length;
    final placedBirds = forestBirds.length + waterBirds.length + cityBirds.length;
    return "$placedBirds/$totalBirds birds placed";
  }

  Map<String, dynamic> get currentQuestion {
    if (currentQuestionIndex.value >= questions.length) {
      currentQuestionIndex.value = 0;
    }
    final q = questions[currentQuestionIndex.value];
    q["birds"] = (q["birds"] as List).map((b) => Map<String, dynamic>.from(b)).toList();
    return q;
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}
