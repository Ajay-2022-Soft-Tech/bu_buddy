// // lib/data/repositories/notifications/notification_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:bu_buddy/features/personalization/models/notification_model.dart';
//
// class NotificationRepository {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   // Send a notification to a user
//   Future<bool> sendNotification(String userId, String title, String message, String type, {Map<String, dynamic>? data}) async {
//     try {
//       await _db.collection('notifications').add({
//         'userId': userId,
//         'title': title,
//         'message': message,
//         'type': type,
//         'data': data,
//         'isRead': false,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // Here you would typically integrate with FCM (Firebase Cloud Messaging)
//       // to send push notifications
//
//       return true;
//     } catch (e) {
//       print('Error sending notification: $e');
//       return false;
//     }
//   }
//
//   // Get user notifications
//   Future<List<NotificationModel>> getUserNotifications() async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) return [];
//
//       final notificationsSnapshot = await _db.collection('notifications')
//           .where('userId', isEqualTo: currentUser.uid)
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       return notificationsSnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return NotificationModel.fromMap(data, doc.id);
//       }).toList();
//     } catch (e) {
//       print('Error getting user notifications: $e');
//       return [];
//     }
//   }
//
//   // Mark notification as read
//   Future<bool> markNotificationAsRead(String notificationId) async {
//     try {
//       final currentUser = _auth.currentUser;
//       if (currentUser == null) return false;
//
//       await _db.collection('notifications').doc(notificationId).update({
//         'isRead': true,
//       });
//
//       return true;
//     } catch (e) {
//       print('Error marking notification as read: $e');
//       return false;
//     }
//   }
//
//   // Listen for new notifications in real-time
//   Stream<QuerySnapshot> listenForNotifications() {
//     final currentUser = _auth.currentUser;
//     if (currentUser == null) {
//       return Stream.empty();
//     }
//
//     return _db.collection('notifications')
//         .where('userId', isEqualTo: currentUser.uid)
//         .where('isRead', isEqualTo: false)
//         .snapshots();
//   }
// }