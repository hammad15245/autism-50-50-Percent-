import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmotionQuizWidget extends StatelessWidget {
  final EmotionChoiceQuizController controller = Get.put(EmotionChoiceQuizController());

  EmotionQuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Obx(() {
        final question = controller.questions[controller.currentQuestionIndex.value];
        final selectedId = controller.selectedOptionId.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Question Text with styled container
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF0E83AD), width: 2),
              ),
              child: Text(
                question["question"],
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E83AD),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Options Grid
            Wrap(
              spacing: screenWidth * 0.04,
              runSpacing: screenHeight * 0.03,
              alignment: WrapAlignment.center,
              children: question["options"].map<Widget>((option) {
                final isSelected = selectedId == option["id"];
                final isCorrect = option["isCorrect"] == true;

                return GestureDetector(
                  onTap: selectedId.isEmpty
                      ? () => controller.selectOption(option["id"])
                      : null,
                  child: Container(
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.grey[300]!,
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image
                            Center(
                              child: Container(
                                width: screenWidth * 0.25,
                                height: screenHeight * 0.15,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: AssetImage(option["image"]),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            
                            // Text
                            Text(
                              option["text"] ?? "",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Selection overlay
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: screenWidth * 0.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.04),

            // Feedback Text
            if (selectedId.isNotEmpty)
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: controller.lastAnswerCorrect.value 
                      ? Colors.green[50] 
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.lastAnswerCorrect.value 
                        ? Colors.green 
                        : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Text(
                  controller.lastAnswerCorrect.value
                      ? "✅ Great job! You got it right!"
                      : "❌ oops! Wrong answer",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: controller.lastAnswerCorrect.value 
                        ? Colors.green[800] 
                        : Colors.orange[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(height:20),

            // Continue Button (only shows on last question)
            if (controller.isLastQuestion && selectedId.isNotEmpty)
              ElevatedButton(
                onPressed: controller.checkAnswerAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0E83AD),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                 horizontal: screenWidth * 0.08,
      vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}