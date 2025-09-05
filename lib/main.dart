import 'package:autism_fyp/views/controllers/global_audio_services.dart';
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