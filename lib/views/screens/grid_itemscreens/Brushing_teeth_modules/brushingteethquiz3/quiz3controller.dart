import 'package:get/get.dart';

class Quiz3answer extends GetxController {
  final Map<String, String> answers = {
    "tooth_rush": "b",
    "M_orning": "o",
    "rin_e": "n",
    "te_eth": "e",
    "tooth_aste": "p",
  };

  final Map<String, String> images = {
    "tooth_rush": "lib/assets/quiz3_icon/toothbrush.png",
    "M_orning": "lib/assets/quiz3_icon/morning.png",
    "rin_e": "lib/assets/quiz3_icon/rinse.png",
    "te_eth": "lib/assets/quiz3_icon/teeth.png",
    "tooth_aste": "lib/assets/quiz3_icon/toothpaste.png",
  };

  var userAnswers = <String, String>{}.obs; // Stores user answers
  var resultMap = <String, RxInt>{}.obs; // 1 = correct, 0 = wrong
  var savedAnswersWithResult = <String, Map<String, dynamic>>{}.obs; // Stores both answer & correctness

  var correctCount = 0.obs;

  late final Set<String> preFilledQuestions;

  Quiz3answer() {
    preFilledQuestions = answers.keys.take(2).toSet(); // First two pre-filled
  }

  void updateAnswer(String question, String value) {
    userAnswers[question] = value;
  }

  void checkAllAnswers() {
    resultMap.clear();
    savedAnswersWithResult.clear();
    int correct = 0;

    answers.forEach((question, correctAnswer) {
      String userAnswer = userAnswers[question] ?? '';

      if (preFilledQuestions.contains(question)) {
        resultMap[question] = 1.obs;
        correct++;
        savedAnswersWithResult[question] = {
          "answer": userAnswer,
          "isCorrect": true
        };
      } else {
        bool isCorrect = userAnswer.toLowerCase().trim() ==
            correctAnswer.toLowerCase().trim();
        resultMap[question] = isCorrect ? 1.obs : 0.obs;
        if (isCorrect) correct++;
        savedAnswersWithResult[question] = {
          "answer": userAnswer,
          "isCorrect": isCorrect
        };
      }
    });

    correctCount.value = correct;
  }
}
