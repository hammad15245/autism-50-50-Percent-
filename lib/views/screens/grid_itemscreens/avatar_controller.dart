import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AvatarController extends GetxController {
  var username = ''.obs;
  var avatarPath = ''.obs; 
  var uniqueId = ''.obs;

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (doc.exists) {
          username.value = doc.data()?['username'] ?? 'No name';
          avatarPath.value = doc.data()?['avatar'] ?? '';
          uniqueId.value = doc.data()?['uniqueId'] ?? '';
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }
}
