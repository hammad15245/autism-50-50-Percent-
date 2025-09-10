import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz1/quiz1_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz1/quiz1_widget.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/step_progressquiz3.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz3screen extends StatelessWidget {
  const Quiz3screen({super.key});

  @override
  Widget build(BuildContext context) {
    final Quiz3answer controller = Get.put(Quiz3answer());
    final AvatarController avatarController = Get.find<AvatarController>(); // Changed to Get.find if already put elsewhere

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

              /// Progress header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepProgressHeader(
                  currentStep: 3,
                  onBack: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        /// Avatar
                        Obx(() {
                          final avatarPath = avatarController.avatarPath.value;
                          if (avatarPath.isEmpty) {
                            return const SizedBox(
                              height: 80,
                              width: 80,
                              child: CircularProgressIndicator(),
                            );
                          }
                          return Image.asset(
                            avatarPath,
                            height: screenHeight * 0.10,
                            width: screenWidth * 0.20,
                            fit: BoxFit.contain,
                          );
                        }),

                        const SizedBox(width: 16),

                        /// Instruction Text (sync with TTS)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => Text(
                                controller.instructionText.value, 
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Quiz Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Fill in the missing letters!",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

              /// Quiz Widget - FIXED: Make sure Quiz3 is properly imported and instantiated
              Center(child: Quiz3()), // Ensure Quiz3 is a StatelessWidget or properly handled
                     
              SizedBox(height: screenHeight * 0.04),
              
        
              
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.08,
                  child: Obx(() => CustomElevatedButton(
                    text: controller.hasSubmitted.value ? "Continue" : "Check Answers",
                    onPressed: () {
                      if (controller.hasSubmitted.value) {
                        // Navigate to next screen
                        // Get.to(() => NextScreen());
                      } else {
                        controller.checkAllAnswers();
                      }
                    },
                  )),
                ),
              ),
              
              SizedBox(height: screenHeight * 0.02),
              
              /// Retry Button for wrong answers
              Obx(() {
                if (controller.hasSubmitted.value && controller.correctCount.value < controller.answers.length) {
                  return Center(
                    child: SizedBox(
                      width: screenWidth * 0.6,
                      child: ElevatedButton(
                        onPressed: controller.retryQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Try Again"),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }
}