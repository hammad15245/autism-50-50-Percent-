import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:autism_fyp/views/controllers/global_audio_services.dart';
import 'package:autism_fyp/views/controllers/progress_controller.dart';
import 'package:autism_fyp/views/controllers/nav_controller.dart';

import 'package:autism_fyp/views/screens/grid_itemscreens/Birds_module/birds_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushing_teeth_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Going-to-bed_module/goindbed_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/add_subtract_module/add_subtract_module_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/bathing_module/bathing_module_controller.dart';

import 'package:autism_fyp/views/screens/grid_itemscreens/home_animals_module/home_animal_controller.dart';

import 'package:autism_fyp/views/widget/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync(() async => AudioInstructionService());

  Get.put(ProgressController(), permanent: true);
  Get.lazyPut(() => NavController(), fenix: true);

  Get.lazyPut(() => HomeAnimalsController(), fenix: true);
  Get.lazyPut(() => GoingToBedController(), fenix: true);
  Get.lazyPut(() => BrushingTeethModuleController(), fenix: true);
  Get.lazyPut(() => BathingModuleController(), fenix: true);
  Get.lazyPut(() => BirdsModuleController(), fenix: true);
  Get.lazyPut(() => AddSubtractModuleController(), fenix: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Autism App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
