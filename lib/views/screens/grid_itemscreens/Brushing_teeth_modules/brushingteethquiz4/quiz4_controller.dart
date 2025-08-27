import 'package:get/get.dart';

class Quiz4Controller extends GetxController {
  // Images for left and right columns



  // Correct answers mapping: key = leftIndex, value = rightIndex
  final Map<int, int> correctPairs = {
    0: 3,
    1: 0,
    2: 1,
    3: 2,
    4: 4,
  };

  // User selected matches: key = leftIndex, value = rightIndex
  var userPairs = <int, int>{}.obs;

  // For feedback: 0 = no feedback, 1 = correct, -1 = incorrect
  var feedback = <int, int>{}.obs;

  // Correct answers count
  var correctCount = 0.obs;

  // Allow screen to call .answers.length
  Map<int, int> get answers => userPairs;

var isChecking = false.obs;

  void selectMatch(int leftIndex, int rightIndex) {
    userPairs[leftIndex] = rightIndex;
  }
void checkAnswers()  {
  correctCount.value = 0;
  feedback.clear();

  userPairs.forEach((left, right) {
    if (correctPairs[left] == right) {
      feedback[left] = 1; // Correct
      correctCount.value++;
    } else {
      feedback[left] = -1; // Incorrect
    }
  });
}


  void resetQuiz() {
    userPairs.clear();
    feedback.clear();
    correctCount.value = 0;
  }
}
