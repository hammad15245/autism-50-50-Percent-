

import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';

import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz4Screen extends StatelessWidget {
  const Quiz4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final Quiz4Controller controller = Get.put(Quiz4Controller());
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
                  currentStep: 4,
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
                  "Match the correct pairs.",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.01),

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
                     
              SizedBox(height: screenHeight * 0.04),
              
        
              
        Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.08,
          child: Obx(() {
            // Show Retry if user has checked answers and not all are correct
            if (controller.isChecking.value && controller.correctCount.value < 5) {
              return CustomElevatedButton(
                text: "Retry",
                onPressed: () {
                  controller.resetQuiz();
                  controller.isChecking.value = false;
                },
              );
            } else {
              // Show Check Answers button if not checked yet or all are correct
              return CustomElevatedButton(
                text: "Check Answers",
                onPressed: () {
                  controller.isChecking.value = true;
                  controller.checkAnswers();
                },
              );
            }
          }),    
        ),
        ),

              
            ],
          ),
        ),
      ),
    );
  }
}