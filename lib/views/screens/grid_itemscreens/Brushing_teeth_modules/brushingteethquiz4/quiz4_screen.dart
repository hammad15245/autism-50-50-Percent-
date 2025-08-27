import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5_screen.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz4Screen extends StatefulWidget {
  const Quiz4Screen({super.key});

  @override
  State<Quiz4Screen> createState() => _Quiz4ScreenState();
}

class _Quiz4ScreenState extends State<Quiz4Screen> {
  final Quiz4Controller controller = Get.put(Quiz4Controller(), permanent: true);

  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void checkAllAnswers() {
    controller.checkAnswers();

    debugPrint(
      "User score: ${controller.correctCount.value} / ${controller.correctPairs.length}",
    );

    // 🎉 Play confetti if all correct
    if (controller.correctCount.value == controller.correctPairs.length) {
      confettiController.play();
    }
  }
  
  void checkAllAnswersAndNavigate() {
    // answerController.checkAllAnswers();

   

    Future.delayed(const Duration(seconds: 5), () {
      Get.to(() =>  Quiz5Screen());
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                child: StepProgressHeader(
                  currentStep: 4,
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Match the correct pairs.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Stack(
                alignment: Alignment.center,
                children: [
                  Quiz4(
                    controller: controller,
                    leftImages: [
                      'lib/assets/quiz4_icon/left1.png',
                      'lib/assets/quiz4_icon/left2.png',
                      'lib/assets/quiz4_icon/left3.png',
                      'lib/assets/quiz4_icon/left4.png',
                      'lib/assets/quiz4_icon/left5.png',
                    ],
                    rightImages: [
                      'lib/assets/quiz4_icon/right1.png',
                      'lib/assets/quiz4_icon/right2.png',
                      'lib/assets/quiz4_icon/right3.png',
                      'lib/assets/quiz4_icon/right4.png',
                      'lib/assets/quiz4_icon/right5.png',
                    ],
                  ),
                  ConfettiWidget(
                    confettiController: confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                    ],
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.08,
                  child: CustomElevatedButton(
                    text: "Check Answers",
onPressed: () {
  checkAllAnswersAndNavigate();
  controller.isChecking.value = true;
  controller.checkAnswers();
  
},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
