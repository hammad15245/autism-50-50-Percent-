import 'package:autism_fyp/views/controllers/quizresult_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushing_teethquiz1.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushingteeth_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz2/screen.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrushingteethScreen extends StatefulWidget {
  const BrushingteethScreen({super.key});

  @override
  State<BrushingteethScreen> createState() => _BrushingteethScreenState();
}

class _BrushingteethScreenState extends State<BrushingteethScreen> {
  final AnswerController answerController = Get.put(AnswerController());
  final brushingController = BrushingTeethController.instance;

final ConfettiController confettiController =
    ConfettiController(duration: const Duration(seconds: 2));

  @override
  void initState() {
    super.initState();
    // confettiController =
    //     ConfettiController(duration: const Duration(seconds: 2));

    // Listen for answer changes to trigger animations
    ever(answerController.hasAnswered, (answered) {
      if (answered == true) {
        if (answerController.isCorrectAnswer()) {
          confettiController.play();
        }
      }
    });
void _handleAnswer(int index) {
  if (!answerController.hasAnswered.value) {
    answerController.selectAnswer(index);

    bool correct = answerController.isCorrectAnswer();
    if (correct) {
      confettiController.play();
    }

    // ✅ Update the total score in Firebase
    QuizScoreService().updateTotalScoreByEmail(isCorrect: correct);

    // Delay and go to next screen
    Future.delayed(const Duration(seconds: 5), () {
      Get.to(() => const Quiz2screen());
    });
  }
}


  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.06),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    StepProgressHeader(
                      currentStep: 1,
                      onBack: () => Navigator.pop(context),
                    ),
                  
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'What does this picture refer to?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),

              // ✅ Image with animations overlay
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/learning_module_ASSETS/toothbrush.png',
                      height: screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),

                    // 🎉 Confetti animation for correct answer
                    ConfettiWidget(
                      confettiController: confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      emissionFrequency: 0.05,
                      numberOfParticles: 20,
                      gravity: 0.3,
                    ),

                    // Cross animation for wrong answer
                    Obx(() {
                      if (answerController.showFeedback.value &&
                          !answerController.isCorrectAnswer()) {
                        return AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 300),
                          child:
                              const Icon(Icons.close, color: Colors.red, size: 150),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              Center(
                child: BrushingTeethQuiz(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
