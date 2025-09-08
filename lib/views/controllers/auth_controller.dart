import 'package:autism_fyp/views/controllers/progress_controller.dart';
import 'package:autism_fyp/views/screens/gender_selectionscreen.dart';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:autism_fyp/views/screens/locignscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final usernamecontroller = TextEditingController();
  final passwordController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final emailController = TextEditingController();

  var isLoading = false.obs;
  var passwordError = ''.obs;

  bool validatePassword(String password) {
    passwordError.value = '';

    if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters long';
      return false;
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      passwordError.value = 'Password must contain at least one uppercase letter';
      return false;
    }
    
    if (!password.contains(RegExp(r'[a-z]'))) {
      passwordError.value = 'Password must contain at least one lowercase letter';
      return false;
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      passwordError.value = 'Password must contain at least one number';
      return false;
    }
    
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      passwordError.value = 'Password must contain at least one special character';
      return false;
    }
    
    if (password.contains(RegExp(r'\s'))) {
      passwordError.value = 'Password cannot contain spaces';
      return false;
    }
    
    return true;
  }

  // ------------------- REGISTER -------------------
Future<void> registerUser(String selectedRole) async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final age = ageController.text.trim();
  final gender = genderController.text.trim();
  final username = usernamecontroller.text.trim();

  if (!validatePassword(password)) {
    Get.snackbar(
      "Password Error",
      passwordError.value,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  try {
    isLoading.value = true;

    UserCredential userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String uid = userCred.user!.uid;
    final String collectionName =
        selectedRole.toLowerCase() == 'parent' ? 'parents' : 'users';

    // Prepare user data
    final Map<String, dynamic> userData = {
      "uid": uid,
      "email": email,
      "age": age,
      "gender": gender,
      "username": username,
      "role": selectedRole.toLowerCase(),
      "avatar": null,
      "createdAt": FieldValue.serverTimestamp(),
    };

    // Save user data
    await _firestore.collection(collectionName).doc(uid).set(userData);
    ProgressController.to.createInitialProgress();

    if (selectedRole.toLowerCase() == "users") {
      final progressRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc('overview');

      final progressData = {
        "totalScore": 0,
        "completedModules": [],
        "lastUpdated": FieldValue.serverTimestamp(),
      };

      await progressRef.set(progressData);
    }

    Get.offAll(() => const LoginScreen());
    Get.snackbar("Success", "Account created successfully as $selectedRole!");
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    if (e.code == 'weak-password') {
      errorMessage = "The password provided is too weak.";
    } else if (e.code == 'email-already-in-use') {
      errorMessage = "This email is already registered.";
    } else {
      errorMessage = e.message ?? "An error occurred";
    }

    Get.snackbar(
      "Registration Failed",
      errorMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } catch (e) {
    Get.snackbar(
      "Registration Failed",
      "An unexpected error occurred",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}
  // ------------------- LOGIN -------------------
  Future<void> loginUser() async {
    final email = usernamecontroller.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar("Error", "Email and Password cannot be empty",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId == null) {
        Get.snackbar("Error", "Something went wrong",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Check both collections
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final parentDoc = await _firestore.collection('parents').doc(userId).get();

      if (parentDoc.exists) {
        // PARENT DETECTED - BLOCK ACCESS
        await _auth.signOut(); // Sign them out immediately
        Get.snackbar(
          "👨‍👩‍👧‍👦 Parent Account",
          "Parent dashboard is available on our website. Please visit website for parent features.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        return;
      }

      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final hasGender = userData.containsKey('gender') && userData['gender'] != null;
        final hasAvatar = userData.containsKey('avatar') && userData['avatar'] != null;

        if (hasGender && hasAvatar) {
          Get.offAll(() => const HomeScreen());
        } else {
          Get.offAll(() => const GenderSelectionScreen());
        }
      } else {
        // User doesn't exist in either collection
        await _auth.signOut();
        Get.snackbar("Error", "User data not found",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        Get.snackbar("Login Failed", "Invalid email or password",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar("Login Failed", e.message ?? "An error occurred",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Login Failed", "An unexpected error occurred",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // ------------------- LOGOUT -------------------
  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed("/login");
  }

  // ------------------- FETCH USER -------------------
  Future<String?> fetchUsername() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['username'] as String?;
    }
    return null;
  }

  // ------------------- SAVE USERNAME -------------------
  Future<void> saveUsername(String username) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
    }, SetOptions(merge: true));
  }

  // ------------------- SAVE AVATAR -------------------
  Future<void> saveAvatar(String avatarPath) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'avatar': avatarPath,
    });
  }

  fetchUserProfile() {}
}