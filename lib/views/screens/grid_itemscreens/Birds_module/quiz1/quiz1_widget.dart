import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BirdSoundWidget extends StatelessWidget {
  final birdcontroller controller = Get.put(birdcontroller());

  BirdSoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Progress Header
          Obx(() => Column(
                children: [
                  LinearProgressIndicator(
                    value: (controller.currentQuestionIndex.value + 1) /
                        controller.questions.length,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF0E83AD),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 16),

  

          ElevatedButton.icon(
            onPressed: controller.playQuestionSound,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E83AD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.volume_up, size: 24, color: Colors.white,),
            label: const Text(
              "Play Sound Again",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 15),

          // Bird Options Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: controller.currentQuestion["options"].length,
                  itemBuilder: (context, index) {
                    final bird = controller.currentQuestion["options"][index];
                    final isSelected = controller.selectedBird.value == bird["id"];
                    final isCorrectChoice = bird["id"] == controller.currentQuestion["correctBird"];
            
                    return GestureDetector(
                      onTap: controller.showFeedback.value
                          ? null
                          : () => controller.checkAnswer(bird["id"]),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (controller.isCorrect.value ? Colors.green : Colors.red)
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
                              bird["icon"],
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error, size: 40),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bird["name"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (controller.isCorrect.value ? Colors.green : Colors.red)
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          const SizedBox(height: 24),

          // Feedback Section
          Obx(() {
            if (controller.showFeedback.value) {
              return Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: controller.isCorrect.value
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: controller.isCorrect.value ? Colors.green : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      controller.isCorrect.value
                          ? "✅ Excellent! That's the ${controller.currentQuestion["correctBird"]}!"
                          : "❌ Try again! Listen carefully to the sound.",
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
                    
                    if (controller.isCorrect.value && !controller.isLastQuestion)
                      ElevatedButton(
                        onPressed: controller.nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E83AD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Next Bird Sound",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                    if (!controller.isCorrect.value)
                      ElevatedButton(
                        onPressed: controller.retryQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Try Again",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                    if (controller.isCorrect.value && controller.isLastQuestion)
                      ElevatedButton(
                        onPressed: controller.checkAnswerAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E83AD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
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