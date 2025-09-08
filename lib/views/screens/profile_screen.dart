import 'dart:math';
import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? avatarPath;
  String? uniqueId; // 🔹 cache the unique ID

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          username = doc.data()?['username'] ?? 'No name';
          avatarPath = doc.data()?['avatar'];
          uniqueId = doc.data()?['uniqueId']; // 🔹 fetch uniqueId if exists
        });
      }
    }
  }

  Future<void> _editUsername() async {
    final controller = TextEditingController(text: username ?? '');
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter new username",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'username': newName});
        setState(() {
          username = newName;
        });
      }
    }
  }

  Future<void> _generateAndShowId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || username == null) return;

    // 🔹 If ID already exists, don’t generate again
    if (uniqueId == null) {
      final random = Random();
      final randomDigits = random.nextInt(9000) + 1000; // 1000–9999
      uniqueId =
          "${username!.substring(0, min(3, username!.length)).toUpperCase()}-$randomDigits";

      // save only once
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'uniqueId': uniqueId,
      });
    }

    // show popup
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 280,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Your Unique ID",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  uniqueId ?? "",
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0E83AD)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0E83AD),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: screenHeight * 0.6,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/rainbow2.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.to(HomeScreen())),
                Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Scrollable Content aligned from the top
          SingleChildScrollView(
            padding: EdgeInsets.only(top: screenHeight * 0.25),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    radius: screenWidth * 0.18,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        avatarPath != null ? AssetImage(avatarPath!) : null,
                    child: avatarPath == null
                        ? Icon(Icons.person,
                            size: screenWidth * 0.15, color: Colors.grey)
                        : null,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  height: screenHeight * 0.6,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const _ActionRow(
                        icon: Icons.person,
                        label: "Manage Profile",
                        color: Colors.blue,
                      ),
                      const Divider(height: 1, thickness: 0.2, color: Colors.grey),
                      const _ActionRow(
                        icon: Icons.email,
                        label: "Update Email & Password",
                        color: Colors.green,
                      ),
                                            const Divider(height: 1, thickness: 0.2, color: Colors.grey),
                      GestureDetector(
                        onTap: _editUsername,
                        child: const _ActionRow(
                          icon: Icons.edit,
                          label: "Erase data",
                          color: Color.fromARGB(255, 76, 145, 175),
                        ),
                      ),
                      const Divider(height: 1, thickness: 0.2, color: Colors.grey),

                      GestureDetector(
                        onTap: _generateAndShowId,
                        child: const _ActionRow(
                          icon: Icons.api_outlined,
                          label: "Generate ID",
                          color: Colors.purple,
                        ),
                      ),

                      const Divider(height: 1, thickness: 0.2, color: Colors.grey),
                      const _ActionRow(
                        icon: Icons.exit_to_app,
                        label: "Logout",
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Helper row widget with circular icon background
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double iconSize;
  final double iconRadius;

  const _ActionRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.iconSize = 24,
    this.iconRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: iconRadius * 2,
            height: iconRadius * 2,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: iconSize,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}
