// counting_module_controller.dart
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/progress_controller.dart';

class AbcLettersModuleController extends GetxController {
  final progressController = Get.find<ProgressController>();

  final String moduleId = "ABC letters";

  var quizResults = <String, Map<String, dynamic>>{}.obs;
  var wrongAnswers = <String, List<Map<String, dynamic>>>{}.obs; 

  void recordQuizResult({
    required String quizId,
    required int score,
    required int retries,
    bool isCompleted = true,
    int wrongAnswersCount = 0, // Add wrong answers count
  }) {
    quizResults[quizId] = {
      "score": score,
      "retries": retries,
      "isCompleted": isCompleted,
      "wrongAnswers": wrongAnswersCount, // Store wrong answers count
    };
  }

  // Add this method to record individual wrong answers
  void recordWrongAnswer({
    required String quizId,
    String? questionId,
    String? wrongAnswer,
    String? correctAnswer,
  }) {
    if (!wrongAnswers.containsKey(quizId)) {
      wrongAnswers[quizId] = [];
    }
    
    wrongAnswers[quizId]!.add({
      "questionId": questionId,
      "wrongAnswer": wrongAnswer,
      "correctAnswer": correctAnswer,
      "timestamp": DateTime.now(),
    });
  }

  Future<void> syncModuleProgress() async {
    for (var entry in quizResults.entries) {
      final quizId = entry.key;
      final result = entry.value;
      try {
        await progressController.updateQuizProgress(
          moduleId: moduleId,
          quizId: quizId,
          score: result["score"],
          retries: result["retries"],
          isCompleted: result["isCompleted"],
          wrongAnswers: result["wrongAnswers"] ?? 0, 
        );
        
        if (wrongAnswers.containsKey(quizId)) {
          for (var wrongAnswer in wrongAnswers[quizId]!) {
            await progressController.recordWrongAnswer(
              moduleId: moduleId,
              quizId: quizId,
              questionId: wrongAnswer["questionId"],
              wrongAnswer: wrongAnswer["wrongAnswer"],
              correctAnswer: wrongAnswer["correctAnswer"],
            );
          }
        }
      } catch (e) {
        print("❌ Failed to sync $quizId: $e");
      }
    }
    

    wrongAnswers.clear();
  }
}