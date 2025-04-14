// // lib/data/repositories/base/base_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../../authentication/models/user_model.dart';
//
// abstract class BaseRepository {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   FirebaseFirestore get db => _db;
//   FirebaseAuth get auth => _auth;
//   User? get currentUser => _auth.currentUser;
//
//   Future<void> handleError(dynamic e, String operation) async {
//     print('Error in $operation: $e');
//     throw FirebaseException(
//       plugin: runtimeType.toString(),
//       message: 'Error in $operation: $e',
//     );
//   }
// }
//
// // lib/data/repositories/authentication/authentication_repository.dart
// class AuthenticationRepository extends BaseRepository {
//   // Sign in with email and password
//   Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       return await auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//     } catch (e) {
//       await handleError(e, 'signInWithEmailAndPassword');
//       rethrow;
//     }
//   }
//
//   // Sign up with email and password
//   Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       return await auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//     } catch (e) {
//       await handleError(e, 'signUpWithEmailAndPassword');
//       rethrow;
//     }
//   }
//
//   // Sign out
//   Future<void> signOut() async {
//     try {
//       await auth.signOut();
//     } catch (e) {
//       await handleError(e, 'signOut');
//     }
//   }
//
//   // Reset password
//   Future<void> resetPassword(String email) async {
//     try {
//       await auth.sendPasswordResetEmail(email: email);
//     } catch (e) {
//       await handleError(e, 'resetPassword');
//     }
//   }
//
//   // Check if user is logged in
//   bool isLoggedIn() {
//     return auth.currentUser != null;
//   }
// }
//
// // lib/data/repositories/user/user_repository.dart
// class UserRepository extends BaseRepository {
//   final CollectionReference _usersCollection;
//
//   UserRepository() : _usersCollection = FirebaseFirestore.instance.collection('users');
//
//   // Create user profile
//   Future<void> createUserProfile(UserModel user) async {
//     try {
//       await _usersCollection.doc(user.id).set(user.toJson());
//     } catch (e) {
//       await handleError(e, 'createUserProfile');
//     }
//   }
//
//   // Get user profile
//   Future<UserModel?> getUserProfile(String userId) async {
//     try {
//       final doc = await _usersCollection.doc(userId).get();
//       if (!doc.exists) return null;
//       return UserModel.fromJson(doc.data() as Map<String, dynamic>);
//     } catch (e) {
//       await handleError(e, 'getUserProfile');
//       return null;
//     }
//   }
//
//   // Update user profile
//   Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
//     try {
//       await _usersCollection.doc(userId).update(data);
//     } catch (e) {
//       await handleError(e, 'updateUserProfile');
//     }
//   }
//
//   // Update user preferences
//   Future<void> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
//     try {
//       await _usersCollection.doc(userId).update({
//         'preferences': preferences,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       await handleError(e, 'updateUserPreferences');
//     }
//   }
//
//   // Verify student ID
//   Future<void> verifyStudent(String userId, String studentId, String college) async {
//     try {
//       await _usersCollection.doc(userId).update({
//         'studentId': studentId,
//         'college': college,
//         'isVerified': true,
//         'verifiedAt': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       await handleError(e, 'verifyStudent');
//     }
//   }
// }