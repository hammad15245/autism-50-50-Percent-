import 'package:autism_fyp/assets/local_image.dart';
import 'package:autism_fyp/views/controllers/auth_controller.dart';
import 'package:autism_fyp/views/controllers/items_controller.dart';
import 'package:autism_fyp/views/controllers/nav_controller.dart';
import 'package:autism_fyp/views/screens/leaderboard_screen.dart';
import 'package:autism_fyp/views/screens/profile_screen.dart';
import 'package:autism_fyp/views/screens/search_screen.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:autism_fyp/views/widget/homeprofile_screen.dart';
import 'package:autism_fyp/views/widget/homesearching_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.put(AuthController());
  final NavController navController = Get.find<NavController>();

  List<Map<String, dynamic>> recommendedModules = [];
  List<Map<String, dynamic>> popularModules = [];
  bool isLoading = true;

  bool showNotifications = false;
  List<String> assignedModules = [];

  @override
  void initState() {
    super.initState();
    _loadPersonalizedModules();
    _loadAssignedModules();
  }

  Future<void> _loadPersonalizedModules() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final prefsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('personalized_learning')
            .doc('preferences')
            .get();

        final modulesSnapshot = await FirebaseFirestore.instance
            .collection('learningModules')
            .get();

        final allModules = modulesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'title': data['title'] ?? doc.id,
            'data': data,
          };
        }).toList();

        if (prefsDoc.exists) {
          final preferences = prefsDoc.data()?['answers'] as Map<String, dynamic>? ?? {};
          final userInterests = List<String>.from(preferences['interests'] ?? []);

          recommendedModules = allModules.where((module) {
            final moduleTitle = module['title'].toString().toLowerCase();
            for (var interest in userInterests) {
              if (moduleTitle.contains(interest.toLowerCase())) return true;
            }
            return false;
          }).toList();

          if (recommendedModules.isEmpty) {
            recommendedModules = allModules.take(4).toList();
          }
        } else {
          recommendedModules = allModules.take(4).toList();
        }

        popularModules = allModules.take(6).toList();
      }
    } catch (e) {
      print('Error loading personalized modules: $e');
      recommendedModules = [
        {'title': 'ABC letters'},
        {'title': 'Counting'},
        {'title': 'Animals'},
        {'title': 'Colors'}
      ];
      popularModules = [
 
        {'title': 'Birds'},
        {'title': 'Home animals'},
        {'title': 'Numbers'}
      ];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadAssignedModules() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('assignedModules')
        .get();

    assignedModules = snapshot.docs.map((doc) => doc.data()['title'] as String? ?? '').toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: PageView(
            controller: navController.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SafeArea(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                          vertical: screenHeight * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: FutureBuilder<String?>(
                                    future: authController.fetchUsername(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        return Text("Error loading name",
                                            style: TextStyle(
                                                fontSize: screenWidth * 0.055,
                                                fontWeight: FontWeight.bold));
                                      } else {
                                        return RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${snapshot.data ?? ''}\n',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.055,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              TextSpan(
                                                text: 'Welcome to Dream Leap',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.04,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications, size: 30),
                                  onPressed: () {
                                    setState(() {
                                      showNotifications = !showNotifications;
                                    });
                                  },
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () => HomeprofileScreen(),
                                  child: const ProfileCircleButton(),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            // Banner
                            Container(
                              width: double.infinity,
                              height: screenHeight * 0.22,
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.02,
                                horizontal: screenWidth * 0.05,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0E83AD),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Find amazing lessons for your kid',
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.015),
                                        SizedBox(
                                          width: screenWidth * 0.35,
                                          child: ElevatedButton(
                                            onPressed: () => Get.to(HomesearchingScreen()),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF0E83AD),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: screenHeight * 0.012,
                                              ),
                                            ),
                                            child: Text(
                                              'Find now',
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Image.asset(
                                      'lib/assets/2.png',
                                      height: screenHeight * 0.13,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // Recommended For You Section
                            Row(
                              children: [
                                Text(
                                  'Recommended For You',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => navController.pageController.jumpToPage(1),
                                  child: Text(
                                    'View all',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: const Color(0xFF0E83AD),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // Recommended Modules Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recommendedModules.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                              ),
                              itemBuilder: (context, index) {
                                final module = recommendedModules[index];
                                final title = module['title'].toString();
                                return _buildModuleCard(title, index, context);
                              },
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // Popular Lessons Section
                            Row(
                              children: [
                                Text(
                                  'Popular Lessons',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => HomesearchingScreen(),
                                  child: Text(
                                    'View all',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: const Color(0xFF0E83AD),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.015),

                            // Popular Modules Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: popularModules.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.9,
                              ),
                              itemBuilder: (context, index) {
                                final module = popularModules[index];
                                final title = module['title'].toString();
                                return _buildModuleCard(title, index, context);
                              },
                            ),
                          ],
                        ),
                      ),
              ),

              Container(child: SearchScreen()),
              Container(child: LeaderboardScreen()),
              Container(child: ProfileScreen()),
            ],
          ),
          bottomNavigationBar: CustomNav.buildCurvedLabeledNavBar(
            onItemTap: (index) => navController.pageController.jumpToPage(index),
            barColor: Colors.white,
            backgroundColor: const Color(0xFF0E83AD),
            buttonBackgroundColor: const Color(0xFF0E83AD),
            height: screenHeight * 0.085,
          ),
        ),

        // Notification Popup
        if (showNotifications)
          Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => setState(() => showNotifications = false),
                  child: Container(color: Colors.black38),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80, right: 16),
                    padding: const EdgeInsets.all(16),
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Assigned Modules',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        if (assignedModules.isEmpty)
                          const Text('No new assignments')
                        else
                          ...assignedModules.map(
                            (module) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle_outline, size: 20, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(module)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildModuleCard(String moduleTitle, int index, BuildContext context) {
    return GestureDetector(
      onTap: () => navigateToItemScreen(moduleTitle, context),
      child: Container(
        decoration: BoxDecoration(
          color: _getCardColor(index),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              getImageForTitle(moduleTitle),
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              moduleTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor(int index) {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFEBEE),
      const Color(0xFFF3E5F5),
      const Color(0xFFE0F7FA),
      const Color(0xFFFFF8E1),
      const Color(0xFFE8EAF6),
      const Color(0xFFF1F8E9),
    ];
    return colors[index % colors.length];
  }
}
