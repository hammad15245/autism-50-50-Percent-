import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class BirdHabitatController extends GetxController {
  final audioService = AudioInstructionService.to;
  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var score = 0.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var draggedBird = RxString('');

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Match birds to their homes!",
      // "audio": "habitat_intro",
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
        {
          "id": "owl",
          "name": "Owl",
          "icon": "lib/assets/quiz1_birds/owl.png",
          "correctHabitat": "forest"
        },
        {
          "id": "duck",
          "name": "Duck",
          "icon": "lib/assets/quiz1_birds/duck.png",
          "correctHabitat": "water"
        },
        {
          "id": "pigeon",
          "name": "Pigeon", 
          "icon": "lib/assets/quiz1_birds/pigeon.png",
          "correctHabitat": "city"
        },
        {
          "id": "woodpecker",
          "name": "Woodpecker",
          "icon": "lib/assets/quiz1_birds/woodpecker.png",
          "correctHabitat": "forest"
        },
        {
          "id": "swan",
          "name": "Swan",
          "icon": "lib/assets/quiz1_birds/swan.png",
          "correctHabitat": "water"
        },
        {
          "id": "sparrow",
          "name": "Sparrow",
          "icon": "lib/assets/quiz1_birds/sparrow.png",
          "correctHabitat": "city"
        }
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
      "Lets solve the quiz for Bird Habitat Matching! Drag birds to their homes.",
      "goingbed_audios/habitat_intro.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadQuestion();
      });
    });
  }

  void loadQuestion() {
    forestBirds.clear();
    waterBirds.clear();
    cityBirds.clear();
    showFeedback.value = false;
    draggedBird.value = '';
  }

  void addBirdToHabitat(String birdId, String habitatType) {
    final birds = currentQuestion["birds"] as List<Map<String, dynamic>>;
    final bird = birds.firstWhere((b) => b["id"] == birdId);
    
    forestBirds.removeWhere((b) => b["id"] == birdId);
    waterBirds.removeWhere((b) => b["id"] == birdId);
    cityBirds.removeWhere((b) => b["id"] == birdId);

    switch (habitatType) {
      case "forest":
        forestBirds.add(bird);
        break;
      case "water":
        waterBirds.add(bird);
        break;
      case "city":
        cityBirds.add(bird);
        break;
    }
  }

  void checkAnswer() {
    final currentQuestion = this.currentQuestion;
    bool allCorrect = true;

    final forestCorrectIds = currentQuestion["habitats"]
        .firstWhere((h) => h["type"] == "forest")["correctBirds"];
    allCorrect = allCorrect && forestBirds.length == forestCorrectIds.length &&
        forestBirds.every((bird) => forestCorrectIds.contains(bird["id"]));

    final waterCorrectIds = currentQuestion["habitats"]
        .firstWhere((h) => h["type"] == "water")["correctBirds"];
    allCorrect = allCorrect && waterBirds.length == waterCorrectIds.length &&
        waterBirds.every((bird) => waterCorrectIds.contains(bird["id"]));

    final cityCorrectIds = currentQuestion["habitats"]
        .firstWhere((h) => h["type"] == "city")["correctBirds"];
    allCorrect = allCorrect && cityBirds.length == cityCorrectIds.length &&
        cityBirds.every((bird) => cityCorrectIds.contains(bird["id"]));

    isCorrect.value = allCorrect;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  void resetQuestion() {
    loadQuestion();
  }

  // void nextQuestion() {
  //   if (currentQuestionIndex.value < questions.length - 1) {
  //     currentQuestionIndex.value++;
  //     loadQuestion();
  //   } else {
  //     showFeedback.value = false;
  //     audioService.setInstructionAndSpeak(
  //       "Amazing! You helped all birds find their homes!",
  //       "goingbed_audios/habitat_complete.mp3",
  //     );
  //   }
  // }
   void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      // Get.to(() => const BirdHabitatscreen());
      

    
}
  Map<String, dynamic> get currentQuestion {
    if (currentQuestionIndex.value >= questions.length) {
      currentQuestionIndex.value = 0; // fallback safety
    }
    final question = questions[currentQuestionIndex.value];
    question["birds"] = (question["birds"] as List)
        .map((b) => Map<String, dynamic>.from(b))
        .toList();
    return question;
  }
}
