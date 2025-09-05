import 'package:autism_fyp/views/screens/grid_itemscreens/ABC_letters_modules/quiz2/quiz2_controller.dart';
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: size.width * 0.05,
          mainAxisSpacing: size.height * 0.02,
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
                      color: Colors
                          .primaries[index % Colors.primaries.length]
                          .shade300,
                    ),
                    child: Center(
                      child: Text(
                        controller.options[index],
                        style: TextStyle(
                          fontSize: size.width * 0.1,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (answer == false)
                    const Icon(Icons.close, color: Colors.red, size: 100),
                  if (answer == true)
                    const Icon(Icons.check, color: Colors.green, size: 100),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}
