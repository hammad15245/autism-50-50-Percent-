import 'package:autism_fyp/views/controllers/nav_controller.dart';
import 'package:autism_fyp/views/screens/grid_itemscreens/avatar_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle? style;

  const CustomElevatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style ??
          ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white, 
          fontWeight: FontWeight.w500,
        ),
        foregroundColor: Colors.white, 
        backgroundColor: const Color(0xFF0E83AD),
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
          ),
      child: Text(text),
    );
  }


}class RoleSelector extends StatefulWidget {
  const RoleSelector({Key? key, required this.onRoleSelected}) : super(key: key);

  final void Function(String role) onRoleSelected;

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String? selectedRole; // null means nothing selected by default

  void _selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
    widget.onRoleSelected(role);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _roleOption(
            label: 'Kid',
            icon: Icons.child_care,
            isSelected: selectedRole == 'Kid',
            onTap: () => _selectRole('Kid'),
            selectedColor: const Color(0xFF0E83AD),
          ),
          const SizedBox(width: 16),
          _roleOption(
            label: 'Parent',
            icon: Icons.family_restroom,
            isSelected: selectedRole == 'Parent',
            onTap: () => _selectRole('Parent'),
            selectedColor: const Color(0xFF0E83AD),
          ),
        ],
      ),
    );
  }

  Widget _roleOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color selectedColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? selectedColor : Colors.grey.shade300,
              width: 2,
            ),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? selectedColor : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: isSelected ? selectedColor : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCircleButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPressed;

  const ProfileCircleButton({
    Key? key,
    this.size = 45.0,
    this.onPressed,
  }) : super(key: key);

  @override
  State<ProfileCircleButton> createState() => _ProfileCircleButtonState();
}

class _ProfileCircleButtonState extends State<ProfileCircleButton> {
  Future<String?> _fetchAvatarPath() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return doc.data()?['avatar'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _fetchAvatarPath(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: const Color(0xFF0E83AD),
            child: const CircularProgressIndicator(color: Colors.white),
          );
        }

        final avatarPath = snapshot.data;
        return GestureDetector(
          onTap: widget.onPressed,
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundImage: (avatarPath != null && avatarPath.isNotEmpty)
                ? AssetImage(avatarPath) 
                : const AssetImage('assets/images/default_avatar.png'),
            backgroundColor: const Color(0xFF0E83AD),
          ),
        );
      },
    );
  }
}


// class CustomBottomNavBar extends StatefulWidget {
//   const CustomBottomNavBar({super.key});

//   @override
//   State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
// }

// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   int _selectedIndex = 0;

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   Widget _buildNavItem(IconData icon, int index) {
//     bool isSelected = _selectedIndex == index;

//     return GestureDetector(
//       onTap: () => _onItemTapped(index),
//       child: isSelected
//           ? Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.grey.shade400,
//                 ),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF0E83AD),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: Colors.white, size: 25),
//               ),
//             )
//           : Icon(icon, color: const Color(0xFF0E83AD), size: 30),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BottomAppBar(
//       shape: const CircularNotchedRectangle(),
//       notchMargin: 10,
//       color: Colors.white,
//       elevation: 50,
//       child: SizedBox(
//         height: 85,
//         child: Padding(
//           padding: const EdgeInsets.only(bottom: 15),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildNavItem(Icons.home_outlined, 0),
//               _buildNavItem(Icons.emoji_flags_outlined, 1),
//               _buildNavItem(Icons.fitness_center_outlined, 2),
//               _buildNavItem(Icons.person_outline, 3),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// /// Builds a WaterDropNavBar with your items and handlers all in one place.
// Widget buildWaterDropNavBar({
//   required int selectedIndex,
//   required ValueChanged<int> onItemSelected,
//   Color backgroundColor = Colors.white,
//   Color waterDropColor = const Color(0xFF5B75F0),
//   Color? inactiveIconColor,
//   double iconSize = 28,
//   double? bottomPadding,
//   required List<BarItem> items,
// }) {
//   return WaterDropNavBar(
//     barItems: items,
//     selectedIndex: selectedIndex,
//     onItemSelected: onItemSelected,
//     backgroundColor: backgroundColor,
//     waterDropColor: waterDropColor,
//     inactiveIconColor: inactiveIconColor,
//     iconSize: iconSize,
//     bottomPadding: bottomPadding,
//   );
// }


/// Builds a labeled curved nav bar with your items and handlers in one shot.

class CustomNav {
  
  static Widget buildCurvedLabeledNavBar({
    
    required ValueChanged<int> onItemTap,
    Color barColor = Colors.white,
    Color backgroundColor = const Color.fromARGB(255, 255, 255, 255),
    Color buttonBackgroundColor = Colors.blueAccent,
    Curve animationCurve = Curves.easeOut,
    Duration animationDuration = const Duration(milliseconds: 600),
    double height = 60,
  }) {
  final navController = Get.put(NavController(), permanent: true);
    
    return Obx(() {
      final navController = Get.find<NavController>();
      return CurvedNavigationBar(
        index: navController.currentIndex.value,
        onTap: (index) {
          navController.onItemSelected(index);
          onItemTap(index);
        },
        color: barColor,
        backgroundColor: backgroundColor,
        buttonBackgroundColor: buttonBackgroundColor,
        animationCurve: animationCurve,
        animationDuration: animationDuration,
        height: height,
items: navController.items,
      );
    });
  }
}



//fetch user data and display on avatar 



// final user = Rx<UserModel?>(null);

// void fetchUserData() {
//   user.bindStream(FirebaseAuth.instance.authStateChanges().asyncMap((user) {
//     if (user != null) {
//       return _firestore.collection('users').doc(user.uid).get().then((doc) => 
//           UserModel.fromFirestore(doc));
//     }
//     return null;
//   }));
// }
// custom button with color changing functionality for learning modules
class ColorChangingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color defaultColor;
  

  const ColorChangingButton({
    Key? key,
    
    required this.text,
    required this.onPressed,
    this.defaultColor = const Color(0xFF0E83AD), required Color color, required bool isDisabled,
  }) : super(key: key);

  @override
  ColorChangingButtonState createState() => ColorChangingButtonState();
}

class ColorChangingButtonState extends State<ColorChangingButton> {
  Color? currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.defaultColor;
  }

  void changeColor(Color color) {
    setState(() {
      currentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        foregroundColor: Colors.white,
        backgroundColor: currentColor,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: Text(widget.text),
    );
  }
}

// color_changing_button
class ColorChangingButto extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isDisabled;

  const ColorChangingButto({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}


class quizbutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const quizbutton({
    Key? key,
    required this.text,
    required this.onPressed, required ButtonStyle style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBackground;
  final Color iconColor;
  
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}


class AvatarWidget extends StatelessWidget {
  final RxBool isSpeaking;
  final AvatarController controller = Get.put(AvatarController());

  AvatarWidget({super.key, required this.isSpeaking});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.avatarPath.isEmpty) {
        return const CircularProgressIndicator();
      }
      return Obx(() {
        return AnimatedScale(
          scale: isSpeaking.value ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            controller.avatarPath.value,
            width: 70,
            height: 70,
          ),
        );
      });
    });
  }
}

