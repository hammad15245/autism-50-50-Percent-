import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignedModulesNotification extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(String, BuildContext) navigateToItemScreen;

  const AssignedModulesNotification({
    Key? key,
    required this.onClose,
    required this.navigateToItemScreen,
  }) : super(key: key);

  @override
  _AssignedModulesNotificationState createState() => _AssignedModulesNotificationState();
}

class _AssignedModulesNotificationState extends State<AssignedModulesNotification> {
  List<String> assignedModules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedModules();
  }

  Future<void> _fetchAssignedModules() async {
    setState(() => isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('assignedModules')
          .get();

      final modules = snapshot.docs
          .map((doc) => doc.data()['title'] as String? ?? 'Unnamed Module')
          .toList();

      setState(() {
        assignedModules = modules;
      });
    } catch (e) {
      print('Error fetching assigned modules: $e');
      setState(() {
        assignedModules = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _markModuleCompleted(String moduleTitle) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await userRef.collection('completedModules').doc(moduleTitle).set({
      'title': moduleTitle,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await userRef.collection('assignedModules').doc(moduleTitle).delete();

    setState(() {
      assignedModules.remove(moduleTitle);
    });
  }

  void _onModuleTap(String moduleTitle) {
    widget.navigateToItemScreen(moduleTitle, context);
    // Mark as completed **after navigation** (async)
    _markModuleCompleted(moduleTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black38),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.only(top: 70, right: 16),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Assigned Modules',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _fetchAssignedModules,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (assignedModules.isEmpty)
                          const Text('No new assignments')
                        else
                          ...assignedModules.map(
                            (module) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: GestureDetector(
                                onTap: () => _onModuleTap(module),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline,
                                        size: 20, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(module)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
