import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/screen.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'brushingteeth_controller.dart';

class BrushingTeethQuiz extends StatefulWidget {
  final List<String> options = ['Toothbrush', 'Spoon', 'Comb', 'Towel'];
  final String correctAnswer = 'Toothbrush';

  BrushingTeethQuiz({super.key});

  @override
 
  State<BrushingTeethQuiz> createState() => _BrushingTeethQuizState();
}

class _BrushingTeethQuizState extends State<BrushingTeethQuiz> {
  
  
final ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 2));

  final AnswerController answerController = Get.put(AnswerController());

  @override
  void initState() {
    super.initState();
    final correctIndex = widget.options.indexOf(widget.correctAnswer);
    answerController.initialize(widget.options.length, correctIndex);
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

void _handleAnswer(int index) {
  if (!answerController.hasAnswered.value) {
    answerController.selectAnswer(index);

    if (answerController.isCorrectAnswer()) {
      confettiController.play();
    }

    // Wait for animations to play, then navigate
    Future.delayed(const Duration(seconds: 5), () {
      Get.to(() => const Quiz2screen());
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Obx(() => GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 12,
               children: List.generate(widget.options.length, (index) {
              final isAnswered = answerController.hasAnswered.value;
              final isSelected = answerController.selectedIndex.value == index;
              final isCorrect = answerController.correctIndex == index;

              Color buttonColor = const Color(0xFF0E83AD);
              if (isAnswered) {
                if (isSelected && isCorrect) {
                  buttonColor = Colors.green;
                } else if (isSelected && !isCorrect) {
                  buttonColor = Colors.red;
                } else if (isCorrect) {
                  buttonColor = Colors.green;
                } else {
                  buttonColor = Colors.blueGrey;
                }
              }

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
               onPressed: () => _handleAnswer(index),

                child: Text(widget.options[index]),
              );
            }),
              )),
        ),

// // confetti animation for correct answer
//         ConfettiWidget(
//           confettiController: confettiController,
//           blastDirectionality: BlastDirectionality.explosive,
//           shouldLoop: false,
//           emissionFrequency: 0.05,
//           numberOfParticles: 20,
//           gravity: 0.3,
//         ),

//         // Cross animation for wrong answer
//         Obx(() {
//           if (answerController.showFeedback.value &&
//               !answerController.isCorrectAnswer()) {
//             return AnimatedOpacity(
//               opacity: 1,
//               duration: const Duration(milliseconds: 300),
//               child: Icon(Icons.close, color: Colors.red, size: 100),
//             );
//           }
//           return const SizedBox.shrink();
//         }),
      ],
    );
  }
}
