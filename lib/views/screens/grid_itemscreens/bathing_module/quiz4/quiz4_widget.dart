import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz4/quiz4_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SensoryQuiz extends StatelessWidget {
  final SensoryController controller = Get.put(SensoryController());

  SensoryQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView( // Add this wrapper
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
   
          Text(
            "Drag sensations to matching bath items",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.03),
          Obx(() => LinearProgressIndicator(
                value: controller.completedMatches.value /
                    controller.totalMatches.value,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              )),
          SizedBox(height: screenHeight * 0.02),
          Obx(() => Text(
                "${controller.completedMatches.value}/${controller.totalMatches.value} matches",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              )),
          SizedBox(height: screenHeight * 0.03),
          Text(
            "Sensations",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E83AD),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildSensationsGrid(screenWidth, screenHeight),
          SizedBox(height: screenHeight * 0.02), // Reduced from 0.03
          Text(
            "Bath Items",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0E83AD),
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          _buildItemsGrid(screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildSensationsGrid(double screenWidth, double screenHeight) {
    return Obx(() => SizedBox( // Constrain the height
      height: screenHeight * 0.30, // Adjust this value as needed
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenHeight * 0.02,
          childAspectRatio: 1.2,
        ),
        itemCount: controller.sensations.length,
        itemBuilder: (context, index) {
          final sensation = controller.sensations[index];
          return _buildDraggableSensation(sensation, screenWidth);
        },
      ),
    ));
  }

  Widget _buildDraggableSensation(
      Map<String, dynamic> sensation, double screenWidth) {
    bool isPlaced = _isSensationPlaced(sensation["id"]);

    return Draggable<String>(
      data: sensation["id"],
      feedback: _buildSensationFeedback(sensation, screenWidth),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildSensationCard(sensation, screenWidth, isPlaced),
      ),
      child: _buildSensationCard(sensation, screenWidth, isPlaced),
    );
  }

  Widget _buildSensationFeedback(
      Map<String, dynamic> sensation, double screenWidth) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth * 0.2,
        height: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF0E83AD), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          // Use Image.asset instead of Text for local icons
          child: Image.asset(
            sensation["icon"],
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
          ),
        ),
      ),
    );
  }

  Widget _buildSensationCard(
      Map<String, dynamic> sensation, double screenWidth, bool isPlaced) {
    return Container(
      decoration: BoxDecoration(
        color: isPlaced ? Colors.green[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPlaced ? Colors.green : Colors.blue[300]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            sensation["icon"],
            width: screenWidth * 0.08,
            height: screenWidth * 0.08,
          ),
          const SizedBox(height: 4),
          Text(
            sensation["name"],
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(double screenWidth, double screenHeight) {
    return Obx(() => SizedBox( 
      height: screenHeight * 0.3,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenHeight * 0.02,
          childAspectRatio: 0.9,
        ),
        itemCount: controller.items.length,
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return _buildItemContainer(item, screenWidth, screenHeight);
        },
      ),
    ));
  }

  Widget _buildItemContainer(
      Map<String, dynamic> item, double screenWidth, double screenHeight) {
    return DragTarget<String>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.orange : Colors.grey[300]!,
              width: candidateData.isNotEmpty ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  // Use Image.asset instead of Text for local icons
                  child: Image.asset(
                    item["icon"],
                    width: screenWidth * 0.12,
                    height: screenWidth * 0.12,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Text(
                  item["name"],
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildPlacedSensations(item, screenWidth),
            ],
          ),
        );
      },
      onWillAccept: (data) => controller.canAcceptSensation(item["id"], data!),
      onAccept: (data) => controller.placeSensation(item["id"], data),
    );
  }

  Widget _buildPlacedSensations(Map<String, dynamic> item, double screenWidth) {
    final placed = item["placedSensations"] as List<String>;
    bool isFull = placed.length >= 2;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        color: isFull ? Colors.green[50] : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (placed.isEmpty)
            Text(
              "Add sensations",
              style: TextStyle(
                fontSize: screenWidth * 0.025,
                color: Colors.grey[600],
              ),
            )
          else
            ...placed.map((sensationId) {
              final sensation = controller.getSensation(sensationId);
              // Use Image.asset instead of Text for local icons
              return Image.asset(
                sensation["icon"],
                width: screenWidth * 0.06,
                height: screenWidth * 0.06,
              );
            }).toList(),
          if (isFull)
            const Icon(
              Icons.check,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }

  bool _isSensationPlaced(String sensationId) {
    for (var item in controller.items) {
      final placed = item["placedSensations"] as List<String>;
      if (placed.contains(sensationId)) {
        return true;
      }
    }
    return false;
  }
}