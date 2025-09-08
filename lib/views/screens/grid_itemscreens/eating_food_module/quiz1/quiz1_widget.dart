import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FoodIdentificationQuiz extends StatelessWidget {
  final FoodIdentificationController controller =
      Get.put(FoodIdentificationController());

  FoodIdentificationQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(screenWidth),
          SizedBox(height: 10),

          // Progress bar
Obx(() => LinearProgressIndicator(
      value: (controller.currentQuestion.value + 1) /
          controller.totalQuestions.value, 
      backgroundColor: Colors.grey[300],
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
)),

SizedBox(height: 10),

// Question number
Obx(() => Text(
      "Question ${controller.currentQuestion}/${controller.totalQuestions.value}",
      style: TextStyle(
        fontSize: screenWidth * 0.040,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0E83AD),
      ),
)),

     
          SizedBox(height: 10),

          // Food image
          _buildFoodImage(screenWidth, screenHeight),
          SizedBox(height: 20),

          // Options grid
         Obx(() => _buildOptionsGrid(screenWidth)),
          SizedBox(height: 20),
         Obx(() => controller.showCompletion.value
    ? _buildCompletionButtons(screenWidth, screenHeight)
    : const SizedBox.shrink(),
),

        ],
      ),
    );
  }


  Widget _buildHeader(double screenWidth) {
    return Column(
      children: [
    
        Text(
          "What is this food?",
          style: TextStyle(
            fontSize: screenWidth * 0.047,
            color: Color(0xFF0E83AD),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFoodImage(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.55,
      height: screenWidth * 0.55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
       
      ),
      child: Obx(() {
        if (controller.currentQuestionData.isNotEmpty) {
          return Image.asset(
            controller.currentQuestionData["image"],
            fit: BoxFit.contain,
          );
        }
        return const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget _buildOptionsGrid(double screenWidth) {
  if (controller.currentQuestionData.isEmpty) return const SizedBox();

  final options = List<String>.from(controller.currentQuestionData["options"] ?? []);

  return GridView.count(
    crossAxisCount: 2,
    childAspectRatio: 2.5,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 10,
    crossAxisSpacing: 12,
    children: List.generate(options.length, (index) {
      final option = options[index];

      return Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              backgroundColor: controller.getButtonColor(index),
              foregroundColor: Colors.white,
              textStyle: TextStyle(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: controller.isAnswering.value
                ? null
                : () => controller.checkAnswer(option, index),
            child: Text(option, textAlign: TextAlign.center),
          ));
    }),
  );
}



  Widget _buildCompletionButtons(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          "Quiz Completed! 🎓",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        //       SizedBox(height: 8),
        // Obx(() => Text(
        //       "Score: ${controller.score.value}/${controller.totalQuestions.value}",
        //       style: TextStyle(
        //         fontSize: screenWidth * 0.045,
        //         color: Colors.orange[800],
        //       ),
        //     )),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: controller.checkAnswerAndNavigate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0E83AD),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
          ),
          child: Text(
            "Continue",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
