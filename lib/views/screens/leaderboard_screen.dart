import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _leaderboardData = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Fetch all users
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      // Create a list to store users with their scores
      List<Map<String, dynamic>> usersWithScores = [];

      // Fetch score for each user
      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        
        try {
          // Try to get score from progress/overview
          final overviewDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userDoc.id)
              .collection('progress')
              .doc('overview')
              .get();

          final score = overviewDoc.exists ? (overviewDoc.data()?['totalScore'] ?? 0) : 0;
          
          usersWithScores.add({
            'id': userDoc.id,
            'username': userData['username'] ?? 'Unknown',
            'avatar': userData['avatar'] ?? '',
            'score': score,
          });
        } catch (e) {

          usersWithScores.add({
            'id': userDoc.id,
            'username': userData['username'] ?? 'Unknown',
            'avatar': userData['avatar'] ?? '',
            'score': 0,
          });
        }
      }


      usersWithScores.sort((a, b) => b['score'].compareTo(a['score']));

      setState(() {
        _leaderboardData = usersWithScores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading leaderboard: ${e.toString()}';
      });
    }
  }

  Widget buildLeaderboardItem(
    Map<String, dynamic> user,
    int rank,
    Color color,
    double height,
    bool isCurrentUser,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          backgroundImage: (user['avatar'] != null && user['avatar'].isNotEmpty)
              ? AssetImage(user['avatar']) as ImageProvider
              : null,
          child: (user['avatar'] == null || user['avatar'].isEmpty)
              ? const Icon(Icons.person, size: 28, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 5),
        Container(
          height: height,
          width: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: isCurrentUser
                ? Border.all(color: const Color(0xFF0E83AD), width: 2) 
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            rank.toString().padLeft(2, "0"),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${user['score']} pts',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? const Color(0xFF0E83AD) : Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Container(
            height: screenH * 0.6,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/leaderboardbg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.to(const HomeScreen())
                ),
                Text(
                  "Leaderboard",
                  style: TextStyle(
                    fontSize: screenW * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _fetchLeaderboardData,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(top: screenH * 0.20),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : _leaderboardData.isEmpty
                        ? const Center(
                            child: Text(
                              "No leaderboard data available",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : _buildLeaderboardContent(screenH),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardContent(double screenH) {
    final topThree = _leaderboardData.take(3).toList();
    final remaining = _leaderboardData.skip(3).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Podium Section
          SizedBox(
            height: screenH * 0.32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (topThree.length > 1)
                  Positioned(
                    left: 40,
                    bottom: 0,
                    child: buildLeaderboardItem(
                      topThree[1],
                      2,
                      const Color(0xFF205295),
                      140,
                      topThree[1]['id'] == currentUid, 
                    ),
                  ),
                if (topThree.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    child: buildLeaderboardItem(
                      topThree[0],
                      1,
                      const Color(0xFFA27B5C),
                      160,
                      topThree[0]['id'] == currentUid, 
                    ),
                  ),
                if (topThree.length > 2)
                  Positioned(
                    right: 40,
                    bottom: 0,
                    child: buildLeaderboardItem(
                      topThree[2],
                      3,
                      const Color(0xFF5C8374),
                      130,
                      topThree[2]['id'] == currentUid,
                    ),
                  ),
              ],
            ),
          ),

          // Remaining Leaderboard
          Container(
            height: screenH * 0.6,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: remaining.length,
              itemBuilder: (context, index) {
                final user = remaining[index];
                final username = user['username'];
                final avatarPath = user['avatar'];
                final score = user['score'];
                final isCurrentUser = user['id'] == currentUid;
                final rank = index + 4;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrentUser
                        ? Border.all(color: const Color(0xFF0E83AD), width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        rank.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 15),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: (avatarPath != null && avatarPath.isNotEmpty)
                            ? ClipOval(
                                child: Image.asset(
                                  avatarPath,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const Icon(Icons.person, size: 28, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.person, size: 28, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser ? const Color(0xFF0E83AD) : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Score: ${score > 0 ? '$score pts' : 'No score yet'}",
                              style: TextStyle(
                                fontSize: 14,
                                color: isCurrentUser ? const Color(0xFF0E83AD) : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}