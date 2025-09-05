import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/quiz4/quiz4_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';

class HealthyChoicesController extends GetxController {
  var availableItems = <Map<String, dynamic>>[].obs;
  var cleanItems = <Map<String, dynamic>>[].obs;
  var dirtyItems = <Map<String, dynamic>>[].obs;
  var showCompletion = false.obs;
  var feedbackMessage = "".obs; // For showing feedback

  final FlutterTts tts = FlutterTts();

  @override
  void onInit() {
    super.onInit();
    _loadItems();
    _speakInstructions();
  }

  void _loadItems() {
    availableItems.value = [
      {"name": "Apple", "icon": "lib/assets/quiz3_cleansorting/apple.png", "type": "clean"},
      {"name": "Banana Peel", "icon": "lib/assets/quiz3_cleansorting/banana.png", "type": "dirty"},
      {"name": "Cookie", "icon": "lib/assets/quiz3_cleansorting/cookie.png", "type": "clean"},
      {"name": "Dirty Burger", "icon": "lib/assets/quiz3_cleansorting/burger.png", "type": "dirty"},
      {"name": "Melted Cake", "icon": "lib/assets/quiz3_cleansorting/cake.png", "type": "dirty"},
      {"name": "Vegetables", "icon": "lib/assets/quiz3_cleansorting/bowl.png", "type": "clean"},
    ];
  }

  void _speakInstructions() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);
    await tts.speak(
        "Drag the items into any basket you want. Try sorting them correctly. Clean items go into the Clean basket, and dirty items go into the Dirty basket.");
  }

  /// Place item in chosen basket freely, but provide feedback
  void placeInBasket(String basketName, Map<String, dynamic> item) {
    availableItems.remove(item);

    if (basketName == "Clean") cleanItems.add(item);
    if (basketName == "Dirty") dirtyItems.add(item);

    // Provide feedback for learning
    if (basketName.toLowerCase() == item["type"].toString().toLowerCase()) {
      feedbackMessage.value = "Correct! ✅";
    } else {
      feedbackMessage.value = "Oops! Wrong basket. ❌";
    }

    if (availableItems.isEmpty) {
      showCompletion.value = true;
    }
  }


    void checkAnswerAndNavigate() {
     
      // Navigate to the next screen
      Get.to(() => const HealthyTreatscreen());
      

    
}
  void resetGame() {
    cleanItems.clear();
    dirtyItems.clear();
    showCompletion.value = false;
    feedbackMessage.value = "";
    _loadItems();
    _speakInstructions();
  }
}
