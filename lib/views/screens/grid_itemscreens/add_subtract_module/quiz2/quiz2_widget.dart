import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NumberLineWidget extends StatelessWidget {
  final NumberLineController controller = Get.put(NumberLineController());

  NumberLineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with Progress
          Obx(() => Column(
                children: [
                  LinearProgressIndicator(
                    value: (controller.currentQuestionIndex.value + 1) /
                        controller.questions.length,
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF0E83AD),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
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

          // Instruction Header
          Obx(() => Text(
                controller.currentQuestion["instruction"],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              )),
          const SizedBox(height: 20),

          // Math Problem Display
          Obx(() => Text(
                controller.currentProblem,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0E83AD),
                ),
              )),
          const SizedBox(height: 15),

          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Stack(
              children: [
                // Number Line
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(vertical: 57),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),

                // Numbers 0-10
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(11, (index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$index",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    );
                  }),
                ),

           Obx(() => Positioned(
  left: (controller.frogPosition.value / 10) * (screenWidth - 60), 
  bottom: 40,
  child: _buildFrogAnimation(),
)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.frogPosition.value > 0
                        ? () => controller.moveFrog(-1)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white,),
                    label: const Text("1 Step Back"),
                  ),
                  
                  const SizedBox(width: 10),
                  
                  
                  ElevatedButton.icon(
                    onPressed: controller.frogPosition.value < 10
                        ? () => controller.moveFrog(1)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 20, color: Colors.white,),
                    label: const Text("1 Step Forward"),
                  ),
                ],
              )),
          const SizedBox(height: 24),

          Obx(() => controller.showFeedback.value
              ? const SizedBox.shrink()
              : ElevatedButton.icon(
                  onPressed: controller.checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E83AD),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, size: 20, color: Colors.white,),
                  label: const Text(
                    "Check Answer",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )),
          const SizedBox(height: 5),

          
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
                          ? "✅ Hoooray! Frog reached the right number!"
                          : "❌ Oops! Frog needs to try again!",
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Next Challenge",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),

                    if (!controller.isCorrect.value)
                      ElevatedButton(
                        onPressed: () {
                          controller.showFeedback.value = false;
                          controller.resetCurrentQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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

  Widget _buildFrogAnimation() {
    return Image.asset(
      "lib/assets/add_sub_quiz/frog.gif", 
      width: 45,
      height: 45,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackFrog();
      },
    );
  }

  Widget _buildFallbackFrog() {
    return const Icon(
      Icons.emoji_nature,
      size: 50,
      color: Colors.green,
    );
  }
}