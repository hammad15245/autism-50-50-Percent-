import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class LivingNonLivingQuiz2Controller extends GetxController {
  final audioService = AudioInstructionService.to;
  RxString get instruction => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var selectedObjects = <String>[].obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;

  final List<Map<String, dynamic>> objects = [
    {"id": "cat", "name": "Cat", "icon": "lib/assets/living_nonliving/cat.png", "isLiving": true},
    {"id": "tree", "name": "Tree", "icon": "lib/assets/living_nonliving/tree.png", "isLiving": true},
    {"id": "car", "name": "Car", "icon": "lib/assets/living_nonliving/car.png", "isLiving": false},
    {"id": "rock", "name": "Rock", "icon": "lib/assets/living_nonliving/rock.png", "isLiving": false},
    {"id": "ball", "name": "Ball", "icon": "lib/assets/living_nonliving/ball.png", "isLiving": false},
    {"id": "flower", "name": "Flower", "icon": "lib/assets/living_nonliving/flower.png", "isLiving": true},
  ];

  @override
  void onInit() {
    super.onInit();
    _playInstruction();
  }

  void _playInstruction() {
    audioService.setInstructionAndSpeak(
      "Select only the living things by tapping on them!",
      "living_nonliving_audios/quiz2_instruction.mp3",
    );
  }

  void toggleSelection(String id) {
    if (selectedObjects.contains(id)) {
      selectedObjects.remove(id);
    } else {
      selectedObjects.add(id);
    }
  }

  void checkAnswer() {
    final correctIds = objects.where((obj) => obj["isLiving"] == true).map((e) => e["id"]).toList();
    isCorrect.value = selectedObjects.toSet().containsAll(correctIds) &&
        selectedObjects.length == correctIds.length;

    showFeedback.value = true;

    if (isCorrect.value) {
      audioService.playCorrectFeedback();
    } else {
      audioService.playIncorrectFeedback();
    }
  }

  void resetQuiz() {
    selectedObjects.clear();
    showFeedback.value = false;
    _playInstruction();
  }
}
