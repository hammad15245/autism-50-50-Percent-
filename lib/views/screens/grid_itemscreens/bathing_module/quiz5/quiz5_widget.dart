import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz5/quiz5_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AfterBathQuiz extends StatelessWidget {
  final AfterBathController controller = Get.put(AfterBathController());

  AfterBathQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
  
          SizedBox(height: 10),
          Obx(() => Text(
              "${controller.currentSequence.length}/${controller.totalSteps.value} steps placed",
              style: TextStyle(
                  fontSize: screenWidth * 0.04, 
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E83AD)))),
          SizedBox(height: 10),
          Text("Available Steps:",
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E83AD))),
          SizedBox(height: 20),
          _buildAvailableSteps(screenWidth, screenHeight),
          SizedBox(height: 15),
          Text("After Bath Sequence:",
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0E83AD))),
          SizedBox(height: screenHeight * 0.01),
          _buildSequenceTimeline(screenWidth, screenHeight),
          // SizedBox(height: screenHeight * 0.03),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     Obx(() => ElevatedButton(
          //           onPressed: controller.showCompletion.value
          //               ? null
          //               : () => controller.checkAnswerAndNavigate(),
          //           style: ElevatedButton.styleFrom(
          //               backgroundColor: controller.showCompletion.value
          //                   ? Colors.green
          //                   : Colors.blue,
          //               padding: EdgeInsets.symmetric(
          //                   horizontal: screenWidth * 0.06,
          //                   vertical: screenHeight * 0.02)),
          //           child: Text(
          //               controller.showCompletion.value
          //                   ? "Completed! 🎉"
          //                   : "Check",
          //               style: TextStyle(
          //                   fontSize: screenWidth * 0.04, color: Colors.white)),
          //         )),
          //     Obx(() => controller.showCompletion.value
          //         ? ElevatedButton(
          //             onPressed: controller.resetQuiz,
          //             style: ElevatedButton.styleFrom(
          //                 backgroundColor: Colors.orange,
          //                 padding: EdgeInsets.symmetric(
          //                     horizontal: screenWidth * 0.06,
          //                     vertical: screenHeight * 0.02)),
          //             child: Text("Try Again",
          //                 style: TextStyle(
          //                     fontSize: screenWidth * 0.04,
          //                     color: Colors.white)),
          //           )
          //         : const SizedBox.shrink()),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildAvailableSteps(double screenWidth, double screenHeight) {
    return Obx(() => Container(
          height: screenHeight * 0.3,
          decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!)),
          child: GridView.builder(
            padding: EdgeInsets.all(screenWidth * 0.03),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: screenWidth * 0.02,
                mainAxisSpacing: screenHeight * 0.01,
                childAspectRatio: 1.2),
            itemCount: controller.availableSteps.length,
            itemBuilder: (context, index) {
              return _buildStepCard(
                  controller.availableSteps[index], index, screenWidth, true);
            },
          ),
        ));
  }
Widget _buildSequenceTimeline(double screenWidth, double screenHeight) {
  return Obx(() => Container(
    height: screenHeight * 0.35,
    decoration: BoxDecoration(
      color: Colors.green[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green[200]!)
    ),
    child: GridView.builder(
      padding: EdgeInsets.all(screenWidth * 0.03),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: screenWidth * 0.03,
        mainAxisSpacing: screenHeight * 0.01,
        childAspectRatio: 2.5,
      ),
      itemCount: controller.totalSteps.value,
      itemBuilder: (context, index) {
        if (index < controller.currentSequence.length) {
          return _buildSequenceSlot(
            controller.currentSequence[index], 
            index, 
            screenWidth, 
            false
          );
        } else {
          return _buildEmptySlot(index, screenWidth);
        }
      },
    ),
  ));
}
  Widget _buildStepCard(Map<String, String> step, int index, double screenWidth,
      bool isAvailable) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(step["icon"]!,
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            fit: BoxFit.contain),
        SizedBox(height: 4),
        Text(step["name"]!,
            style: TextStyle(
                fontSize: screenWidth * 0.03, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2),
      ],
    );

    if (!isAvailable) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[300]!, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2))
            ]),
        child: content,
      );
    }

    return Draggable<int>(
      data: index,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(step["icon"]!,
                  width: screenWidth * 0.1,
                  height: screenWidth * 0.1,
                  fit: BoxFit.contain),
              SizedBox(height: 4),
              Text(step["name"]!,
                  style: TextStyle(fontSize: screenWidth * 0.03)),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
          opacity: 0.35,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 2))
                  ]),
              child: content)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2))
            ]),
        child: content,
      ),
    );
  }

  Widget _buildSequenceSlot(Map<String, String> step, int index,
      double screenWidth, bool isDraggable) {
    return DragTarget<int>(
      onWillAccept: (data) => true,
      onAccept: (availableIndex) => controller.moveToSequence(availableIndex, index),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: () => controller.moveToAvailable(index),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color:
                        candidateData.isNotEmpty ? Colors.orange : Colors.green,
                    width: 2)),
            child: Row(
              children: [
                Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.08,
                  decoration: const BoxDecoration(
                      color: Colors.green, shape: BoxShape.circle),
                  child: Center(
                      child: Text("${index + 1}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step["name"]!,
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w600)),
                      Text(step["description"]!,
                          style: TextStyle(
                              fontSize: screenWidth * 0.025,
                              color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Image.asset(step["icon"]!,
                    width: screenWidth * 0.09,
                    height: screenWidth * 0.09,
                    fit: BoxFit.contain),
                const SizedBox(width: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptySlot(int index, double screenWidth) {
    return DragTarget<int>(
      onWillAccept: (data) => true,
      onAccept: (availableIndex) {
        controller.moveToSequence(availableIndex, index);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  candidateData.isNotEmpty ? Colors.orange : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${index + 1}.",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  "Drag step here",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}