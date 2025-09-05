import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz3/quiz3_controller.dart';
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


              SizedBox(height: screenHeight * 0.03),

              // Progress indicator
              Obx(() => LinearProgressIndicator(
                    value: controller.collectedCleanItems.value /
                        controller.totalCleanItems.value,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.green),
                  )),

              SizedBox(height: screenHeight * 0.02),

              // Progress text
              Obx(() => Text(
                    "${controller.collectedCleanItems.value}/${controller.totalCleanItems.value} clean items found",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  )),

              SizedBox(height: screenHeight * 0.03),

              // Grid (remove Expanded, wrap in SizedBox with fixed height)
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

              // // Buttons
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     Obx(() => ElevatedButton(
              //           onPressed: controller.showCompletion.value
              //               ? null
              //               : controller.checkAnswerAndNavigate,
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: controller.showCompletion.value
              //                 ? Colors.green
              //                 : Colors.blue,
              //             padding: EdgeInsets.symmetric(
              //               horizontal: screenWidth * 0.06,
              //               vertical: screenHeight * 0.02,
              //             ),
              //           ),
              //           child: Text(
              //             controller.showCompletion.value
              //                 ? "Completed! 🎉"
              //                 : "Check",
              //             style: TextStyle(
              //               fontSize: screenWidth * 0.04,
              //               color: Colors.white,
              //             ),
              //           ),
              //         )),
              //     Obx(() => controller.showCompletion.value
              //         ? ElevatedButton(
              //             onPressed: controller.resetQuiz,
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: Colors.orange,
              //               padding: EdgeInsets.symmetric(
              //                 horizontal: screenWidth * 0.06,
              //                 vertical: screenHeight * 0.02,
              //               ),
              //             ),
              //             child: Text(
              //               "Try Again",
              //               style: TextStyle(
              //                 fontSize: screenWidth * 0.04,
              //                 color: Colors.white,
              //               ),
              //             ),
              //           )
              //         : const SizedBox.shrink()),
              //   ],
              // ),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
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
