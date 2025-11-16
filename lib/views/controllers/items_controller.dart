
import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/quiz1/quiz1_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushingteeth_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth/brushingteeth_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/quiz1/quiz1_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/quiz1/quiz1_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/quiz1/quiz1_screen.dart';

import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/quiz1/quiz1_screen.dart';
import 'package:autism_fyp/views/widget/items_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../screens/grid_itemscreens/wakeup_module/quiz1/quiz1_screen.dart';

class LearningItemController extends GetxController {
  final items = <LearningItem>[].obs;
  final isLoading = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchLearningItems() async {
    try {
      isLoading.value = true;
      items.value = [];

      final querySnapshot = await _firestore
          .collection('learningModules')
          .get();

      items.value = querySnapshot.docs
          .map((doc) => LearningItem.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      print("Error fetching learning items: $e");
    } finally {
      isLoading.value = false;
    }
  }

}

// class popularItemscontroller extends GetxController {
//   final popularItems = <LearningItem>[].obs;
//   final isLoading = false.obs;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Future<void> fetchPopularItems(dynamic isPopularLoading) async {
//   try {
//     isPopularLoading.value = true;
//     popularItems.value = [];

//     final querySnapshot = await _firestore
//         .collection('learningModules')
//         .where('popularid', isNotEqualTo: '')
//         .orderBy('popularid')
//         .limit(4)
//         .get();

//     popularItems.value = querySnapshot.docs
//         .map((doc) => LearningItem.fromFirestore(doc.data())) // No cast needed
//         .toList();
//   } catch (e) {
//     print("Error fetching popular items: $e");
//     Get.snackbar('Error', 'Failed to load popular items');
//   } finally {
//     isPopularLoading.value = false;
//   }
// }
// }


void navigateToItemScreen(String title, BuildContext context) {
  switch (title.toLowerCase().trim()) {
  case 'brushing teeth':
      Get.to(() => const BrushingteethScreen());
      
      break;

      case 'bathing':
      Get.to(() => const BathTimeItemsScreen());
      break;
   
 
          case 'going to bed':
      Get.to(() =>  Bedtimescreen());
      break;
          case 'time to wake up':
      Get.to(() =>  wakeupscreen());
      break;
           case 'addition and subtraction':
      Get.to(() =>  FruitMathscreen());
      break;
          case 'birds':
      Get.to(() =>  BirdSoundscreen());
      break;
          case 'home animals':
      Get.to(() =>  animalsortingscreen());
      break;
 
     
      
      
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson not found')),
      );
  }
}





