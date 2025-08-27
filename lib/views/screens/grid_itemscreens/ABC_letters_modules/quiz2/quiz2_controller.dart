import 'package:get/get.dart';

class BubbleQuizController extends GetxController {
var answers = <int, bool?>{}.obs; 
  var hasAnswered = false.obs;

  final List<String> options = ["A", "1", "B", "2", "C", "3"];
  final List<String> correctAnswers = ["A", "B", "C"];

  void initializeAnswers() {
answers.value = { for (var i = 0; i < options.length; i++) i: null };
    hasAnswered.value = false;
  }

  void selectAnswer(int index) {
    if (hasAnswered.value) return;

    final isCorrect = correctAnswers.contains(options[index]);
    answers[index] = isCorrect;
    hasAnswered.value = true;
  }

  bool isCorrectAnswer(int index) {
    return answers[index] == true;
  }

  bool isWrongAnswer(int index) {
    return answers[index] == false;
  }
}
