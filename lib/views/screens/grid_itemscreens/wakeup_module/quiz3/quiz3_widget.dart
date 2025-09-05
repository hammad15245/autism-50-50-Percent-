import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/wakeup_module/quiz3/quiz3_controller.dart';

class BreakfastSortingWidget extends StatelessWidget {
  final BreakfastSortingController controller =
      Get.put(BreakfastSortingController());

  BreakfastSortingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// ✅ Dynamic Question Header
          Obx(() {
            final questionText = controller.questions[controller.currentQuestionIndex.value]["question"];
            return Column(
              children: [
                Text(
                  questionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),

                LinearProgressIndicator(
                  value: (controller.currentQuestionIndex.value + 1) /
                      controller.totalQuestions.value,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF0E83AD),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 8),

                Text(
                  "Question ${controller.currentQuestionIndex.value + 1} of ${controller.totalQuestions.value}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          Obx(() => Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: controller.currentFoodItems.map((food) {
                  final isSelected = controller.selectedItems.contains(food);
                  final isHealthy = food["isHealthy"] == true;

                  final borderColor = isSelected
                      ? (controller.showFeedback.value
                          ? (isHealthy ? Colors.green : Colors.red)
                          : Colors.blue)
                      : const Color.fromARGB(255, 62, 162, 198);

                  final bgColor = isSelected
                      ? (controller.showFeedback.value
                          ? (isHealthy ? Colors.green[50] : Colors.red[50])
                          : Colors.blue.withOpacity(0.1))
                      : Colors.white;

                  return GestureDetector(
                    onTap: controller.showFeedback.value
                        ? null
                        : () => controller.toggleSelection(food),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2),
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
                            food["icon"],
                            height: 60,
                            width: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 60,
                                width: 60,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            food["name"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: controller.showFeedback.value && isSelected
                                  ? (isHealthy
                                      ? Colors.green[800]
                                      : Colors.red[800])
                                  : Colors.black,
                            ),
                          ),

                          if (controller.showFeedback.value && isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                isHealthy
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: isHealthy ? Colors.green : Colors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              )),

          const SizedBox(height: 32),

          /// ✅ Check Answer Button
          Obx(() => controller.showFeedback.value
              ? const SizedBox.shrink()
              : ElevatedButton.icon(
                  onPressed: controller.selectedItems.isNotEmpty
                      ? controller.checkAnswer
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E83AD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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

          // const SizedBox(height: 5),

          /// ✅ Feedback Section
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
                  color:
                      controller.isCorrect.value ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    controller.isCorrect.value
                        ? "✅ Great job! You chose correctly!"
                        : "❌ Some of your choices were wrong.",
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
                      controller.currentQuestionIndex.value + 1 ==
                              controller.questions.length
                          ? "Finish Quiz"
                          : "Next Question",
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
