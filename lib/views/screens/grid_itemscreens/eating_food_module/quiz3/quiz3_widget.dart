import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz3/quiz3_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthyChoicesQuiz extends StatelessWidget {
  final HealthyChoicesController controller =
      Get.put(HealthyChoicesController());

  HealthyChoicesQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Obx(() => _buildDraggableItems(screenWidth)),
          SizedBox(height: 30),

          // Baskets
          _buildBaskets(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.03),

          // Completion
          Obx(() => controller.showCompletion.value
              ? _buildCompletion(screenWidth, screenHeight)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }


Widget _buildDraggableItems(double screenWidth) {
   return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.availableItems.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenWidth * 0.02,
          childAspectRatio: 1.4, 
        ),
        itemBuilder: (context, index) {
          final item = controller.availableItems[index];
          return Draggable<Map<String, dynamic>>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: Image.asset(item["icon"],
                  width: screenWidth * 0.15, height: screenWidth * 0.15),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: Image.asset(item["icon"],
                  width: screenWidth * 0.15, height: screenWidth * 0.15),
            ),
            child: Image.asset(item["icon"],
                width: screenWidth * 0.15, height: screenWidth * 0.15),
          );
        },
      );
}


  Widget _buildBaskets(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBasket("Clean", controller.cleanItems, screenWidth),
        _buildBasket("Dirty", controller.dirtyItems, screenWidth),
      ],
    );
  }

  Widget _buildBasket(
      String name, RxList<Map<String, dynamic>> collectedItems, double screenWidth) {
    return DragTarget<Map<String, dynamic>>(
      onAccept: (item) => controller.placeInBasket(name, item),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: screenWidth * 0.4,
          height: screenWidth * 0.51,
          padding: EdgeInsets.all(screenWidth * 0.03),
          decoration: BoxDecoration(
            color: name == "Clean" ? Colors.green[200] : Colors.brown[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0E83AD), width: 2),
          ),
          child: Column(
            children: [
              Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.05)),
              const Divider(),
              Expanded(
                child: Obx(() => Wrap(
                      children: collectedItems
                          .map((item) => Padding(
                                padding: EdgeInsets.all(4),
                                child: Image.asset(item["icon"],
                                    width: screenWidth * 0.1,
                                    height: screenWidth * 0.1),
                              ))
                          .toList(),
                    )),
              ),
            ],
          ),
        );
      },
    );
  }Widget _buildCompletion(double screenWidth, double screenHeight) {
  // Get the latest feedback from controller
  String feedback = controller.feedbackMessage.value;

  // Determine color: green for correct, red for wrong, green if empty
  Color feedbackColor = feedback.isEmpty || feedback.contains("Correct")
      ? Colors.green
      : Colors.red;

  return Column(
    children: [
      Text(
        feedback.isEmpty ? "Well done! 🎉" : feedback, // Show feedback
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: feedbackColor,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: screenHeight * 0.02),
      ElevatedButton(
        onPressed: () => controller.checkAnswerAndNavigate(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E83AD),
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.015),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          "Continue",
          style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
        ),
      ),
    ],
  );
}


  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Need Help?"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text("Drag items into the correct basket:"),
              SizedBox(height: 8),
              Text("- Clean items → Clean Basket"),
              Text("- Dirty items → Dirty Basket"),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text("Got it!"))
          ],
        );
      },
    );
  }
}
