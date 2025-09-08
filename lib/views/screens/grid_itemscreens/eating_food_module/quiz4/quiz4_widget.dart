import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz4/quiz4_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HealthyTreatQuiz extends StatelessWidget {
  final HealthyTreatController controller = Get.put(HealthyTreatController());

  HealthyTreatQuiz({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Obx(() {
        if (controller.showCompletion.value) {
          return _buildCompletion(screenWidth, screenHeight);
        }

        var current = controller.questions[controller.currentQuestionIndex.value];
        Map<String, dynamic> healthy = current["healthy"] as Map<String, dynamic>;
        Map<String, dynamic> treat = current["treat"] as Map<String, dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Question ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}",
              style: TextStyle(
                  fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Color(0xFF0E83AD)),
            ),
            SizedBox(height: 10),
            Text(
              current["question"],
              style: TextStyle(
                  fontSize: screenWidth * 0.040, fontWeight: FontWeight.w600, color: Color(0xFF0E83AD)),
            ),
            SizedBox(height: 15),

    Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    Flexible(
      child: Column(
        children: [
          Image.asset(
            healthy["icon"],
            fit: BoxFit.contain,
            width: screenWidth * 0.35,
            height: screenWidth * 0.35,
          ),
          SizedBox(height: 5),
          Text(
            healthy["name"].toString(),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E83AD),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 10),
    Flexible(
      child: Column(
        children: [
          Image.asset(
            treat["icon"],
            fit: BoxFit.contain,
            width: screenWidth * 0.35,
            height: screenWidth * 0.35,
          ),
          SizedBox(height: 5),
          Text(
            treat["name"].toString(),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0E83AD),
            ),
          ),
        ],
      ),
    ),
  ],
),


            SizedBox(height: 30),

   TextField(
  onChanged: (val) => controller.userAnswer.value = val,
  decoration: InputDecoration(
    labelText: "Type the healthier choice",   
      labelStyle: TextStyle(color:Colors.black), 
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),

  ),
),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => controller.checkAnswer(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0E83AD),
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.015),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                "Submit",
                style:
                    TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            Text(
              controller.feedbackMessage.value,
              style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: controller.feedbackMessage.value.contains("Correct")
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCompletion(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Text(
          "Well done! 🎉",
          style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.green),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.02),
        ElevatedButton(
          onPressed: (){},
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E83AD),
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.015),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Text(
            "Cntinue ",
            style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
          ),
        )
      ],
    );
  }
}
