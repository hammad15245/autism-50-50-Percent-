import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz2_controller.dart';

class FoodGroupQuiz extends StatelessWidget {
  final FoodGroupController controller = Get.put(FoodGroupController());

  FoodGroupQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Obx(() => Text(
                "Sorted: ${controller.placedItems.value}/${controller.totalItems.value}",
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0E83AD),
                ),
              )),
          SizedBox(height:10),
        Text(
            "Drag these items into their categories:",
            style: TextStyle(
              fontSize: screenWidth * 0.040,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0E83AD),
            ),
          ),
          SizedBox(height:10),

          Obx(() => _buildAvailableFoods(screenWidth)),
          SizedBox(height: 10),
          _buildFoodGroupsGrid(screenWidth, screenHeight),
          SizedBox(height: 10),

  

       Obx(()=> controller.showCompletion.value
              ? _buildCompletionButtons(screenWidth, screenHeight)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }


  Widget _buildFoodGroupsGrid(double screenWidth, double screenHeight) {
    return Obx(() => GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: screenWidth * 0.02,
          mainAxisSpacing: screenHeight * 0.02,
          children: controller.foodGroups
              .map((group) => _buildFoodGroupCard(
                    group["name"] as String,
                    (group["items"] as List<dynamic>).cast<String>(),
                    screenWidth,
                  ))
              .toList(),
        ));
  }

Widget _buildFoodGroupCard(
    String groupName, List<String> items, double screenWidth) {
  return DragTarget<Map<String, dynamic>>(
    onWillAccept: (food) => true,
    onAccept: (food) {
      controller.placeFood(groupName, food["name"]);
    },
    builder: (context, candidateData, rejectedData) {
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF0E83AD), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0E83AD),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: items
                    .map((foodName) => Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenWidth * 0.01),
                          child: Draggable<Map<String, dynamic>>(
                            data: {
                              "name": foodName,
                              "fromGroup": groupName,
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: _buildFoodChip(foodName, screenWidth,
                                  isDragging: true),
                            ),
                            childWhenDragging: _buildFoodChip(foodName, screenWidth,
                                faded: true),
                            child: _buildFoodChip(foodName, screenWidth),
                            onDragCompleted: () {
                              controller.removeFood(groupName, foodName);
                            },
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildAvailableFoods(double screenWidth) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: screenWidth * 0.02,
      children: controller.availableFoods
          .map((food) => Draggable<Map<String, dynamic>>(
                data: food,
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildFoodChip(food["name"], screenWidth,
                      isDragging: true),
                ),
                childWhenDragging: _buildFoodChip(food["name"], screenWidth,
                    isDragging: false, faded: true),
                child: _buildFoodChip(food["name"], screenWidth),
              ))
          .toList(),
    );
  }

  Widget _buildFoodChip(String food, double screenWidth,
      {bool isDragging = false, bool faded = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03, vertical: screenWidth * 0.015),
      decoration: BoxDecoration(
        color: isDragging
            ?  Color(0xFF0E83AD)
            : faded
                ? Colors.grey[300]
                : const Color(0xFF0E83AD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        food,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: Colors.white,
        ),
      ),
    );
  }

  

  Widget _buildCompletionButtons(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          "Great job! 🎉",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        ElevatedButton(
          onPressed: () {
            controller.checkAnswerAndNavigate();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0E83AD),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.015,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            "Continue",
            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
