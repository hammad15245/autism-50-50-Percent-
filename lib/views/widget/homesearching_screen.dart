import 'package:autism_fyp/views/screens/home_screen.dart';
import 'package:autism_fyp/views/widget/learningpath_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomesearchingScreen extends StatefulWidget {
  const HomesearchingScreen({Key? key}) : super(key: key);

  @override
  State<HomesearchingScreen> createState() => _HomesearchingScreenState();
}

class _HomesearchingScreenState extends State<HomesearchingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allModules = [];
  List<Map<String, dynamic>> _filteredModules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllModules();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllModules() async {
    try {
      final modulesSnapshot = await FirebaseFirestore.instance
          .collection('learningModules')
          .get();

      _allModules = modulesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? doc.id,
          'data': data,
        };
      }).toList();

      setState(() {
        _filteredModules = _allModules;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading modules: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredModules = _allModules;
      });
      return;
    }

    setState(() {
      _filteredModules = _allModules.where((module) {
        final title = module['title'].toString().toLowerCase();
        return title.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02,
            vertical: screenHeight * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                // decoration: BoxDecoration(
                  
                //   color: const Color(0xFF0E83AD),
                //   borderRadius: BorderRadius.only(
                //     bottomLeft: Radius.circular(20),
                //     bottomRight: Radius.circular(20),
                //   ),
                // ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Color.fromARGB(255, 0, 0, 0)),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Back",
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height:10),

              // Search bar
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search modules',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    ),
                  ),
                ),
              ),

          
              SizedBox(height: 20),

              // Loading or results
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredModules.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.1),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No modules available'
                                      : 'No results for "${_searchController.text}"',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : LearningWidget(modules: _filteredModules), // Pass filtered modules to LearningWidget
            ],
          ),
        ),
      ),
    );
  }
}