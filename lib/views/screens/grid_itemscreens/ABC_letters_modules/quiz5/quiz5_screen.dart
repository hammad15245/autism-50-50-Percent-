import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SoundRecognitionScreen extends StatelessWidget {
  const SoundRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
  final SoundRecognitionController controller = Get.put(SoundRecognitionController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.04),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StepProgressHeader(
                currentStep: 4, 
                onBack: () => Navigator.pop(context),
              ),
            ),
                  Padding(
                    padding: const EdgeInsets.only(right: 17.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                                      onPressed: controller.skipQuestion,
                                      child: const Text(
                      "Skip",
                      style: TextStyle(fontSize: 17, color: Color(0xFF0E83AD)),
                                      ),
                                    ),
                    ),
                  ),
              
              SizedBox(height: screenHeight * 0.10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Listen to the beginning sounds',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                ),
        
            
            // SizedBox(height:2),
            Expanded(
              child: SoundRecognitionQuiz(),
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
                      text: "Continue",
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