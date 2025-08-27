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
  int? selectedIndex; // tracks which avatar is selected

  // Add your avatar asset paths here
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
          'avatar': avatarPath, // 🔵 save avatar under field "avatar"
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save avatar: $e");
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
            //   SizedBox(height: screenHeight * 0.03),
            // Text(
            //   'Choose your Favorite Avatar',
            //   style: TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: screenWidth * 0.06,
            //   ),
            // ),
            // const Spacer(),
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

      SizedBox(height: screenHeight * 0.02),

      // Avatar Grid (this scrolls itself)
      Expanded(
        child: GridView.builder(
          padding: EdgeInsets.all(screenWidth * 0.05),
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
      width: 100,  // adjust size
      height: 100, // adjust size
    ),
  ),
),

            );
          },
        ),
      ),

      // Continue button
        Center(
          child: SizedBox(
        width: screenWidth * 0.65,
        height: screenHeight * 0.08,
        child: CustomElevatedButton(
          text: "Continue",
          onPressed: () async {
            if (selectedIndex != null) {
              final avatarPath = avatarAssets[selectedIndex!];
              await _saveAvatarToFirestore(avatarPath);
              Get.offAll(() => const HomeScreen());
            } else {
              Get.snackbar("Select Avatar", "Please select an avatar");
            }
          },
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
      
    

    ],
  ),
),

      );
    
  }
}
