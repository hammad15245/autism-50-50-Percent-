import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/progress_controller.dart';

class HomeAnimalsController extends GetxController {
  final progressController = Get.find<ProgressController>();

  final String moduleId = "home animals"; // home_animals

  var quizResults = <String, Map<String, dynamic>>{}.obs;

  void recordQuizResult({
    required String quizId,
    required int score,
    required int retries,
    bool isCompleted = true,
  }) {
    quizResults[quizId] = {
      "score": score,
      "retries": retries,
      "isCompleted": isCompleted,
    };
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
        );
      } catch (e) {
        print("❌ Failed to sync $quizId: $e");
      }
    }
  }
}
