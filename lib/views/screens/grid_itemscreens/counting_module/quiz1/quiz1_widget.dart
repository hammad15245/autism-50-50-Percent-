import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountingQuiz extends StatelessWidget {
  final CountingController controller = Get.put(CountingController());

  CountingQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

   
          // Progress
          Obx(() => Text(
              "Question ${controller.currentQuestion.value}/${controller.totalQuestions.value}",
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E83AD)))),
          SizedBox(height: 5),
          
          // Progress Bar
          Obx(() => LinearProgressIndicator(
            value: controller.currentQuestion.value / controller.totalQuestions.value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
          )),
          SizedBox(height: 10),
          
          // Question
          Obx(() => Text(
            controller.currentQuestionData["question"] ?? "Let's count!",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: 20),
          
          // Items to Count Grid
          _buildCountableItems(screenWidth, screenHeight),
          SizedBox(height: 10),
          
          _buildCounterSection(screenWidth, screenHeight),
          SizedBox(height: 10),
          
          // Action Buttons
          Align(
            alignment: Alignment.bottomCenter,
             child: Center(child: _buildActionButtons(screenWidth, screenHeight))),
        ],
      ),
    );
  }

  Widget _buildCountableItems(double screenWidth, double screenHeight) {
    return Obx(() => Container(
      height: screenHeight * 0.35,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!)
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(screenWidth * 0.03),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenHeight * 0.01,
          childAspectRatio: 1.0,
        ),
        itemCount: controller.getCurrentItems().length,
        itemBuilder: (context, index) {
          final item = controller.getCurrentItems()[index];
          return _buildCountableItem(item, screenWidth);
        },
      ),
    ));
  }

  Widget _buildCountableItem(Map<String, dynamic> item, double screenWidth) {
    return GestureDetector(
      onTap: controller.incrementCount,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[300]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2)
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              item["icon"],
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 4),
            Text(
              item["name"],
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection(double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.1),
        //     blurRadius: 4,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Text(
            "How many did you count?",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E83AD),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Decrement Button
              IconButton(
                onPressed: controller.decrementCount,
                icon: Icon(Icons.remove_circle, size: screenWidth * 0.08),
                color: Color(0xFF0E83AD),
              ),
              SizedBox(width: screenWidth * 0.05),
              
              // Count Display
              Obx(() => Container(
                width: screenWidth * 0.2,
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF0E83AD)),
                ),
                child: Text(
                  controller.currentCount.value.toString(),
                  style: TextStyle(
                    fontSize: screenWidth * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E83AD),
                  ),
                  textAlign: TextAlign.center,
                ),
              )),
              SizedBox(width: screenWidth * 0.05),
              
              // Increment Button
              IconButton(
                onPressed: controller.incrementCount,
                icon: Icon(Icons.add_circle, size: screenWidth * 0.08),
                color: Color(0xFF0E83AD),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(double screenWidth, double screenHeight) {
    return Obx(() {
      if (controller.showCompletion.value) {
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
         
            SizedBox(height:7),
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
      } else {
        return ElevatedButton(
          onPressed: controller.checkAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0E83AD),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
          ),
          child: Text(
            "Check Answer",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        );
      }
    });
  }
}