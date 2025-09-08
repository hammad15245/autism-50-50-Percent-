import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'quiz1_controller.dart';

class FruitMathWidget extends StatelessWidget {
  final FruitMathController controller = Get.put(FruitMathController());

  FruitMathWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
          const SizedBox(height: 16),

          // Target Requirements
          Obx(() => Wrap(
            spacing: 12,
            children: List.generate(controller.currentQuestion["target"].length, (index) {
              final target = controller.currentQuestion["target"][index];
              return Chip(
                label: Text("${target["count"]} ${target["type"]}s", 
                    style: const TextStyle(color: Colors.white),
),
                backgroundColor: const Color.fromARGB(255, 96, 185, 218),
                avatar: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    controller.availableFruits.firstWhere(
                      (f) => f["type"] == target["type"],
                      orElse: () => {"icon": ""},
                    )["icon"],
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 16),
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 15),

          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: controller.availableFruits.length,
            itemBuilder: (context, index) {
              final fruit = controller.availableFruits[index];
              return Draggable<Map<String, dynamic>>(
                data: fruit,
                feedback: Material(
                  elevation: 4,
                  child: Opacity(
                    opacity: 0.8,
                    child: Image.asset(
                      fruit["icon"],
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, size: 40),
                    ),
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.3,
                  child: FruitItem(fruit: fruit),
                ),
                child: FruitItem(fruit: fruit),
              );
            },
          )),
          const SizedBox(height: 15),

Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.green[50],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.green[300]!, width: 2),
  ),
  child: Column(
    children: [
      Text(
        "Your Basket",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
      const SizedBox(height: 12),
      // REMOVE Obx from here and use GetBuilder or separate the observable part
      DragTarget<Map<String, dynamic>>(
        onAccept: (fruit) {
          controller.addToBasket(fruit);
        },
        builder: (context, candidateData, rejectedData) {
          return Obx(() => Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green, width: 1.5),
            ),
            child: controller.basketItems.isEmpty
                ? const Center(
                    child: Text(
                      "Drag fruits here!",
                      style: TextStyle(
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: controller.basketItems.map((fruit) {
                      return Draggable<Map<String, dynamic>>(
                        data: fruit,
                        feedback: Material(
                          elevation: 4,
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.asset(
                              fruit["icon"],
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error, size: 30),
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () => controller.removeFromBasket(fruit),
                          child: Image.asset(
                            fruit["icon"],
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, size: 30),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ));
        },
      ),
    ],
  ),
),
          const SizedBox(height: 15),

       // Action Buttons
Obx(() => controller.showFeedback.value
    ? const SizedBox.shrink() 
    : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
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
          ),
        ],
      ),
),   const SizedBox(height: 15),

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
                ? "✅ Perfect! Your basket is correct!"
                : "❌ Not quite right. Try again!",
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
          
          // Show "Next Question" only when correct AND not last question
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
                "Next Question",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          
          // Show "Try Again" button when answer is wrong
          if (!controller.isCorrect.value)
            ElevatedButton(
              onPressed: () {
                controller.showFeedback.value = false; // Hide feedback
                // Optional: Clear basket or keep wrong answer for learning
              },
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
              onPressed: () {
                controller.checkAnswerAndNavigate(); 
              },
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
}),],
      ),
    );
  }
}

class FruitItem extends StatelessWidget {
  final Map<String, dynamic> fruit;

  const FruitItem({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            fruit["icon"],
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 30),
          ),
          const SizedBox(height: 4),
          Text(
            fruit["name"],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}