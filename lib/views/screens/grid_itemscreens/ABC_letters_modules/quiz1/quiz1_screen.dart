import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz1/quiz1_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/screens/progressheader.dart';

class Quiz1Screen extends StatefulWidget {
  const Quiz1Screen({super.key});


  @override
  State<Quiz1Screen> createState() => _Quiz1ScreenState();
}


class _Quiz1ScreenState extends State<Quiz1Screen> {
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
                currentStep: 1,
                onBack: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Find the correct Letter from Picture.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            // Use the AlphabetQuizScreen widget
            Expanded(
              child: AlphabetQuiz(),
            ),
          ],
        ),
      ),
    );
  }
}