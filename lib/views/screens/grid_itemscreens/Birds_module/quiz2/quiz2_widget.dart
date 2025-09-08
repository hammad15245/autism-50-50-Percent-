import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BirdHabitatWidget extends StatelessWidget {
  final BirdHabitatController controller = Get.put(BirdHabitatController());

  BirdHabitatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
    

          _buildHabitatsRow(),
          const SizedBox(height: 24),

          Obx(() {
            final birds = controller.currentQuestion["birds"] as List<Map<String, dynamic>>;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: birds.map<Widget>((bird) {
                return Draggable<String>(
                  data: bird["id"],
                  feedback: Material(
                    elevation: 4,
                    child: Image.asset(
                      bird["icon"],
                      width: 60,
                      height: 60,
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _buildBirdItem(bird),
                  ),
                  child: _buildBirdItem(bird),
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 20),

          Obx(() => controller.showFeedback.value
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
                  icon: const Icon(Icons.check_circle, size: 20, color: Colors.white,),
                  label: const Text(
                    "Check Answer",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                )),
          const SizedBox(height: 20),

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
                          ? "✅ Perfect! All birds are in their right homes!"
                          : "❌ Some birds are in the wrong habitat. Try again!",
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

  Widget _buildHabitatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildHabitatWidget("forest", "Forest", Colors.green),
        _buildHabitatWidget("water", "Water", Colors.blue),
        _buildHabitatWidget("city", "City", Colors.orange),
      ],
    );
  }

  Widget _buildHabitatWidget(String habitatType, String name, Color color) {
    return HabitatWidget(
      habitatType: habitatType,
      name: name,
      color: color,
      controller: controller,
    );
  }

  Widget _buildBirdItem(Map<String, dynamic> bird) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            bird["icon"],
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.emoji_nature, size: 40, color: Colors.green),
          ),
          const SizedBox(height: 4),
          Text(
            bird["name"],
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


class HabitatWidget extends StatelessWidget {
  final String habitatType;
  final String name;
  final Color color;
  final BirdHabitatController controller;

  const HabitatWidget({
    super.key,
    required this.habitatType,
    required this.name,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: (birdId) {
        controller.addBirdToHabitat(birdId, habitatType);
      },
      builder: (context, candidateData, rejectedData) {
        return Obx(() {
          List<Map<String, dynamic>> birds = [];
          switch (habitatType) {
            case "forest":
              birds = controller.forestBirds;
              break;
            case "water":
              birds = controller.waterBirds;
              break;
            case "city":
              birds = controller.cityBirds;
              break;
          }

          return Container(
            width: 100,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Column(
              children: [
                Image.asset(
                  "lib/assets/quiz1_birds/$habitatType.png",
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.landscape, size: 40, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  children: birds.map((bird) => Image.asset(
                    bird["icon"],
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.emoji_nature, size: 20, color: Colors.grey),
                  )).toList(),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}