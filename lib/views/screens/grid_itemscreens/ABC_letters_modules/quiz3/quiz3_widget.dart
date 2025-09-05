import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindAlphabetQuiz extends StatelessWidget {
  final List<String> targetLetters;
  final String imagePath;
  final List<Map<String, dynamic>> hiddenLetters;

  FindAlphabetQuiz({
    super.key,
    required this.targetLetters,
    required this.imagePath,
    required this.hiddenLetters,
  });

  final FindLetterController controller = Get.put(FindLetterController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        
        // Calculate responsive values
        final topPadding = screenHeight * 0.06;
        final horizontalPadding = screenWidth * 0.05;
        final infoBoxPadding = screenWidth * 0.03;
        final infoBoxFontSize = screenWidth * 0.06;
        final progressFontSize = screenWidth * 0.045;
        final letterFontSize = screenWidth * 0.06;
        final letterPadding = screenWidth * 0.03;
        final letterBorderWidth = screenWidth * 0.005;
        final shadowBlur = screenWidth * 0.015;

        // Set the target letters when quiz starts
        controller.targetLetters.value = targetLetters;
        controller.targetLetter.value = targetLetters[0];

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),

              // Target letter to find
              Positioned(
                top: topPadding,
                left: horizontalPadding,
                child: Container(
                  padding: EdgeInsets.all(infoBoxPadding),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Text(
                        "Find: ${controller.targetLetter.value}",
                        style: TextStyle(
                          fontSize: infoBoxFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                ),
              ),

              // Progress indicator with Collected text
              Positioned(
                top: topPadding,
                right: horizontalPadding,
                child: Container(
                  padding: EdgeInsets.all(infoBoxPadding),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Collected:",
                        style: TextStyle(
                          fontSize: progressFontSize * 0.8,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "${controller.allCollectedLetters.length}/${controller.targetLetters.length}",
                        style: TextStyle(
                          fontSize: progressFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )),
                ),
              ),

              // Hidden letters
              ...hiddenLetters.map((item) {
                final topPosition = (item["top"] / 800) * screenHeight;
                final leftPosition = (item["left"] / 400) * screenWidth;

                return Positioned(
                  top: topPosition,
                  left: leftPosition,
                  child: GestureDetector(
                    onTap: () {
                      controller.onLetterTapped(item["letter"]);
                    },
                    child: Obx(() {
                      bool isCorrectlyCollected = controller.correctlyCollectedLetters.contains(item["letter"]);
                      bool isTemporarilyIncorrect = controller.temporarilyIncorrectLetters.contains(item["letter"]);
                      
                      Color bubbleColor;
                      
                      if (isCorrectlyCollected) {
                        bubbleColor = Colors.green.withOpacity(0.8);
                      } else if (isTemporarilyIncorrect) {
                        bubbleColor = Colors.red.withOpacity(0.8);
                      } else {
                        bubbleColor = Colors.white.withOpacity(0.7);
                      }
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(letterPadding),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: shadowBlur,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.black.withOpacity(0.3),
                            width: letterBorderWidth,
                          ),
                        ),
                        child: Text(
                          item["letter"],
                          style: TextStyle(
                            fontSize: letterFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}