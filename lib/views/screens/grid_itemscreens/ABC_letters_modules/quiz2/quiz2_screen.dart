
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_widget.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Quiz2bubble extends StatefulWidget {
  const Quiz2bubble({super.key});

  @override
  State<Quiz2bubble> createState() => _Quiz2bubbleState();
}

class _Quiz2bubbleState extends State<Quiz2bubble> {
    final BubbleQuizController controller = Get.put(BubbleQuizController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StepProgressHeader(
                currentStep: 2,
                onBack: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Find and Tap only A B C letters.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Use the enhanced BubbleQuizScreen widget
            Expanded(
              child: BubbleQuizScreen(),
            ),
            SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Align(
                  
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.08,
                    child: CustomElevatedButton(
                      text: "Next",
                      onPressed: controller.checkAnswerAndNavigate,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}