import 'package:autism_fyp/views/screens/grid_itemscreens/living_nonliving_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LivingNonLivingQuiz2Widget extends StatelessWidget {
  final LivingNonLivingQuiz2Controller controller =
      Get.put(LivingNonLivingQuiz2Controller());

  LivingNonLivingQuiz2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Obx(() => Text(
                controller.instruction.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() => GridView.builder(
                  itemCount: controller.objects.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final object = controller.objects[index];
                    final isSelected =
                        controller.selectedObjects.contains(object["id"]);

                    return GestureDetector(
                      onTap: () => controller.toggleSelection(object["id"]),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.green.withOpacity(0.3)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              object["icon"],
                              height: screenWidth * 0.18,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              object["name"],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),

          const SizedBox(height: 16),

          Obx(() => ElevatedButton(
                onPressed: controller.selectedObjects.isNotEmpty
                    ? () => controller.checkAnswer()
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: controller.selectedObjects.isNotEmpty
                      ? Colors.blue
                      : Colors.grey.shade400,
                ),
                child: const Text("Submit"),
              )),
        ],
      ),
    );
  }
}
