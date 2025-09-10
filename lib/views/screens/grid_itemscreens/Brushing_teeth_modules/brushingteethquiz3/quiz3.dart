import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz3controller.dart';

class Quiz3 extends StatefulWidget {
  Quiz3({super.key});

  @override
  State<Quiz3> createState() => _Quiz3State();
}

class _Quiz3State extends State<Quiz3> {
  final Quiz3answer answerController = Get.find<Quiz3answer>();
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize text controllers for all questions
    for (var question in answerController.answers.keys) {
      _textControllers[question] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all text controllers
    _textControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Scaled sizes
    final double imageSize = screenHeight * 0.06;
    final double textFieldSize = screenHeight * 0.06;
    final double fontSize = screenWidth * 0.04;
    final double horizontalPadding = screenWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.015;

    final List<String> allQuestions = answerController.answers.keys.toList();

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
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

          // Update controller text based on current state
          final currentText = answerController.userAnswers[question] ?? "";
          if (_textControllers[question]!.text != currentText &&
              !isPreFilled) {
            _textControllers[question]!.text = currentText;
          }

          if (isPreFilled && _textControllers[question]!.text != correctValue) {
            _textControllers[question]!.text = correctValue;
          }

          return Padding(
            padding: EdgeInsets.symmetric(vertical: verticalSpacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image
                if (imagePath.isNotEmpty)
                  Image.asset(
                    imagePath,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  )
                else
                  Icon(Icons.image, size: imageSize * 0.9),

                SizedBox(width: screenWidth * 0.03),

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
                  final isSubmitted = answerController.hasSubmitted.value;
                  
                  return SizedBox(
                    width: textFieldSize,
                    height: textFieldSize,
                    child: TextField(
                      enabled: !isPreFilled && !isSubmitted,
                      controller: _textControllers[question],
                      textAlign: TextAlign.center,
                      onChanged: (value) {
                        if (!isPreFilled && !isSubmitted) {
                          answerController.updateAnswer(question, value);
                        }
                      },
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
                        fillColor: _getFieldColor(isPreFilled, result),
                        contentPadding: EdgeInsets.zero,
                      ),
                      maxLength: 1, // Only allow single character input
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null, // Hide character counter
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

  Color _getFieldColor(bool isPreFilled, int? result) {
    if (isPreFilled) {
      return Colors.green.shade100;
    }
    
    if (result == null) {
      return Colors.white;
    }
    
    return result == 1 ? Colors.green.shade100 : Colors.red.shade100;
  }
}