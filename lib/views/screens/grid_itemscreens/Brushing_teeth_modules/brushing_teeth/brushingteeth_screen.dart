
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushing_teethquiz1.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushingteeth_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';

import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/step_progressquiz3.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BrushingteethScreen extends StatelessWidget {
  const BrushingteethScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BrushingTeethQuiz1Controller controller = Get.put(BrushingTeethQuiz1Controller());
    final AvatarController avatarController = Get.put(AvatarController());

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
                  currentStep: 1,
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
                  "What do we use for brushing teeth?",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
SizedBox(height: screenHeight * 0.04),

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/learning_module_ASSETS/toothbrush.png',
                      height: screenHeight * 0.3,
                      fit: BoxFit.contain,
                    ),

              
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),

              /// Quiz Widget
               Center(child: BrushingTeethQuiz()),
            ],
          ),
        ),
      ),
    );
  }
}
