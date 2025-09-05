import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NumberMatchQuiz extends StatelessWidget {
  final NumberMatchController controller = Get.put(NumberMatchController());

  NumberMatchQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
    
          Text(
            "Tap the group that matches the number",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          
          // Progress
          Obx(() => Text(
            "Question ${controller.currentQuestion.value}/${controller.totalQuestions.value}",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E83AD),
            ),
          )),
          SizedBox(height: 5),
          Obx(() => LinearProgressIndicator(
            value: controller.currentQuestion.value / controller.totalQuestions.value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
          )),
          SizedBox(height: 10),
          
          Obx(() => _buildNumberCard(controller.currentNumber.value, screenWidth)),
          SizedBox(height: 10),
          
           _buildOptionsGrid(screenWidth, screenHeight),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Center(
              child: Obx(() => controller.showCompletion.value
                ? _buildCompletionButtons(screenWidth, screenHeight)
                : _buildNextButton(screenWidth, screenHeight)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberCard(int number, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF0E83AD), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        "$number",
        style: TextStyle(
          fontSize: screenWidth * 0.15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0E83AD),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(double screenWidth, double screenHeight) {
    return Obx(() {
      final options = List<Map<String, dynamic>>.from(controller.currentQuestionData["options"] ?? []);
      
      return Container(
        height: screenHeight * 0.2,
        child: GridView.builder(
          padding: EdgeInsets.all(screenWidth * 0.03),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: screenWidth * 0.03,
            mainAxisSpacing: screenHeight * 0.02,
            childAspectRatio: 0.9,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            return _buildOptionCard(options[index], index, screenWidth);
          },
        ),
      );
    });
  }

  Widget _buildOptionCard(Map<String, dynamic> option, int index, double screenWidth) {
    return GestureDetector(
      onTap: () => controller.checkAnswer(index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color:Color(0xFF0E83AD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              option["image"],
              width: screenWidth * 0.2,
              height: screenWidth * 0.2,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 8),
            Text(
              "${option["count"]} items",
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(double screenWidth, double screenHeight) {
    return ElevatedButton(
      onPressed: controller.nextQuestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0E83AD),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.02,
        ),
      ),
      child: Text(
        "Next Question",
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: Colors.white,
        ),
      ),
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
        SizedBox(height:5),
        Text(
          "Score: ${controller.score.value}/${controller.totalQuestions.value}",
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            color: Color(0xFF0E83AD),
          ),
        ),
        SizedBox(height:7),
        ElevatedButton(
          onPressed: controller.checkAnswerAndNavigate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0E83AD),
            // padding: EdgeInsets.symmetric(
            //   horizontal: screenWidth * 0.06,
            //   vertical: screenHeight * 0.02,
            // ),
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