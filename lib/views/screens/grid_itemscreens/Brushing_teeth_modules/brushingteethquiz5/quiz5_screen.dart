import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';

import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz5Screen extends StatelessWidget {
  const Quiz5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final Quiz5Controller controller = Get.put(Quiz5Controller());
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
                  currentStep: 5,
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
                  "Find the perfect for the pictures shown below",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
                   SizedBox(height: screenHeight * 0.02),

              // Template image
              Obx(() {
                return Center(
                  child: Image.asset(
                    controller.templates[controller.selectedTemplate.value],
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                );
              }),

SizedBox(height: screenHeight * 0.06),


              /// Quiz Widget - FIXED: Make sure Quiz3 is properly imported and instantiated
             TemplateOptionsWidget(), // Ensure Quiz3 is a StatelessWidget or properly handled
                     
              SizedBox(height: screenHeight * 0.04),
              
             Center(
                    child: SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.08,
                      child: CustomElevatedButton(
                        text: "Continue",
                 onPressed: () {
                 
                   
                 },
                 
                      ),
                    ),
                  
               
             ),
                           SizedBox(height:20),

            ],
          ),
        ),
      ),
    );
  }
}