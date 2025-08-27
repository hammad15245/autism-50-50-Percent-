import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';

class BubbleQuizScreen extends StatefulWidget {
  const BubbleQuizScreen({Key? key}) : super(key: key);

  @override
  State<BubbleQuizScreen> createState() => _BubbleQuizScreenState();
}

class _BubbleQuizScreenState extends State<BubbleQuizScreen> {
  final BubbleQuizController controller = Get.put(BubbleQuizController());
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    controller.initializeAnswers();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    controller.selectAnswer(index);

    if (controller.isCorrectAnswer(index)) {
      confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: size.width * 0.04,
              mainAxisSpacing: size.height * 0.03,
            ),
            itemCount: controller.options.length,
            itemBuilder: (context, index) {
              return Obx(() {
                final answer = controller.answers[index];
                return GestureDetector(
                  onTap: () => _handleTap(index),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.primaries[
                                  index % Colors.primaries.length]
                              .shade300,
                        ),
                        child: Center(
                          child: Text(
                            controller.options[index],
                            style: TextStyle(
                              fontSize: size.width * 0.1,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (answer == false)
                        const Icon(Icons.close,
                            color: Colors.red, size: 40),
                    ],
                  ),
                );
              });
            },
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }
}
