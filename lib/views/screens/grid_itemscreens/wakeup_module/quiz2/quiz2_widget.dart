import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz2_controller.dart';

class MatchSoundWidget extends StatelessWidget {
  final MatchSoundController controller = Get.put(MatchSoundController());

  MatchSoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with progress
          Obx(() => Column(
                children: [
             
                  LinearProgressIndicator(
                    value: (controller.currentQuestionIndex.value + 1) /
                        controller.quizQuestions.length,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF0E83AD),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Question ${controller.currentQuestionIndex.value + 1} of ${controller.quizQuestions.length}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )),
          // const SizedBox(height: 15),

          // Play Sound Button
          // Obx(() => ElevatedButton.icon(
          //       onPressed: controller.playSound,
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: controller.PlayingSound.value
          //             ? Colors.orange
          //             : const Color(0xFF0E83AD),
          //         foregroundColor: Colors.white,
          //         padding:
          //             const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //       ),
          //       icon: Icon(
          //         controller.isPlayingSound.value
          //             ? Icons.volume_up
          //             : Icons.play_arrow,
          //         size: 24,
          //       ),
            
          //     )),
          const SizedBox(height: 25),

          // Options Grid
          Obx(() {
            final currentQuestion = controller.currentQuestion;
            return Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children:
                  (currentQuestion["options"] as List<dynamic>).map((option) {
                final optionMap = option as Map<String, dynamic>;
                final isSelected =
                    controller.selectedAnswer.value == optionMap["id"];

                return GestureDetector(
                  onTap: controller.showFeedback.value
                      ? null
                      : () => controller.checkAnswer(optionMap["id"]),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? (controller.isCorrect.value
                                ? Colors.green
                                : Colors.red)
                            : const Color.fromARGB(255, 62, 162, 198),
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          optionMap["icon"],
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 80,
                              width: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error_outline,
                                  color: Colors.red, size: 30),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          optionMap["name"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? (controller.isCorrect.value
                                    ? Colors.green
                                    : Colors.red)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 32),

          // Feedback Section
          Obx(() {
            if (!controller.showFeedback.value) return const SizedBox.shrink();

            return Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: controller.isCorrect.value
                    ? Colors.green[50]
                    : Colors.orange[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: controller.isCorrect.value
                      ? Colors.green
                      : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    controller.isCorrect.value
                        ? "✅ Great listening! That's correct!"
                        : "❌ Try again! Listen carefully",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: controller.isCorrect.value
                          ? Colors.green[800]
                          : Colors.orange[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: controller.nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E83AD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      controller.isLastQuestion ? "Continue" : "Next Sound",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),

        ],
      ),
    );
  }
}
