import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_widge.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class BathingSequenceScreen extends StatelessWidget {
  const BathingSequenceScreen({super.key});
  
  
  @override
  Widget build(BuildContext context) {

final BathingSequenceController controller = Get.put(BathingSequenceController());
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
                child: StepProgressHeader(
                  currentStep: 2,
                  onBack: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
            "Drag and drop to arrange the steps\nin the correct bathing order",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
            
              BathingSequenceQuiz(),
              
          
          
  SizedBox(height: screenHeight * 0.04),
       Padding(
  padding: const EdgeInsets.only(bottom: 5.0),
  child: Align(
    alignment: Alignment.bottomCenter,
    child: SizedBox(
      width: screenWidth * 0.8,
      height: screenHeight * 0.08,
      child:  CustomElevatedButton(
        text: "Continue",
        onPressed: () {
          controller.checkallanswerandnavigate();
        },
      )
    ),
  ),
),

    
    // Try Again Button
    // Obx(() => controller.showCompletion.value
    //     ? ElevatedButton(
    //         onPressed: controller.resetSequence,
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



  