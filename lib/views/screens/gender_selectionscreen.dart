import 'package:autism_fyp/views/controllers/auth_controller.dart';
import 'package:autism_fyp/views/screens/avatar_selectionscreen.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final AuthController authController = Get.put(AuthController());

  String? selectedGender;
  bool _isLoading = false;

  Future<void> _saveUserData() async {
    final username = _usernameController.text.trim();
    final age = authController.ageController.text.trim();

    if (username.isEmpty || selectedGender == null || age.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    try {
      setState(() => _isLoading = true);
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'gender': selectedGender,
          'age': age,
        }, SetOptions(merge: true));
      }

      Get.off(() => const AvatarSelectionScreen());
      Get.snackbar("Success", "Data saved successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to save data");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.black, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.02,
        horizontal: screenWidth * 0.04,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.03,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios,
                          color: Colors.black, size: screenWidth * 0.06),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Back",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // title
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Text(
                          'Please fill in the true information',
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

              SizedBox(height: screenHeight * 0.03),

              // gender squares
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GenderSquare(
                        label: "Boy",
                        color: const Color(0xFF2196F3),
                        isSelected: selectedGender == "male",
                        imagePath: "lib/assets/male.png",
                        onTap: () => setState(() => selectedGender = "male"),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Flexible(
                      child: GenderSquare(
                        label: "Girl",
                        color: Colors.redAccent,
                        isSelected: selectedGender == "female",
                        imagePath: "lib/assets/female.png",
                        onTap: () => setState(() => selectedGender = "female"),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // nickname + age fields
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    child: TextField(
                      controller: _usernameController,
                      style: TextStyle(fontSize: screenWidth * 0.041),
                      decoration: inputDecoration.copyWith(
                        hintText: "Please enter nickname for your child?",
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    child: TextField(
                      controller: authController.ageController,
                      style: TextStyle(fontSize: screenWidth * 0.041),
                      decoration: inputDecoration.copyWith(
                        hintText: "Age of your child?",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.07),

              // continue button
              Center(
                child: SizedBox(
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.08,
                  child: CustomElevatedButton(
                    text: _isLoading ? "" : "Continue",
                    onPressed: _isLoading ? () {} : _saveUserData,
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

              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Center(
                    child: SizedBox(
                      height: screenHeight * 0.03,
                      width: screenHeight * 0.03,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderSquare extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final String imagePath;
  final VoidCallback onTap;

  const GenderSquare({
    Key? key,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.22,
        width: screenWidth * 0.38,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 5,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          
            ],
          ),
        ),
      ),
    );
  }
}
