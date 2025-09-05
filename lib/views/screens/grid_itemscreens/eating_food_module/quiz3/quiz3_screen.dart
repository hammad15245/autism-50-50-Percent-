import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/progressheaderquiz4_eatingfood.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz3/quiz3_widget.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';

import 'package:flutter/material.dart';


class HealthyChoicesscreen extends StatelessWidget {
  const HealthyChoicesscreen({super.key});
  
  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepProgressHeaderquiz4eating(
                  currentStep: 3, 
                  onBack: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 50),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Text(
                  "Clean & Dirty Sorting",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
            
HealthyChoicesQuiz(),              
              // SizedBox(height: screenHeight * 0.01),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 5.0),
              //   child: Align(
              //     alignment: Alignment.bottomCenter,
              //     child: SizedBox(
              //       width: screenWidth * 0.8,
              //       height: screenHeight * 0.08,
              //       child:  CustomElevatedButton(
              //         text: "Continue",
              //         onPressed: () {
              //           controller.checkAnswerAndNavigate();
              //         },
              //       )),
              //     ),
                
              // ),

              // Try Again Button (commented out as per your pattern)
              // Obx(() => controller.showCompletion.value
              //     ? ElevatedButton(
              //         onPressed: controller.resetQuiz,
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.orange,
              //           padding: EdgeInsets.symmetric(
              //             horizontal: screenWidth * 0.06,
              //             vertical: screenHeight * 0.02,
              //           ),
              //         ),
              //         child: Text(
              //           "Try Again",
              //           style: TextStyle(
              //             fontSize: screenWidth * 0.04,
              //             color: Colors.white,
              //           ),
              //         ),
              //       )
              //     : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}