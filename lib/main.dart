import 'package:autism_fyp/views/controllers/auth_controller.dart';
import 'package:autism_fyp/views/controllers/firebase_progress.dart';
import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/controllers/progress_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/goindbed_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/counting_module/counting_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/eating_food_module/eating_food_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/home_animal_controller.dart';
import 'package:autism_fyp/views/screens/locignscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:autism_fyp/views/controllers/nav_controller.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
await Get.putAsync(() async => AudioInstructionService());

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    Get.lazyPut(() => NavController(), fenix: true); 
  // Get.put(AuthController());
  // Get.put(FirebaseService()); // ← Add this line
  // Get.put(ProgressController());
  Get.put(ProgressController(), permanent: true);
      Get.lazyPut(() => HomeAnimalsController(), fenix: true);
    Get.lazyPut(() => GoingToBedController(), fenix: true);
    Get.lazyPut(() => EatingFoodController(), fenix: true);
      Get.lazyPut(() => CountingModuleController(), fenix: true);


    return GetMaterialApp(
      title: 'Autism App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: LoginScreen(),
    );
  }
}

