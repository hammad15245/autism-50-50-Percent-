import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz3/quiz3_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BubbleQuizScreen extends StatefulWidget {
  const BubbleQuizScreen({Key? key}) : super(key: key);

  @override
  State<BubbleQuizScreen> createState() => _BubbleQuizScreenState();
}

class _BubbleQuizScreenState extends State<BubbleQuizScreen> {
  final BubbleQuizController controller = Get.put(BubbleQuizController());

  @override
  void initState() {
    super.initState();
    controller.initializeAnswers();
  }

  void _handleTap(int index) {
    controller.selectAnswer(index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress + Instruction
        Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            children: [
              Obx(() => LinearProgressIndicator(
                    value: controller.getProgressPercentage(),
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  )),
              SizedBox(height: screenHeight * 0.01),
              Obx(() => Text(
                    "${controller.getCorrectAnswersCount()}/3 letters found",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  )),
              SizedBox(height: screenHeight * 0.02),
              Text(
                "Tap on the letters (A, B, C)",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0E83AD),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Bubble Grid (shrinkWrap so it doesn't break parent scroll)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: screenWidth * 0.04,
            mainAxisSpacing: screenHeight * 0.02,
            childAspectRatio: 1.0,
          ),
          itemCount: controller.options.length,
          itemBuilder: (context, index) {
            return Obx(() {
              final answer = controller.answers[index];
              return GestureDetector(
                onTap: () => _handleTap(index),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.primaries[index % Colors.primaries.length].shade300,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          controller.options[index],
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    if (answer == false)
                      Icon(Icons.close, color: Colors.red, size: screenWidth * 0.15),
                    if (answer == true)
                      Icon(Icons.check, color: Colors.green, size: screenWidth * 0.15),
                  ],
                ),
              );
            });
          },
        ),

        // Feedback / Button
        Center(
          child: Obx(() => controller.showCompletion.value
              ? _buildFeedbackSection(context)
              : _buildCheckButton(context)),
        ),
      ],
    );
  }

  Widget _buildCheckButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: ElevatedButton(
        onPressed: controller.checkAnswerAndNavigate,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E83AD),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Check Answers",
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final correctCount = controller.getCorrectAnswersCount();
    final isPerfect = correctCount == 3;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.04),
      margin: EdgeInsets.all(screenWidth * 0.03),
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
            isPerfect ? "Perfect! 🎉" : "Good Job!",
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
                ? "You found all 3 letters!"
                : "You found $correctCount out of 3 letters!",
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
                onPressed: () {
                  Get.to(() => const Quiz3Screen());
                },
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
                onPressed: controller.resetQuiz,
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
       
        ],
      ),
    );
  }
}
