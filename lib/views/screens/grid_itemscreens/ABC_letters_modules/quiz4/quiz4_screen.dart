import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/abc_quiz_progressheader.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_widget.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Quiz4matchingscreen extends StatelessWidget {
  const Quiz4matchingscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Quiz4matchingController controller = Get.put(Quiz4matchingController());
    final AvatarController avatarController = Get.put(AvatarController());

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: abcstepprogressheader(
                currentStep: 4,
                onBack: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Avatar
                      Obx(() {
                        final avatarPath = avatarController.avatarPath.value;
                        if (avatarPath.isEmpty) {
                          return const SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Image.asset(
                          avatarPath,
                          height: screenHeight * 0.10,
                          width: screenWidth * 0.20,
                          fit: BoxFit.contain,
                        );
                      }),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Obx(
                            () => Text(
                              controller.instructionText.value, 
                              style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Quiz Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Match Letters with their things",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => LinearProgressIndicator(
                    value: controller.getProgressPercentage(),
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
                  )),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Progress text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => Text(
                    "${controller.userPairs.length}/5 matches made",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  )),
            ),

            SizedBox(height: screenHeight * 0.02),

            // Matching widget - Expanded to take available space
            Expanded(
              child: SingleChildScrollView(
                child: Quiz4matching(
                  controller: controller,
                  leftImages: [
                    'lib/assets/quiz4_matching/left1.png',
                    'lib/assets/quiz4_matching/left2.png',
                    'lib/assets/quiz4_matching/left3.png',
                    'lib/assets/quiz4_matching/left4.png',
                    'lib/assets/quiz4_matching/left5.png',
                  ],
                  rightImages: [
                    'lib/assets/quiz4_matching/right1.png',
                    'lib/assets/quiz4_matching/right2.png',
                    'lib/assets/quiz4_matching/right3.png',
                    'lib/assets/quiz4_matching/right4.png',
                    'lib/assets/quiz4_matching/right5.png',
                  ],
                ),
              ),
            ),

            // Check button
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: controller.checkAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E83AD),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Check Answers",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}