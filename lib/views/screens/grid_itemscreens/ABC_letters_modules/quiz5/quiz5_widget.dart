import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz5/quiz5_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SoundRecognitionQuiz extends StatelessWidget {
  final SoundRecognitionController controller = Get.put(SoundRecognitionController());

  SoundRecognitionQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ Dynamic Instruction Text (AI-synced)
          Obx(() => Column(
                children: [
                  Text(
                    controller.instructionText.value.isEmpty
                        ? "Listen and choose the correct picture!"
                        : controller.instructionText.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E83AD),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  controller.isSpeaking.value
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.volume_up, size: 28),
                          onPressed: (){}, 
                        ),
                ],
              )),

          SizedBox(height: screenHeight * 0.02),

          Obx(() => LinearProgressIndicator(
                value: (controller.currentIndex.value + 1) / controller.soundObjects.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
              )),
          SizedBox(height: screenHeight * 0.01),

          // ✅ Progress text
          Obx(() => Text(
                "Question ${controller.currentIndex.value + 1}/${controller.soundObjects.length}",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              )),
          SizedBox(height: screenHeight * 0.03),

          // ✅ Options Grid
          Obx(() {
            final currentData = controller.soundObjects[controller.currentIndex.value];
            final options = _generateOptions(currentData["image"]!);

            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return _buildImageOption(options[index], currentData["image"]!);
              },
            );
          }),

          SizedBox(height: screenHeight * 0.03),

          // ✅ Completion Feedback
          Obx(() => controller.showCompletion.value
              ? _buildCompletionFeedback(context)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCompletionFeedback(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final correctCount = controller.correctlyAnsweredQuestions.value;
    final totalQuestions = controller.soundObjects.length;
    final isPerfect = correctCount == totalQuestions;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isPerfect ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isPerfect ? Colors.green.shade200 : Colors.blue.shade200,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPerfect ? Icons.check_circle : Icons.emoji_events,
            color: isPerfect ? Colors.green : Colors.blue,
            size: screenWidth * 0.1,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            isPerfect ? "Quiz Completed! 🎉" : "Great Effort!",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: isPerfect ? Colors.green.shade800 : Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            isPerfect
                ? "Perfect score! You got all $totalQuestions right!"
                : "You got $correctCount out of $totalQuestions correct!",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Get.to(() => const Quiz4matchingscreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
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
              ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
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
          SizedBox(height: screenHeight * 0.01),
          Text(
            isPerfect
                ? "You're a sound recognition expert! ✨"
                : "Practice makes perfect!",
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<String> _generateOptions(String correctImage) {
    List<String> allImages = controller.soundObjects.map((e) => e["image"]!).toList();
    allImages.remove(correctImage);
    allImages.shuffle();
    List<String> options = [correctImage, ...allImages.take(3)];
    options.shuffle();
    return options;
  }

  Widget _buildImageOption(String imagePath, String correctImage) {
    return GetBuilder<SoundRecognitionController>(
      id: "options",
      builder: (controller) {
        bool isSelected = controller.selectedAnswer.value == imagePath;
        bool isCorrect = imagePath == correctImage;
        bool showFeedback = controller.showFeedback.value;

        Color borderColor = const Color.fromARGB(255, 209, 209, 209);
        if (showFeedback) {
          if (isSelected) {
            borderColor = isCorrect ? Colors.green : Colors.red;
          } else if (isCorrect) {
            borderColor = Colors.green;
          }
        }

        return GestureDetector(
          onTap: () {
            if (!controller.showFeedback.value && !controller.showCompletion.value) {
              controller.checkAnswer(imagePath);
              controller.update(["options"]);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 3),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        );
      },
    );
  }
}
