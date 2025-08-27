import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3_screen.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz2 extends StatefulWidget {
  const Quiz2({super.key});

  @override
  State<Quiz2> createState() => _Quiz2State();
}

class _Quiz2State extends State<Quiz2> {
  final ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 2));
  final List<String> options = [
    'Eating Breakfast',
    'Brushing his teeth',
    'Playing with toys',
    'Sleeping',
  ];

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
      Get.to(() => const Quiz3screen());
    });
  }
}
  

  final String correctAnswer = 'Brushing his teeth';

  final Quiz2answer answerController = Get.put(Quiz2answer());

  @override
  void initState() {
    super.initState();
    final correctIndex = options.indexOf(correctAnswer);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      answerController.initialize(options.length, correctIndex);
      
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() => GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 12,
            children: List.generate(options.length, (index) {
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

                child: Text(options[index]),
              );
            }),
          )),
    );
  }
}
