import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz2 extends StatefulWidget {
  const Quiz2({super.key});

  @override
  State<Quiz2> createState() => _Quiz2State();
}

class _Quiz2State extends State<Quiz2> {
  final BrushingTeethQuiz2Controller quizController =
      Get.put(BrushingTeethQuiz2Controller());

  @override
  void initState() {
    super.initState();
    quizController.initializeQuiz();
  }

  void _handleAnswer(int index) {
    quizController.selectAnswer(index);

    if (quizController.isCorrect.value) {
      Future.delayed(const Duration(seconds: 3), () {
        Get.to(() => const Quiz3screen());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
     
               GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quizController.options.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      return Obx(() {
                        final isAnswered = quizController.hasAnswered.value;
                        final isSelected = quizController.selectedIndex.value == index;
                        final isCorrectOption = quizController.correctIndex == index;

                        Color buttonColor = const Color(0xFF0E83AD);
                        if (isAnswered) {
                          if (isSelected && isCorrectOption) {
                            buttonColor = Colors.green;
                          } else if (isSelected && !isCorrectOption) {
                            buttonColor = Colors.red;
                          } else if (isCorrectOption) {
                            buttonColor = Colors.green;
                          } else {
                            buttonColor = Colors.blueGrey;
                          }
                        }

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: quizController.isButtonDisabled(index)
                              ? null
                              : () => _handleAnswer(index),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(quizController.options[index]),
                          ),
                        );
                      });
                    },
                  ),
              const SizedBox(height: 20),
              Obx(() {
                if (quizController.hasAnswered.value &&
                    !quizController.isCorrect.value) {
                  return ElevatedButton(
                    onPressed: quizController.retryQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Try Again"),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ),
        // Obx(() {
        //   if (quizController.showFeedback.value) {
        //     return Align(
        //       alignment: Alignment.topCenter,
        //       child: Padding(
        //         padding: const EdgeInsets.only(top: 80),
        //         child: AnimatedOpacity(
        //           opacity: quizController.showFeedback.value ? 1.0 : 0.0,
        //           duration: const Duration(milliseconds: 300),
        //           child: Icon(
        //             quizController.isCorrect.value
        //                 ? Icons.check
        //                 : Icons.close,
        //             color: quizController.isCorrect.value
        //                 ? Colors.green
        //                 : Colors.red,
        //             size: 80,
        //           ),
        //         ),
        //       ),
        //     );
        //   }
        //   return const SizedBox.shrink();
        // }),
      ],
    );
  }

}
