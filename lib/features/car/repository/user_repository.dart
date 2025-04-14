// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../authentication/models/user_model.dart';
//
// class UserRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   Future<void> createUserProfile(UserModel user) async {
//     try {
//       await _firestore.collection('users').doc(_auth.currentUser!.uid).set(user.toMap());
//     } catch (e) {
//       throw FirebaseException(plugin: 'UserRepository', message: e.toString());
//     }
//   }
//
//   Future<UserModel> getUserProfile() async {
//     try {
//       final doc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
//       if (doc.exists) {
//         return UserModel.fromSnapshot(doc.data()!);
//       } else {
//         throw 'User profile not found';
//       }
//     } catch (e) {
//       throw FirebaseException(plugin: 'UserRepository', message: e.toString());
//     }
//   }
//
//   Future<void> updateUserProfile(Map<String, dynamic> data) async {
//     try {
//       await _firestore.collection('users').doc(_auth.currentUser!.uid).update(data);
//     } catch (e) {
//       throw FirebaseException(plugin: 'UserRepository', message: e.toString());
//     }
//   }
// }
