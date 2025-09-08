import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/quiz1/quiz1_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimalSortingWidget extends StatelessWidget {
  final AnimalSortingController controller = Get.put(AnimalSortingController());

  AnimalSortingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
 

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.forest, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "WILD ANIMALS",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              
               SizedBox(width: MediaQuery.of(context).size.width * 0.25),
              
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "HOME ANIMALS",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),

          // Sorting Area - Titles are now ABOVE
          Container(
            height: screenHeight * 0.5,
            child: Row(
              children: [
                Expanded(child: _buildCategorySide("wild")),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _buildAnimalsCenter()),
                const SizedBox(width: 8),
                Expanded(child: _buildCategorySide("home")),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Check Answer Button
          Obx(() => controller.showFeedback.value || controller.allAnimalsPlaced
              ? const SizedBox.shrink()
              : ElevatedButton.icon(
                  onPressed: controller.checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E83AD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, size: 20, color: Colors.white),
                  label: const Text(
                    "Check Answer",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )),
          const SizedBox(height: 20),

          // Feedback Section
          Obx(() {
            if (controller.showFeedback.value) {
              return Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: controller.isCorrect.value ? Colors.green[50] : Colors.orange[50],
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
                          ? "✅ Perfect! All animals are in the right place!"
                          : "❌ Some animals are in the wrong category. Try again!",
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                        color: controller.isCorrect.value ? Colors.green[800] : Colors.orange[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    if (controller.isCorrect.value)
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

                    if (!controller.isCorrect.value)
                      ElevatedButton(
                        onPressed: controller.resetQuestion,
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

  Widget _buildCategorySide(String category) {
    Color color = category == "wild" ? Colors.green : Colors.blue;
    
    return DragTarget<Map<String, dynamic>>(
      onAccept: (animal) {
        controller.placeAnimal(animal, category);
      },
      builder: (context, candidateData, rejectedData) {
        return Obx(() {
          List<Map<String, dynamic>> animals = [];
          if (category == "wild") {
            animals = controller.wildAnimals;
          } else {
            animals = controller.homeAnimals;
          }

          return Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  animals[index]["icon"],
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.emoji_nature, size: 40, color: color),
                );
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildAnimalsCenter() {
    return Obx(() => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: controller.currentAnimals.length,
          itemBuilder: (context, index) {
            final animal = controller.currentAnimals[index];
            final isPlaced = controller.completedAnimals.contains(animal["id"]);

            return isPlaced
                ? const SizedBox.shrink()
                : Draggable<Map<String, dynamic>>(
                    data: animal,
                    feedback: Material(
                      elevation: 8,
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          animal["icon"],
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            animal["icon"],
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.emoji_nature, size: 30, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            animal["name"],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ));
  }
}