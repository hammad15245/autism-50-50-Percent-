import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz3/quiz3_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz4/quiz4_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CleanDirtyQuiz extends StatelessWidget {
  final CleanDirtyController controller = Get.find<CleanDirtyController>();

  CleanDirtyQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.9, 
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                "Find Clean Items",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E83AD),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 15),

              // Progress indicator
              Obx(() => LinearProgressIndicator(
                    value: controller.collectedCleanItems.value /
                        controller.totalCleanItems.value,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  )),

              SizedBox(height: 20),

              // Progress text
              Obx(() => Text(
                    "${controller.collectedCleanItems.value}/${controller.totalCleanItems.value} clean items found",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  )),

              SizedBox(height: 15),

              SizedBox(
                height: screenHeight * 0.6,
                child: Obx(() => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: screenWidth * 0.03,
                        mainAxisSpacing: screenHeight * 0.02,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: controller.items.length,
                      itemBuilder: (context, index) {
                        return _buildImageItem(controller.items[index], index,
                            screenWidth, screenHeight);
                      },
                    )),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Feedback Section
              Obx(() => controller.showCompletion.value 
                  ? _buildCompletionFeedback(context) 
                  : _buildActionButtons(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return ElevatedButton(
      onPressed: controller.checkAnswerAndNavigate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF0E83AD),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        "Check Answer",
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCompletionFeedback(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate performance metrics
    final correctSelections = controller.collectedCleanItems.value;
    final wrongSelections = controller.wrongSelections.value;
    final totalSelections = correctSelections + wrongSelections;
    final accuracy = totalSelections > 0 
        ? (correctSelections / totalSelections * 100).round() 
        : 0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.only(top: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: wrongSelections == 0 ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: wrongSelections == 0 ? Colors.green.shade200 : Colors.blue.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Success Icon and Message
          Icon(
            wrongSelections == 0 ? Icons.check_circle : Icons.emoji_events,
            color: wrongSelections == 0 ? Colors.green : Colors.blue,
            size: screenWidth * 0.1,
          ),
          
          SizedBox(height: screenHeight * 0.01),
          
          Text(
            wrongSelections == 0 
                ? "Excellent! All clean items found!" 
                : "Great job! You found most of the clean items!",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: wrongSelections == 0 ? Colors.green.shade800 : Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          
         
    
          SizedBox(height: 15),

          
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to next quiz or module
                  Get.to(() => sensoryscreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Continue",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Try Again Button
              ElevatedButton(
                onPressed: controller.resetQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
 
        ],
      ),
    );
  }

  Widget _buildImageItem(
      Map<String, dynamic> item, int index, double screenWidth, double screenHeight) {
    bool isSelected = item["isSelected"] == true;
    bool isClean = item["isClean"] == true;

    return GestureDetector(
      onTap: () => controller.toggleItemSelection(index),
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.01),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? (isClean ? Colors.green : Colors.red)
                      : Colors.grey[300]!,
                  width: isSelected ? 3 : 2,
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
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Image.asset(
                        item["image"],
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                            size: screenWidth * 0.06,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(screenWidth * 0.01),
                    child: Text(
                      item["name"],
                      style: TextStyle(
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.012),
                  decoration: BoxDecoration(
                    color: isClean ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isClean ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: screenWidth * 0.035,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}