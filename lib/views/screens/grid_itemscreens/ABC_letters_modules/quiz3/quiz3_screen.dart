
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_widget.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_widget.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Quiz3Screen extends StatefulWidget {
  const Quiz3Screen({super.key});

  @override
  State<Quiz3Screen> createState() => _Quiz3ScreeneState();
}

class _Quiz3ScreeneState extends State<Quiz3Screen> {
    final FindLetterController controller = Get.put(FindLetterController());

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
                currentStep: 3,
                onBack: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Find A B C Letters from the picture.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Use the enhanced BubbleQuizScreen widget
           // In your Quiz3Screen, update the FindAlphabetQuiz widget usage:
Expanded(
  child: FindAlphabetQuiz(
    targetLetters: ['A', 'B', 'C', 'D', 'E', 'F'],
    imagePath: 'lib/assets/quiz3picture.jpg', 
    hiddenLetters: [
      {"letter": "A", "top": 45.0, "left": 180.0},
      {"letter": "B", "top": 250.0, "left": 100.0},
      {"letter": "C", "top": 500.0, "left": 250.0},
      {"letter": "D", "top": 400.0, "left": 20.0},
      {"letter": "E", "top": 300.0, "left": 200.0},
      {"letter": "F", "top": 300.0, "left": 350.0},
    ],
  ),
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