import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'quiz5_controller.dart';

class TemplateOptionsWidget extends StatelessWidget {
  final Quiz5Controller controller = Get.find<Quiz5Controller>();

   TemplateOptionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      final options =
          controller.templateOptions[controller.selectedTemplate.value];

      final optionSize = screenWidth * 0.27; 

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(options.length, (index) {
          return GestureDetector(
            onTap: () => controller.selectOption(index),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: optionSize,
                  height: optionSize,
                  
                  decoration: BoxDecoration(
                    // borderRadius: BorderRadius.circular(8),
                 
                    border: Border.all(color: Colors.grey, width: 1),
                  ), 
                  
                  child: Image.asset(
                    height: 40,
                    width: 40,
                    options[index],
                    fit: BoxFit.cover,
                  ),
                ),

                if (controller.userAnswered.value)
                  if (controller.correctAnswers[
                          controller.selectedTemplate.value] ==
                      index)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 50)
                  else if (controller.correctAnswers[
                          controller.selectedTemplate.value] !=
                      index &&
                      controller.userAnswerCorrect.value == false)
                    const Icon(Icons.cancel,
                        color: Colors.red, size: 50),
              ],
            ),
          );
        }),
      );
    });
  }
}
