import 'package:autism_fyp/views/screens/grid_itemscreens/wakeup_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WakeUpQuiz extends StatelessWidget {
  final WakeUpController controller = Get.put(WakeUpController());

  WakeUpQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with progress indicator
          Obx(() => Column(
                children: [
                  LinearProgressIndicator(
                    value: controller.currentSequence.length /
                        controller.correctSequence.length,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF0E83AD),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              )),
          const SizedBox(height: 24),

          // Available Steps Grid
          Text(
            "Available Steps:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          
          Obx(() => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: controller.displayedItems.map((step) {
              return GestureDetector(
                onTap: () => controller.addStep(step),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: const Color.fromARGB(255, 62, 162, 198),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        step["icon"]!,
                        height: 60,
                        width: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error_outline, color: Colors.red),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step["name"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),

          const SizedBox(height: 15),

          // Current Sequence
          Text(
            "Your Sequence:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey[300]!),
  ),
  child: Wrap(
    spacing: 8,
    runSpacing: 8,
    children: controller.currentSequence.isEmpty
        ? [
            const Text(
              "Tap steps above to build your sequence",
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          ]
        : controller.currentSequence.map((step) {
            return Chip(
              label: Text(
                step["name"]!,
                style: const TextStyle(
                  color: Colors.white, // White text color
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 62, 162, 198),
              deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white), // White delete icon
              onDeleted: () => controller.removeStep(step),
              // Remove labelStyle from here and put it in Text widget
            );
          }).toList(),
  ),
)),

          const SizedBox(height: 15),

          // Check Answer Button
          Obx(() => ElevatedButton(
                onPressed: controller.currentSequence.isNotEmpty ? controller.checkAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E83AD),
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
                  "Check Answer",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),

          const SizedBox(height: 20),

          // Feedback Section
          Obx(() {
            if (controller.currentSequence.isNotEmpty && controller.hasFeedback.value) {
              return Container(
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
                      : "❌ Oops! Wrong answer",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: controller.lastAnswerCorrect.value 
                        ? Colors.green[800] 
                        : Colors.orange[800],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),

          const SizedBox(height: 20),

          // Continue Button (if needed)
          Obx(() {
            if (controller.lastAnswerCorrect.value && controller.currentSequence.isNotEmpty) {
              return ElevatedButton(
                onPressed: () {
                  // Add your continue logic here
                  controller.checkAnswerAndNavigate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E83AD),
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
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }
}