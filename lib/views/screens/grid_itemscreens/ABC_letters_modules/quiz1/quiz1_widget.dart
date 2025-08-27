import 'package:audioplayers/audioplayers.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/screen.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz1_controller.dart'; // your ABC letters controller

class AlphabetQuiz extends StatefulWidget {
  final List<String> options = ['A', 'B', 'C', 'D'];
  final String correctAnswer = 'A';

  AlphabetQuiz({super.key});


  @override
  State<AlphabetQuiz> createState() => _AlphabetQuizState();
}

class _AlphabetQuizState extends State<AlphabetQuiz> {
  final ConfettiController confettiController =
      ConfettiController(duration: const Duration(seconds: 2));


  final AlphabetQuizController controller =
      Get.put(AlphabetQuizController());





  @override
  void initState() {
    super.initState();
    final correctIndex = widget.options.indexOf(widget.correctAnswer);
    controller.correctIndex.value = correctIndex;
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void _handleAnswer(int index) {
    if (!controller.hasAnswered.value) {
      controller.selectAnswer(index);

      if (index == controller.correctIndex.value) {
        confettiController.play();
      }

    Future.delayed(const Duration(seconds: 5), () {
      Get.to(() => const Quiz2bubble());
    });
    }
  }

  @override
  Widget build(BuildContext context) {
                  Color buttonColor = const Color(0xFF0E83AD);

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
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
                        widget.correctAnswer,
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
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.black54,
                        size: 28,
                      ),
                      onPressed: () {
    controller.playLetter(AssetSource('lib/assets/letters/A.mp3'));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Options Grid using CustomElevatedButton and color logic
              Obx(
                () => GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 12,
                  children: List.generate(widget.options.length, (index) {
                              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  
                  backgroundColor: controller.getButtonColor(index),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
               onPressed: () => _handleAnswer(index),

                child: Text(widget.options[index]),
              );
                  }),
                ),
              ),
            ],
          ),
        ),

        // Confetti animation for correct answer
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
