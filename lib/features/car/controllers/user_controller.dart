// Create one controller in a common location like lib/controllers/user_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool profileLoading = false.obs;

  // Add necessary properties and methods from both controllers
  // ...

  // Add the FCM token update method
  Future<void> updateFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
          'deviceInfo': {
            'platform': Platform.isIOS ? 'iOS' : 'Android',
            'appVersion': '1.0.0',
          }
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }
}
