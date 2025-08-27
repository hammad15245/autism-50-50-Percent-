import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz5_controller.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';

class Quiz5Screen extends StatelessWidget {
  final Quiz5Controller controller = Get.put(Quiz5Controller());

  Quiz5Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.06),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StepProgressHeader(
                  currentStep: 5,
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.10),
               const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Find the perfect for the pictures shown below.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Template image
              Obx(() {
                return Image.asset(
                  controller.templates[controller.selectedTemplate.value],
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                );
              }),

SizedBox(height: screenHeight * 0.06),

              // Options for the current template
          
           TemplateOptionsWidget(),


              SizedBox(height: screenHeight * 0.04),
             Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.08,
                  child: CustomElevatedButton(
                    text: "Next",
onPressed: () {

  
},
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
