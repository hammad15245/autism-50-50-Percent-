import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/quiz3/quiz3_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SequenceQuiz extends StatelessWidget {
  final SequenceController controller = Get.put(SequenceController());

  SequenceQuiz({super.key});

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
            controller.levels[controller.currentLevel.value - 1]["instruction"],
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: screenWidth * 0.043,
              color: Color(0xFF0E83AD),
            ),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: 20),
          
       
          Obx(() => _buildAvailableNumbers(screenWidth)),
          SizedBox(height: 15),
          
          // Selected Sequence
          Text(
            "Your sequence:",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          SizedBox(height:15),
          _buildSelectedSequence(screenWidth),
          SizedBox(height: 10),
          
          Obx(() =>  controller.showCompletion.value
            ? _buildCompletionButtons(screenWidth, screenHeight)
            : _buildGameButtons(screenWidth, screenHeight)),
        ],
      ),
    );
  }

  Widget _buildAvailableNumbers(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Wrap(
        spacing: screenWidth * 0.03,
        runSpacing: screenWidth * 0.02,
        alignment: WrapAlignment.center,
        children: controller.numbers.map((number) {
          return _buildNumberButton(number, screenWidth, false);
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedSequence(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Obx(() => Wrap(
        spacing: screenWidth * 0.03,
        runSpacing: screenWidth * 0.02,
        alignment: WrapAlignment.center,
        children: controller.selectedNumbers.map((number) {
          return _buildNumberButton(number, screenWidth, true);
        }).toList(),
      )),
    );
  }

  Widget _buildNumberButton(int number, double screenWidth, bool isSelected) {
    return GestureDetector(
      onTap: isSelected 
          ? () => controller.removeNumber(number)
          : () => controller.selectNumber(number),
      child: Container(
        width: screenWidth * 0.15,
        height: screenWidth * 0.15,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.blue,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "$number",
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.green[800] : Colors.blue[800],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButtons(double screenWidth, double screenHeight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        
        // Reset Button
        ElevatedButton(
          onPressed: controller.resetGame,
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.015,
              ),
            backgroundColor: Color(0xFF0E83AD),
        
          ),
          child: Text(
            "Reset",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
Widget _buildCompletionButtons(double screenWidth, double screenHeight) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: screenWidth * 0.1),
              SizedBox(height: 8),
              Text(
                "Correct Sequence!",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 13),
        ElevatedButton(
          onPressed: controller.checkAnswerAndNavigate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0E83AD),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.02,
            ),
          ),
          child: Text(
            "Continue",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }}