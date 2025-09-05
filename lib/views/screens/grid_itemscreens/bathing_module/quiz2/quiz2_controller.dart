import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BathingSequenceController extends GetxController {
  final List<String> correctStepOrder = [
    "Turn on water",
    "Get undressed", 
    "Get in tub",
    "Wash with soap",
    "Rinse off", 
    "Dry with towel",
    "Get dressed"
  ].obs;


  var stepData = [
    {"step": "Turn on water", "description": "Start with warm water"},
    {"step": "Get undressed", "description": "Take off clothes"},
    {"step": "Get in tub", "description": "Step into bathtub"},
    {"step": "Wash with soap", "description": "Use soap to clean body"},
    {"step": "Rinse off", "description": "Wash off all soap"},
    {"step": "Dry with towel", "description": "Dry yourself completely"},
    {"step": "Get dressed", "description": "Put on clean clothes"}
  ].obs;

  var currentSequence = <Map<String, String>>[].obs;
  
  var isSequenceCorrect = false.obs;
  var showCompletion = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSequences();
  }

  void _initializeSequences() {
    print("Initializing sequences...");
    
    // Start with shuffled order
    currentSequence.assignAll(List.from(stepData)..shuffle());
    
  
  }

  void shuffleSequence() {
    currentSequence.clear();
    currentSequence.addAll(List.from(stepData)..shuffle());
    isSequenceCorrect.value = false;
    showCompletion.value = false;
  }

  void checkallanswerandnavigate() {
  
    if (!_areSequencesValid()) {
      return;
    }
    
    _performSequenceCheck();
  }

  bool _areSequencesValid() {
    if (correctStepOrder.isEmpty) {
      _showErrorSnackbar("Configuration error: No sequence data available");
      return false;
    }
    
    if (currentSequence.isEmpty) {
      _showErrorSnackbar("Please arrange the steps first");
      return false;
    }
    
    if (currentSequence.length != correctStepOrder.length) {
      _showErrorSnackbar("Please complete all steps in the sequence");
      return false;
    }
    
    return true;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "Error", 
      message,
      backgroundColor: Colors.red.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

void _performSequenceCheck() {
  List<String> currentStepOrder = currentSequence
      .map((step) => (step["step"] ?? "").trim().toLowerCase())
      .toList();

  List<String> correctOrder = correctStepOrder
      .map((e) => e.trim().toLowerCase())
      .toList();

  print("Correct: $correctOrder");
  print("Current: $currentStepOrder");

  bool isCorrect = listEquals(currentStepOrder, correctOrder);

  isSequenceCorrect.value = isCorrect;
  showCompletion.value = true;

  if (isCorrect) {

    Future.delayed(const Duration(seconds: 5), () {
      Get.off(() => CleanDirtyScreen()); // or Get.to if you want back navigation
    });

  } else {
    Get.snackbar(
      "Almost there!",
      "Try again to get the order right",
      backgroundColor: Colors.orange.shade300,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
}

  void reorderItems(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= currentSequence.length ||
        newIndex < 0 || newIndex > currentSequence.length) {
      return;
    }
    
    if (oldIndex < newIndex) newIndex -= 1;
    final item = currentSequence.removeAt(oldIndex);
    currentSequence.insert(newIndex, item);
    
    print("Reordered. New sequence: ${currentSequence.map((e) => e["step"]).toList()}");
  }

  void manualCheckSequence() {
    checkallanswerandnavigate();
  }

  bool get allStepsCorrect => isSequenceCorrect.value;
}