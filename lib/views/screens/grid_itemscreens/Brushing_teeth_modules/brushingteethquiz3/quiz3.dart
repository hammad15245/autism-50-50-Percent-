import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz3controller.dart';

class Quiz3 extends StatelessWidget {
  Quiz3({super.key});

  final Quiz3answer answerController = Get.find<Quiz3answer>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scaled sizes
    final double imageSize = screenHeight * 0.06; // 6% of height
    final double textFieldSize = screenHeight * 0.06;
    final double fontSize = screenWidth * 0.04; // Adjust font size based on width
    final double horizontalPadding = screenWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.015;

    final List<String> allQuestions = answerController.answers.keys.toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06,vertical: screenHeight * 0.02),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 234, 239, 243),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: allQuestions.map((question) {
          final String imagePath = answerController.images[question] ?? "";
          final bool isPreFilled =
              answerController.preFilledQuestions.contains(question);
          final String correctValue = answerController.answers[question] ?? "";

          return Padding(
            padding: EdgeInsets.symmetric(vertical: verticalSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.contain,
                      )
                    : Icon(Icons.image, size: imageSize * 0.9),

                SizedBox(width: screenWidth * 0.03),

                // Question text
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                // Answer field
                Obx(() {
                  final result = answerController.resultMap[question]?.value;
                  return SizedBox(
                    width: textFieldSize,
                    height: textFieldSize,
                    child: TextField(
                      enabled: !isPreFilled,
                      controller: TextEditingController(
                        text: isPreFilled
                            ? correctValue
                            : (answerController.userAnswers[question] ?? ""),
                      ),
                      textAlign: TextAlign.center,
                      onChanged: (value) =>
                          answerController.updateAnswer(question, value),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isPreFilled
                            ? Colors.green.shade100
                            : (result == null
                                ? Colors.white
                                : (result == 1
                                    ? Colors.green.shade100
                                    : Colors.red.shade100)),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
