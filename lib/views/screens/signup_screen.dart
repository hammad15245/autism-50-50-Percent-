import 'package:autism_fyp/views/controllers/auth_controller.dart';
import 'package:autism_fyp/views/screens/gender_selectionscreen.dart';
import 'package:autism_fyp/views/screens/locignscreen.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.put(AuthController());
  bool _obscureText = true;
  String? selectedRole; // Track selected role
String? _passwordError;
  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth,
              height: screenHeight * 0.35,
              child: Image.asset(
                'lib/assets/png1.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                child: Column(
                  children: [
                    const Text(
                      'Create your new account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'Create an account to start',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Role Selector
                    const Text(
                      "Choose your role",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    RoleSelector(
                      onRoleSelected: (role) {
                        setState(() {
                          selectedRole = role;
                        });
                      },
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Show error if no role selected
                    if (selectedRole == null)
                      const Text(
                        'Please select a role',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    SizedBox(height: screenHeight * 0.01),

                    // Email Field
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          SizedBox(
                            child: TextField(
                              controller: authController.emailController,
                              decoration: InputDecoration(
                                hintText: 'Your Email',
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.015,
                                  horizontal: 12,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Password Field
                 SizedBox(
  width: screenWidth * 0.8,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: screenHeight * 0.01),
      TextField(
        controller: authController.passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'New Password',
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off
                  : Icons.visibility,
              size: 20,
            ),
            onPressed: _toggleVisibility,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _passwordError != null ? Colors.red : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorText: _passwordError, 
          contentPadding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.015,
            horizontal: 12,
          ),
        ),
        onChanged: (value) {
          // Clear error when user starts typing
          if (value.isNotEmpty && _passwordError != null) {
            setState(() {
              _passwordError = null;
            });
          }
        },
      ),
      // Password requirements hint
      // Padding(
      //   padding: EdgeInsets.only(top: screenHeight * 0.01),
      //   child: Text(
      //     'Password must contain:\n• At least 8 characters\n• One uppercase letter\n• One lowercase letter\n• One number\n• One special character\n• No spaces',
      //     style: TextStyle(
      //       fontSize: 12,
      //       color: Colors.grey[600],
      //     ),
      //   ),
      // ),
    ],
  ),
),

SizedBox(height: screenHeight * 0.03),

// Register Button
Obx(() => authController.isLoading.value
    ? const CircularProgressIndicator()
    : SizedBox(
        width: screenWidth * 0.8,
        height: screenHeight * 0.08,
        child: CustomElevatedButton(
          text: 'Register',
          onPressed: () {
            // Validate role selection
            if (selectedRole == null) {
              Get.snackbar(
                "Error",
                "Please select a role (Parent or Kid)",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
              return;
            }
            
            // Validate password before registration
            final password = authController.passwordController.text;
            if (!authController.validatePassword(password)) {
              setState(() {
                _passwordError = authController.passwordError.value;
              });
              return;
            }
            
            // Clear any previous error if password is valid
            setState(() {
              _passwordError = null;
            });
            
            // Call registerUser with the selected role
            authController.registerUser(selectedRole!);
          },
        ),
      )),
                    SizedBox(height: screenHeight * 0.02),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(() => const LoginScreen());
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(color: Color(0xFF0E83AD)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}