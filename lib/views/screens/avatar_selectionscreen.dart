import 'package:autism_fyp/views/controllers/personalized_learning.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  int? selectedIndex;
  final List<String> avatarAssets = [
    'lib/assets/avatars/avatar1.png',
    'lib/assets/avatars/avatar2.png',
    'lib/assets/avatars/avatar3.png',
    'lib/assets/avatars/avatar4.png',
    'lib/assets/avatars/avatar5.png',
    'lib/assets/avatars/avatar6.png',
    'lib/assets/avatars/female1.png',
    'lib/assets/avatars/female2.png',
    'lib/assets/avatars/female3.png',
    'lib/assets/avatars/female4.png',
  ];

  Future<void> _saveAvatarToFirestore(String avatarPath) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'avatar': avatarPath,
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save avatar: $e");
    }
  }

  Future<bool> _checkUserPreferences(String userId) async {
    try {
      // Check if user has completed preferences flag
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      final hasCompletedPrefs = userDoc.data()?['hasCompletedPreferences'] ?? false;
      
      // If already completed, no need to show questions
      if (hasCompletedPrefs) {
        return true;
      }

      // Check if personalized_learning document exists
      final prefsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('personalized_learning')
          .doc('preferences')
          .get();

      return prefsDoc.exists;
    } catch (e) {
      print('Error checking preferences: $e');
      return false;
    }
  }

  Future<void> _navigateAfterAvatarSelection() async {
    if (selectedIndex != null) {
      final avatarPath = avatarAssets[selectedIndex!];
      await _saveAvatarToFirestore(avatarPath);
      
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final hasPreferences = await _checkUserPreferences(userId);
        
        if (hasPreferences) {
          // User has already completed preferences, go to home screen
          Get.offAll(() => const HomeScreen());
        } else {
          // User hasn't completed preferences, go to questions screen
          Get.offAll(() => const PersonalizationQuestionsScreen(isFirstTime: true));
        }
      } else {
        Get.offAll(() => const HomeScreen());
      }
    } else {
      Get.snackbar("Select Avatar", "Please select an avatar");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.03,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    "Back",
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05),
                      child: Text(
                        'Choose your favorite avatar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.06,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            // Avatar Grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(screenWidth * 0.06),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 1,
                ),
                itemCount: avatarAssets.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedIndex == index
                              ? const Color(0xFF0E83AD)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          avatarAssets[index],
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 5),
            
            // Continue button
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.08,
                  child: CustomElevatedButton(
                    text: "Continue",
                    onPressed: _navigateAfterAvatarSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E83AD),
                      foregroundColor: Colors.white,
                      textStyle: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}