import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/home_animal_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/quiz2/quiz2_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class AnimalSortingController extends GetxController {
  final audioService = AudioInstructionService.to;
final homeAnimalsController = Get.find<HomeAnimalsController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var currentQuestionIndex = 0.obs;
  var score = 0.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;
  var completedAnimals = <String>[].obs;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "Drag animals to WILD or HOME side",
      "animals": [
        {"id": "lion", "name": "Lion", "icon": "lib/assets/home_animals/lion.png", "type": "wild", "fact": "Lions are wild animals that live in grasslands!"},
        {"id": "dog", "name": "Dog", "icon": "lib/assets/home_animals/dog.png", "type": "home", "fact": "Dogs are home animals and make great pets!"},
        {"id": "elephant", "name": "Elephant", "icon": "lib/assets/home_animals/elephant.png", "type": "wild", "fact": "Elephants are wild animals from Africa and Asia!"},
        {"id": "cat", "name": "Cat", "icon": "lib/assets/home_animals/cat.png", "type": "home", "fact": "Cats are home animals that love to nap!"},
        {"id": "monkey", "name": "Monkey", "icon": "lib/assets/home_animals/monkey.png", "type": "wild", "fact": "Monkeys are wild animals that live in trees!"},
        {"id": "rabbit", "name": "Rabbit", "icon": "lib/assets/home_animals/rabbit.png", "type": "home", "fact": "Rabbits are home animals that hop around!"},
        {"id": "chicken", "name": "Chicken", "icon": "lib/assets/home_animals/chicken.png", "type": "home", "fact": "cats are home animals that hop around!"},
        {"id": "wolf", "name": "Wolf", "icon": "lib/assets/home_animals/wolf.png", "type": "wild", "fact": "goat are home animals that hop around!"}
      ]
    }
  ];

  var wildAnimals = <Map<String, dynamic>>[].obs;
  var homeAnimals = <Map<String, dynamic>>[].obs;

  final String quizid = "1";

  @override
  void onInit() {
    super.onInit();
    audioService.setInstructionAndSpeak(
      "Hey kiddos! Welcome to Animal Sorting! Drag animals to wild or home side.",
      "goingbed_audios/animalsort_intro.mp3",
    ).then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        loadQuestion();
      });
    });
  }

  void loadQuestion() {
    wildAnimals.clear();
    homeAnimals.clear();
    completedAnimals.clear();
    showFeedback.value = false;
  }

  void placeAnimal(Map<String, dynamic> animal, String category) {
    wildAnimals.removeWhere((a) => a["id"] == animal["id"]);
    homeAnimals.removeWhere((a) => a["id"] == animal["id"]);

    if (category == "wild") {
      wildAnimals.add(animal);
    } else {
      homeAnimals.add(animal);
    }

    completedAnimals.add(animal["id"]);

    if (completedAnimals.length ==
        questions[currentQuestionIndex.value]["animals"].length) {
      checkAnswer();
    }
  }

  void checkAnswer() {
    final currentAnimals = questions[currentQuestionIndex.value]["animals"];
    bool allCorrect = true;

    for (var animal in wildAnimals) {
      if (animal["type"] != "wild") {
        allCorrect = false;
        break;
      }
    }

    for (var animal in homeAnimals) {
      if (animal["type"] != "home") {
        allCorrect = false;
        break;
      }
    }

    allCorrect = allCorrect && completedAnimals.length == currentAnimals.length;

    isCorrect.value = allCorrect;
    showFeedback.value = true;

    if (isCorrect.value) {
      score.value++;
      audioService.playCorrectFeedback();
      updateProgress();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  Future<void> updateProgress() async {
    try {
      homeAnimalsController.recordQuizResult(
        quizId: quizid,
        score: score.value,
        retries: 0,
        isCompleted: true,
      );
      await homeAnimalsController.syncModuleProgress();
    } catch (e) {
      print("❌ Error updating progress: $e");
    }
  }

  void resetQuestion() {
    loadQuestion();
  }

  void checkAnswerAndNavigate() {
    Get.to(() => const AnimalPatternsscreen());
  }

  Map<String, dynamic> get currentQuestion =>
      questions[currentQuestionIndex.value];
  List<Map<String, dynamic>> get currentAnimals =>
      questions[currentQuestionIndex.value]["animals"];
  bool get allAnimalsPlaced =>
      completedAnimals.length == currentAnimals.length;
}
