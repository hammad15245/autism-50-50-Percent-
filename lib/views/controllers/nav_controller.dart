// nav_controller.dart
import 'dart:io';

import 'package:autism_fyp/views/screens/gender_selectionscreen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz3/quiz3_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz4/quiz4_screen.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/Brushing_teeth_modules/brushingteethquiz5/quiz5_screen.dart';
import 'package:autism_fyp/views/screens/leaderboard_screen.dart';
import 'package:autism_fyp/views/screens/profile_screen.dart';
import 'package:autism_fyp/views/screens/signup_screen.dart';
import 'package:autism_fyp/views/screens/username_selectionscreen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:autism_fyp/views/screens/search_screen.dart';
class NavController extends GetxController {
  final RxInt currentIndex = 0.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: currentIndex.value);
  }

  List<Widget> get pages => [
    HomeScreen(),
    SearchScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  List<CurvedNavigationBarItem> get items => [
    CurvedNavigationBarItem(
      child: Icon(Icons.home_outlined, size: 30, 
          color: currentIndex.value == 0 ? Colors.white : const Color(0xFF0E83AD)),
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.search_outlined, size: 30, 
          color: currentIndex.value == 1 ? Colors.white : const Color(0xFF0E83AD)),
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.leaderboard_outlined, size: 30, 
          color: currentIndex.value == 2 ? Colors.white : const Color(0xFF0E83AD)),
    ),
    CurvedNavigationBarItem(
      child: Icon(Icons.person_outline, size: 30, 
          color: currentIndex.value == 3 ? Colors.white : const Color(0xFF0E83AD)),
    ),
  ];

  static void initialize() {
    Get.lazyPut<NavController>(() => NavController());
  }

  void onItemSelected(int index) {
    if (currentIndex.value == index) return;
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}