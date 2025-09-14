import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:confetti/confetti.dart';

class SpeechLetterQuiz extends StatefulWidget {
  const SpeechLetterQuiz({super.key});

  @override
  State<SpeechLetterQuiz> createState() => _SpeechLetterQuizState();
}

class _SpeechLetterQuizState extends State<SpeechLetterQuiz> {
  final AlphabetQuizController controller = Get.put(AlphabetQuizController());
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  var isListening = false.obs;
  var recognizedText = ''.obs;
  var showFeedback = false.obs;
  var isCorrect = false.obs;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await speechToText.initialize(
      onStatus: (status) =>
          isListening.value = status == stt.SpeechToText.listeningStatus,
      onError: (error) => print("Speech recognition error: $error"),
    );

    if (!available) Get.snackbar("Error", "Speech recognition not available");
  }

  void _startListening() async {
    recognizedText.value = '';
    showFeedback.value = false;

    await speechToText.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;

        controller.checkLetterPronunciation(
          spokenText: recognizedText.value,
          onCorrect: _handleCorrectPronunciation,
          onIncorrect: _handleIncorrectPronunciation,
        );
      },
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  void _handleCorrectPronunciation() {
    speechToText.stop();
    isCorrect.value = true;
    showFeedback.value = true;
    confettiController.play();

    Future.delayed(const Duration(seconds: 2), () {
      showFeedback.value = false;
      isCorrect.value = false;
      recognizedText.value = '';
      controller.nextLetter();
    });
  }

  void _handleIncorrectPronunciation() {
    speechToText.stop();
    isCorrect.value = false;
    showFeedback.value = true;

    Future.delayed(const Duration(seconds: 2), () {
      showFeedback.value = false;
      recognizedText.value = '';
      controller.repeatInstruction();
    });
  }

  void _repeatInstruction() => controller.repeatInstruction();

  @override
  void dispose() {
    speechToText.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() {
                final letter = controller.letters[controller.currentLetterIndex.value];
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue.shade50,
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.black54, size: 28),
                        onPressed: _repeatInstruction,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 40),
              Obx(() => Column(
                    children: [
                      ElevatedButton(
                        onPressed: isListening.value ? null : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isListening.value ? Colors.grey : Color(0xFF0E83AD),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: Icon(
                          isListening.value ? Icons.mic : Icons.mic_none,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (recognizedText.isNotEmpty)
                        Text(
                          "You said: ${recognizedText.value}",
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      if (showFeedback.value)
                        Text(
                          isCorrect.value ? "✅ Correct!" : "❌ Try again!",
                          style: TextStyle(
                            fontSize: 20,
                            color: isCorrect.value ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      LinearProgressIndicator(
                        value: (controller.currentLetterIndex.value + 1) /
                            controller.letters.length,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Letter ${controller.currentLetterIndex.value + 1}/${controller.letters.length}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.3,
        ),
      ],
    );
  }
}
