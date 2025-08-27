import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_widget.dart';
import 'package:flutter/material.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';

class Quiz2bubble extends StatefulWidget {
  const Quiz2bubble({super.key});

  @override
  State<Quiz2bubble> createState() => _Quiz2bubbleState();
}

class _Quiz2bubbleState extends State<Quiz2bubble> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.06),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StepProgressHeader(
                currentStep: 2,
                onBack: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Collect the ABC letters.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Use the AlphabetQuizScreen widget
            Expanded(
              child: BubbleQuizScreen(),
            ),
          ],
        ),
      ),
    );
  }
}