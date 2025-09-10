import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz2/quiz2_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz3/quiz3_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BathingSequenceQuiz extends StatelessWidget {
  final BathingSequenceController controller = Get.put(BathingSequenceController());

  BathingSequenceQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     IconButton(
          //       icon: Icon(
          //         Icons.lightbulb_outline,
          //         color: Colors.amber[700],
          //         size: screenWidth * 0.07,
          //       ),
          //       onPressed: _showHintDialog,
          //       tooltip: 'Get Hint',
          //     ),
          //   ],
          // ),
          
          SizedBox(height: 15),
          
          Text(
            "Put bathing steps in order",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 15),
          
          SizedBox(
            height: screenHeight * 0.55,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Obx(() => ReorderableListView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                onReorder: controller.reorderItems,
                children: [
                  for (int index = 0; index < controller.currentSequence.length; index++)
                    _buildSequenceItem(controller.currentSequence[index], index, screenWidth, screenHeight),
                ],
              )),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Check Button
          Obx(() => _buildActionButtons()),
          
          // Feedback and Continue Section
          Obx(() => controller.showCompletion.value 
              ? _buildFeedbackSection(context) 
              : const SizedBox()),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    
    return ElevatedButton(
      onPressed: controller.hasSubmitted.value ? null : controller.manualCheckSequence,
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.hasSubmitted.value ? Colors.grey : Color(0xFF0E83AD),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        controller.hasSubmitted.value ? "Checking..." : "Check Order",
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.only(top: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: controller.isSequenceCorrect.value ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: controller.isSequenceCorrect.value ? Colors.green.shade200 : Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Feedback Message
          Text(
            controller.isSequenceCorrect.value 
                ? "🎉 Perfect! You got the sequence right!" 
                : "Almost there! The order needs adjustment.",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: controller.isSequenceCorrect.value ? Colors.green.shade800 : Colors.orange.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenHeight * 0.01),
          
          // Additional Feedback
          Text(
            controller.isSequenceCorrect.value 
                ? "You've mastered the bathing sequence!" 
                : "Remember the correct bathing steps order.",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: controller.isSequenceCorrect.value ? Colors.green.shade600 : Colors.orange.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: screenHeight * 0.02),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Continue Button (only show if correct)
              if (controller.isSequenceCorrect.value)
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => CleanDirtyScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              
              // Try Again Button (show if incorrect or as alternative)
              ElevatedButton(
                onPressed: controller.retrySequence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isSequenceCorrect.value ? Colors.blue : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  controller.isSequenceCorrect.value ? "Practice Again" : "Try Again",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // // Show hint dialog
  // void _showHintDialog() {
  //   Get.dialog(
  //     AlertDialog(
  //       backgroundColor: Colors.white,
  //       title: Row(
  //         children: [
  //           Icon(Icons.lightbulb, color: Colors.amber),
  //           SizedBox(width: 10),
  //           Text("Hint ", style: TextStyle(fontWeight: FontWeight.bold)),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Remember the correct order for bathing:",
  //             style: TextStyle(fontWeight: FontWeight.w600),
  //           ),
  //           SizedBox(height: 10),
  //           for (int i = 0; i < controller.stepData.length; i++)
  //             Text(
  //               "${i + 1}. ${controller.stepData[i]["step"]}",
  //               style: TextStyle(fontSize: 14),
  //             ),
  //           SizedBox(height: 15),
  //           Text(
  //             "💡 Tip: Drag and drop the steps to put them in order!",
  //             style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF0E83AD)),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Get.back(),
  //           style: TextButton.styleFrom(
  //             backgroundColor: Color(0xFF0E83AD), 
  //             foregroundColor: Colors.white, 
  //             padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(20),
  //             ),
  //             elevation: 2,
  //             shadowColor: Colors.blue[300],
  //           ),
  //           child: Text(
  //             "Got it!",
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSequenceItem(Map<String, String> step, int index, double screenWidth, double screenHeight) {
    return Card(
      key: Key('${step["step"]}-$index'),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01), 
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            "${index + 1}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
              fontSize: screenWidth * 0.04,
            ),
          ),
        ),
        title: Text(
          step["step"]!,
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: step["description"] != null ? Text(
          step["description"]!,
          style: TextStyle(
            fontSize: screenWidth * 0.032, 
            color: Colors.grey[600],
          ),
        ) : null,
        trailing: Icon(
          Icons.drag_handle, 
          color: Colors.blue[300],
          size: screenWidth * 0.05, 
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: EdgeInsets.symmetric( 
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.005,
        ),
        onTap: () {
          // Speak step description when tapped
          controller.speakStepDescription(index);
        },
      ),
    );
  }
}