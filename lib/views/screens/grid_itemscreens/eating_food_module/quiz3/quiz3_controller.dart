import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/eating_food_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';

class HealthyChoicesController extends GetxController {
  var availableItems = <Map<String, dynamic>>[].obs;
  var cleanItems = <Map<String, dynamic>>[].obs;
  var dirtyItems = <Map<String, dynamic>>[].obs;
  var showCompletion = false.obs;
  var feedbackMessage = "".obs;
  var score = 0.obs;
  var retries = 0.obs;
  var wrongAnswersCount = 0.obs;
  var totalItems = 0.obs;

  // Track locked items (correctly placed items that can't be moved)
  var lockedItems = <String>[].obs;

  final audioService = AudioInstructionService.to;
  final eatingFoodController = Get.find<EatingFoodController>();

  RxString get instructionText => audioService.instructionText;
  RxBool get isSpeaking => audioService.isSpeaking;

  @override
  void onInit() {
    super.onInit();
    resetGame();
    
    Future.delayed(Duration.zero, () {
      audioService.setInstructionAndSpeak(
        "kiddos lets Drag the items into any basket you want. Try sorting them correctly. Clean items go into the Clean basket, and dirty items go into the Dirty basket.",
      );
    });
  }

  void resetGame() {
    cleanItems.clear();
    dirtyItems.clear();
    showCompletion.value = false;
    feedbackMessage.value = "";
    score.value = 0;
    wrongAnswersCount.value = 0;
    lockedItems.clear(); // Clear locked items on reset

    availableItems.value = [
      {"name": "Apple", "icon": "lib/assets/quiz3_cleansorting/apple.png", "type": "clean"},
      {"name": "Banana Peel", "icon": "lib/assets/quiz3_cleansorting/banana.png", "type": "dirty"},
      {"name": "Cookie", "icon": "lib/assets/quiz3_cleansorting/cookie.png", "type": "clean"},
      {"name": "Dirty Burger", "icon": "lib/assets/quiz3_cleansorting/burger.png", "type": "dirty"},
      {"name": "Melted Cake", "icon": "lib/assets/quiz3_cleansorting/cake.png", "type": "dirty"},
      {"name": "Vegetables", "icon": "lib/assets/quiz3_cleansorting/bowl.png", "type": "clean"},
    ];

    totalItems.value = availableItems.length;
  }

  /// Check if an item is locked (correctly placed and can't be moved)
  bool isItemLocked(String itemName) {
    return lockedItems.contains(itemName);
  }

  /// Place item in chosen basket freely, but provide feedback
  void placeInBasket(String basketName, Map<String, dynamic> item) {
    // Check if item is already locked (placed correctly)
    if (isItemLocked(item["name"])) {
      return; // Don't allow moving locked items
    }

    availableItems.remove(item);

    if (basketName == "Clean") cleanItems.add(item);
    if (basketName == "Dirty") dirtyItems.add(item);

    // Provide feedback for learning
    final isCorrect = basketName.toLowerCase() == item["type"].toString().toLowerCase();
    
    if (isCorrect) {
      score.value++;
      
      // Lock the item in place when placed correctly
      lockedItems.add(item["name"]);
      
      feedbackMessage.value = "Correct! ✅";
      audioService.playCorrectFeedback();
      audioService.setInstructionAndSpeak(
        "Good job! ${item["name"]} belongs in the $basketName basket.",
      );
    } else {
      wrongAnswersCount.value++;
      feedbackMessage.value = "Oops! Wrong basket. ❌";
      audioService.playIncorrectFeedback();
      
      // Record the wrong answer
      eatingFoodController.recordWrongAnswer(
        quizId: "quiz3",
        questionId: item["name"],
        wrongAnswer: basketName,
        correctAnswer: item["type"] == "clean" ? "Clean" : "Dirty",
      );
      
      audioService.setInstructionAndSpeak(
        "${item["name"]} should go in the ${item["type"] == "clean" ? "Clean" : "Dirty"} basket.",
      );
      
      // Return incorrect items to available foods after a delay
      Future.delayed(Duration(seconds: 2), () {
        if (!isItemLocked(item["name"])) { // Only return if not locked
          removeFromBasket(basketName, item);
        }
      });
    }

    checkCompletion();
  }

  void checkCompletion() {
    if (availableItems.isEmpty) {
      showCompletion.value = true;
      completeQuiz();
    }
  }

  void completeQuiz() {
    final correctCount = score.value;
    final total = totalItems.value;

    // Calculate final score (each correct placement = 1 point)
    final earnedScore = correctCount;
    final isPassed = earnedScore >= (total * 0.7); // 70% to pass

    // Record quiz result
    eatingFoodController.recordQuizResult(
      quizId: "quiz3",
      score: earnedScore,
      retries: retries.value,
      isCompleted: isPassed,
      wrongAnswersCount: wrongAnswersCount.value,
    );
    
    // Sync with Firestore
    eatingFoodController.syncModuleProgress();

    if (correctCount == total) {
      audioService.setInstructionAndSpeak(
        "Perfect! You sorted all $total items correctly!",
      );
    } else if (isPassed) {
      audioService.setInstructionAndSpeak(
        "Good job! You got $correctCount out of $total correct.",
      );
    } else {
      audioService.setInstructionAndSpeak(
        "Good try! You got $correctCount out of $total correct. Let's practice more.",
      );
    }
  }

  void retryQuiz() {
    retries.value++;
    resetGame();
    
    audioService.setInstructionAndSpeak(
      "Let's try again! Drag each item to the correct basket.",
    );
  }

  void checkAnswerAndNavigate() {
    if (showCompletion.value) {
      Get.to(() => const HealthyTreatscreen());
    }
  }

  // Remove item from basket and return to available items
  void removeFromBasket(String basketName, Map<String, dynamic> item) {
    // Don't remove locked items
    if (isItemLocked(item["name"])) {
      return;
    }

    if (basketName == "Clean") {
      cleanItems.remove(item);
    } else if (basketName == "Dirty") {
      dirtyItems.remove(item);
    }
    
    availableItems.add(item);
    
    // Adjust score if it was a correct item
    final wasCorrect = basketName.toLowerCase() == item["type"].toString().toLowerCase();
    if (wasCorrect) {
      score.value--;
    }
  }

  @override
  void onClose() {
    audioService.stopSpeaking();
    super.onClose();
  }
}