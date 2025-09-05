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

    return Scaffold(
      
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with current sound
            
 

// Or as part of a row with the question:
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // Text part wrapped in Obx
    Obx(() => Text(
      "What starts with '${controller.currentSound.value}' sound?",
      style: TextStyle(
        fontSize: 18, 
        fontWeight: FontWeight.w500, 
        color: Color(0xFF0E83AD)
      ),
    )),
    SizedBox(width: 10),
    // IconButton part wrapped in Obx
    Obx(() => IconButton(
      icon: controller.isPlayingSound.value
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
              ),
            )
          : Icon(Icons.volume_up, size: 28),
      onPressed: controller.isPlayingSound.value ? null : controller.playSound,
    )),
  ],
),
              
              SizedBox(height: screenHeight * 0.03),
              
              // Image options grid
Expanded(
  child: Obx(() {
    final currentData = controller.soundObjects[controller.currentIndex.value];
    final options = _generateOptions(currentData!["image"]!);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        
        // Calculate responsive values
        final crossAxisSpacing = screenWidth * 0.04; // 4% of screen width
        final mainAxisSpacing = screenHeight * 0.02; // 2% of screen height
        
        return Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: GridView.builder(
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildImageOption(options[index], currentData["image"]!);
            },
          ),
        );
      },
    );
  }),
),
              
              // Progress indicator
              Obx(() => LinearProgressIndicator(
                value: (controller.currentIndex.value + 1) / controller.soundObjects.length,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E83AD)),
              )),
              
              SizedBox(height: screenHeight * 0.02),
              
        
            ],
          ),
        ),
      ),
    );
  }

  List<String> _generateOptions(String correctImage) {
    // Get 3 random wrong options + correct option
    List<String> allImages = controller.soundObjects.map((e) => e["image"]!).toList();
    allImages.remove(correctImage);
    allImages.shuffle();
    
    List<String> options = [correctImage, ...allImages.take(3)];
    options.shuffle();
    return options;
  }
Widget _buildImageOption(String imagePath, String correctImage) {
  return LayoutBuilder(
    builder: (context, constraints) {
      // Calculate responsive size based on available space
      final availableWidth = constraints.maxWidth;
      final imageSize = availableWidth * 0.9; // 90% of available width
      
      return Obx(() {
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
            if (!controller.showFeedback.value) {
              controller.checkAnswer(imagePath);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: borderColor,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      });
    },
  );
}}