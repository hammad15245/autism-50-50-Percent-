import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz1/quiz1_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz1/quiz1_widget.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class BathTimeItemsScreen extends StatelessWidget {
  const BathTimeItemsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final BathingItemsController controller = Get.put(BathingItemsController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView( // MOVE SingleChildScrollView HERE
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepProgressHeader(
                  currentStep: 1,
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select your answers from the images.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            
              BathTimeItemsQuiz(),
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
                       onPressed: controller.manualNextQuestion,
                    ),
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