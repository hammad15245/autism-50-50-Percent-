
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz5/quiz5_widget.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz1/quiz1_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz1/quiz1_widget.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/step_progressquiz3.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:get/get.dart';

class countbathitems extends StatelessWidget {
  const countbathitems({super.key});
  
  @override
  Widget build(BuildContext context) {
    Get.lazyPut<CountingController>(() => CountingController());

    // final CountingController controller = Get.find<CountingController>();
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
                child: StepProgressHeaderquiz3(
                  currentStep: 1, 
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Count the Bath Items",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
            
              CountingQuiz(), 
              
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