import 'package:autism_fyp/assets/local_image.dart';
import 'package:autism_fyp/views/controllers/auth_controller.dart';
import 'package:autism_fyp/views/controllers/items_controller.dart';
import 'package:autism_fyp/views/controllers/nav_controller.dart';
import 'package:autism_fyp/views/screens/leaderboard_screen.dart';
import 'package:autism_fyp/views/screens/profile_screen.dart';
import 'package:autism_fyp/views/screens/search_screen.dart';
import 'package:autism_fyp/views/widget/custom_widget.dart';
import 'package:autism_fyp/views/widget/learningpath_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LearningItemController controller = Get.put(LearningItemController());
  final AuthController authController = Get.put(AuthController());
  final NavController navController = Get.find<NavController>();

  int selectedIndex = 0;
  final List<String> categories = [
    "Animals",
    "Science",
    "Games",
    "Numbers",
    "Alphabets",
    "Emotions",
    "Fruit",
    "Daily Life",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: navController.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // First Page (Your original HomeScreen content)
          SafeArea(
            child: SingleChildScrollView(
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
                                  style: TextStyle(fontSize: screenWidth * 0.055, fontWeight: FontWeight.bold));
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
                      Icon(Icons.notifications, size: 30,),
                      SizedBox(width: 20,),
                      const ProfileCircleButton(),
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
                                  onPressed: () {},
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
                  // Choose Interests Title
                  Row(
                    children: [
                      Text(
                        'Choose Interests',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
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

                  SizedBox(
                    height: screenHeight * 0.15,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == selectedIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8.5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: screenWidth * 0.18,
                                  height: screenWidth * 0.18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF0E83AD)
                                          : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      getCategoryImage(categories[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Text(
                                  categories[index],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.032,
                                    height: 1.2,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected 
                                        ? const Color(0xFF0E83AD)
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),
                  // Popular Lessons Title
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
                        onPressed: () {},
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
                ],
              ),
            ),
          ),
          
          // Other pages will be automatically handled by the NavController
          Container(child: SearchScreen()), // Placeholder for SearchScreen
          Container(child: LeaderboardScreen()), // Placeholder for LeaderboardScreen
          Container(child: ProfileScreen()), // Placeholder for ProfileScreen
        ],
      ),
      bottomNavigationBar: CustomNav.buildCurvedLabeledNavBar(
        onItemTap: (index) {},
        barColor: Colors.white,
        backgroundColor: const Color(0xFF0E83AD),
        buttonBackgroundColor: const Color(0xFF0E83AD),
        height: screenHeight * 0.085,
      ),
    );
  }
}