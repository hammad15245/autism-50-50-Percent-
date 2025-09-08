import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/quiz2/quiz2_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class AnimalShadowsWidget extends StatelessWidget {
  final AnimalShadowsController controller = Get.put(AnimalShadowsController());

  AnimalShadowsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
      

            Obx(() => Flexible(
  flex: 2,
  child: GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
    ),
    itemCount: controller.currentLevelData["pairs"].length,
    itemBuilder: (context, index) {
      final animal = controller.currentLevelData["pairs"][index]["animal"];
      final isMatched = controller.matchedAnimals[animal["id"]] == true;

      return DragTarget<String>(
        onAccept: (animalId) {
          controller.handleDrag(animalId, animal["id"]);
        },
        builder: (context, candidateData, rejectedData) {
          final borderColor = controller.getBorderColor(animal["id"]);
          final borderWidth = controller.shouldShowFeedback(animal["id"]) || isMatched ? 3 : 2;
          
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: borderWidth.toDouble(),
              ),
            ),
            child: Center(
              child: isMatched
                  ? Image.asset(animal["icon"], width: 60, height: 60)
                  : Image.asset(
                      animal["shadow"],
                      width: 60,
                      height: 60,
                      color: Colors.grey[600],
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.pets, color: Colors.grey),
                      ),
                    ),
            ),
          );
        },
      );
    },
  ),
)),

            const SizedBox(height: 20),
// Drag items
Obx(() => Flexible(
  flex: 1,
  child: Wrap(
    spacing: 16,
    runSpacing: 16,
    alignment: WrapAlignment.center,
    children: controller.currentLevelData["pairs"].map<Widget>((pair) {
      final animal = pair["animal"];
      final isMatched = controller.matchedAnimals[animal["id"]] == true;

      return isMatched
          ? const SizedBox.shrink()
          : Draggable<String>(
              data: animal["id"],
              feedback: Material(
                elevation: 8,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(animal["icon"], width: 50, height: 50),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[300]!),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      animal["icon"],
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.pets,
                              size: 30, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animal["name"],
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
  ),
)),
            const SizedBox(height: 10),

            Obx(() {
              if (controller.showFeedback.value) {
                return Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "✅ Perfect! All shadows matched correctly!",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: controller.nextLevel,
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
                          "Continue ➔",
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
      ),
    );
  }
}