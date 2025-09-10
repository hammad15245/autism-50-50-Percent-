import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';

class BathTimeItemsQuiz extends StatelessWidget {
  final BathingItemsController controller = Get.put(BathingItemsController());

  BathTimeItemsQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress indicator
          Obx(() => LinearProgressIndicator(
            value: (controller.currentIndex.value + 1) / controller.bathingItems.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
          )),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Question
          Obx(() => Text(
            (controller.bathingItems[controller.currentIndex.value]["question"] as String?) ?? "Question",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          )),
          
          SizedBox(height:20),
          
          Obx(() {
            String imagePath = (controller.bathingItems[controller.currentIndex.value]["image"] as String?) ?? "";
            return Container(
              height: 200,
              width:  200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            );
          }),
          
          SizedBox(height: 15),
          
          // Options buttons
          Obx(() {
            List<String> options = (controller.bathingItems[controller.currentIndex.value]["options"] as List<String>?) ?? [];
            
            return GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 12,
              padding: EdgeInsets.all(screenWidth * 0.03),
              children: List.generate(options.length, (index) {
                return _buildGridButton(options[index], index, screenWidth);
              }),
            );
          }),
          
          SizedBox(height: screenHeight * 0.03),
          
          Obx(() {
            if (controller.currentIndex.value == controller.bathingItems.length - 1 && 
                controller.hasSubmitted.value) {
              return _buildCompletionFeedback(context);
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

  Widget _buildGridButton(String option, int index, double screenWidth) {
    return Obx(() {
      bool isSelected = controller.selectedAnswer.value == option;
      bool showFeedback = controller.showFeedback.value;
      
      String correctAnswer = (controller.bathingItems[controller.currentIndex.value]["correctAnswer"] as String?) ?? "";
      bool isCorrect = option == correctAnswer;
      
      Color buttonColor = const Color(0xFF0E83AD);
      Color textColor = Colors.white;
      
      if (showFeedback) {
        if (isSelected) {
          buttonColor = isCorrect ? Colors.green : Colors.red;
        } else if (isCorrect) {
          buttonColor = Colors.green;
        }
      }
      
      return CustomElevatedButton(
        text: option,
        onPressed: () {
          if (!controller.showFeedback.value) {
            controller.checkAnswer(option);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  Widget _buildCompletionFeedback(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200, width: 2),
      ),
      child: Column(
        children: [
          Text(
            "Quiz Completed! 🎉",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          
   
  
          
          SizedBox(height: 10),
          
          SizedBox(
            width: screenWidth * 0.5,
            child: CustomElevatedButton(
              text: "Continue",
              onPressed: () {
                controller.manualNextQuestion();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0E83AD),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: screenWidth * 0.04,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.01),
          
          // Retry Button (if needed)
          Obx(() {
            if (controller.score.value < controller.bathingItems.length * 0.7) {
              return SizedBox(
                width: screenWidth * 0.5,
                child: TextButton(
                  onPressed: controller.retryQuiz,
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }

 
}