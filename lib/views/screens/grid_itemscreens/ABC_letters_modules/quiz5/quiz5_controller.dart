import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_letters_module_controller.dart';

class SoundRecognitionController extends GetxController {
  var currentSound = "A".obs;
  var currentIndex = 0.obs;
  var correctlyAnsweredQuestions = 0.obs;
  var totalQuestions = 6;
  var retries = 0.obs;
  var wrongAttempts = 0.obs;
  var hasSubmitted = false.obs;
  var showCompletion = false.obs;
  var selectedAnswer = RxString("");
  var isCorrect = false.obs;
  var showFeedback = false.obs;

  final audioService = AudioInstructionService.to;
  final abcModuleController = Get.find<AbcLettersModuleController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  var isFeedbackPlaying = false.obs;

  var soundObjects = [
    {"sound": "A", "image": "lib/assets/quiz5_sounds/apple.png", "word": "Apple"},
    {"sound": "B", "image": "lib/assets/quiz5_sounds/ball.png", "word": "Ball"},
    {"sound": "C", "image": "lib/assets/quiz5_sounds/cat.png", "word": "Cat"},
    {"sound": "D", "image": "lib/assets/quiz5_sounds/dog.png", "word": "Dog"},
    {"sound": "E", "image": "lib/assets/quiz5_sounds/egg.png", "word": "Egg"},
    {"sound": "F", "image": "lib/assets/quiz5_sounds/fish.png", "word": "Fish"},
  ].obs;

  @override
  void onInit() {
    super.onInit();

    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "Listen carefully. I will say a word. Tap the picture that starts with the same letter!",
         // no local audio
      );
    });

    loadNextQuestion();
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }

  Future<void> playCurrentSound() async {
    String word = soundObjects[currentIndex.value]["word"]!;
    await audioService.speakText(word); // AI-generated voice
  }

  void loadNextQuestion() {
    if (currentIndex.value < soundObjects.length - 1) {
      currentIndex.value++;
      currentSound.value = soundObjects[currentIndex.value]["sound"]!;
      selectedAnswer.value = "";
      isCorrect.value = false;
      showFeedback.value = false;

      Future.delayed(const Duration(milliseconds: 600), () {
        playCurrentSound();
      });
    } else {
      showCompletion.value = true;
      audioService.speakText("Well done! You have finished all the sounds.");
    }
  }

  void checkAnswer(String chosenWord) {
    if (hasSubmitted.value) return;
    hasSubmitted.value = true;

    String correctWord = soundObjects[currentIndex.value]["word"]!;
    if (chosenWord == correctWord) {
      isCorrect.value = true;
      correctlyAnsweredQuestions.value++;
      _playFeedback("Great job! That is correct.");
    } else {
      isCorrect.value = false;
      wrongAttempts.value++;
      _playFeedback("Oops! Try again.");
    }

    showFeedback.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      hasSubmitted.value = false;
      loadNextQuestion();
    });
  }

  Future<void> _playFeedback(String text) async {
    if (isFeedbackPlaying.value) return;
    isFeedbackPlaying.value = true;
    await audioService.speakText(text);
    isFeedbackPlaying.value = false;
  }
}
