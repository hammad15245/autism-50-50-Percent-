import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BedtimeQuiz extends StatelessWidget {
  final BedtimeController controller = Get.put(BedtimeController());

  BedtimeQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // OPTIONS (Steps to Select)
          LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double itemWidth = screenWidth / 2 - 20;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: controller.correctSequence.map((step) {
                  return GestureDetector(
                    onTap: () => controller.addStep(step),
                    child: Container(
                      width: itemWidth,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black54, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(step["icon"]!,
                              height: screenWidth * 0.1,
                              width: screenWidth * 0.1),
                          const SizedBox(height: 8),
                          Text(
                            step["name"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          // SHOW CURRENT SELECTION
          Obx(() => Column(
                children: [
                  const Text(
                    "Your Order:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.currentSequence.map((step) {
                      return GestureDetector(
                        onTap: () => controller.removeStep(step),
                        child: Chip(
                          avatar: Image.asset(step["icon"]!,
                              height: 24, width: 24),
                          label: Text(step["name"]!),
                          backgroundColor: Colors.green.shade100,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              )),

          const SizedBox(height: 20),

          // ✅ RESULT / RETRY / CONTINUE BUTTONS
          Obx(() {
            if (controller.currentSequence.length ==
                controller.correctSequence.length) {
              bool isCorrect = controller.checkAnswer();

              return Column(
                children: [
                  Text(
                    isCorrect
                        ? "✅ Great job! Correct Order."
                        : "❌ Wrong! Try again.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Show Correct button only if answer is right
                  if (isCorrect)
                    ElevatedButton(
                      onPressed: () => controller.checkAnswerAndNavigate(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0E83AD),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  // Show Retry button if answer is wrong
                  if (!isCorrect)
                    ElevatedButton(
                      onPressed: () => controller.resetQuiz(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Retry",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              );
            }
            return const SizedBox.shrink();
          })
        ],
      ),
    );
  }
}
