import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz3screen extends StatefulWidget {
  const Quiz3screen({super.key});

  @override
  State<Quiz3screen> createState() => _Quiz3screenState();
}

class _Quiz3screenState extends State<Quiz3screen> {
  final Quiz3answer answerController = Get.put(Quiz3answer(), permanent: true);
  late ConfettiController confettiController;

  @override
  void initState() {
    super.initState();
    confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void checkAllAnswersAndNavigate() {
    answerController.checkAllAnswers();

   

    Future.delayed(const Duration(seconds: 5), () {
      Get.to(() => const Quiz4Screen());
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
                  currentStep: 3,
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Fill in the following blanks.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Stack(
                alignment: Alignment.center,
                children: [
                  Quiz3(),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.08,
                  child: CustomElevatedButton(
                    text: "Next",
                    onPressed: checkAllAnswersAndNavigate,
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
