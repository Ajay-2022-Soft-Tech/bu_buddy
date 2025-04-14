// // lib/data/repositories/payment/payment_repository.dart
// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'base_repository.dart';
//
// class PaymentRepository extends BaseRepository {
//   // Process payment
//   Future<Map<String, dynamic>> processPayment(String rideId, double amount,
//       String paymentMethod) async {
//     try {
//       if (currentUser == null) throw 'User not authenticated';
//
//       final batch = db.batch();
//
//       // Add payment record
//       final paymentRef = db.collection('payments').doc();
//       batch.set(paymentRef, {
//         'rideId': rideId,
//         'userId': currentUser!.uid,
//         'amount': amount,
//         'paymentMethod': paymentMethod,
//         'status': 'completed',
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // Update ride payment status
//       batch.update(db.collection('rides').doc(rideId), {
//         'paymentStatus': 'paid',
//         'paymentId': paymentRef.id,
//       });
//
//       await batch.commit();
//
//       return {
//         'success': true,
//         'paymentId': paymentRef.id,
//       };
//     } catch (e) {
//       await handleError(e, 'processPayment');
//       return {'success': false, 'error': e.toString()};
//     }
//   }
//
//   // Get payment history
//   Stream<QuerySnapshot> getPaymentHistory() {
//     if (currentUser == null) return const Stream.empty();
//
//     return db.collection('payments')
//         .where('userId', isEqualTo: currentUser!.uid)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
// }
//
// // lib/data/repositories/tracking/tracking_repository.dart
// class TrackingRepository extends BaseRepository {
//   // Update location
//   Future<void> updateLocation(String rideId, GeoPoint location) async {
//     try {
//       if (currentUser == null) throw 'User not authenticated';
//
//       await db.collection('rides').doc(rideId).update({
//         'currentLocation': location,
//         'lastLocationUpdate': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       await handleError(e, 'updateLocation');
//     }
//   }
//
//   // Get location updates
//   Stream<DocumentSnapshot> getLocationUpdates(String rideId) {
//     return db.collection('rides').doc(rideId).snapshots();
//   }
//
//   // Calculate ETA
//   Future<double> calculateETA(GeoPoint start, GeoPoint end) async {
//     try {
//       // Simple distance calculation (you'd want to use Maps API in production)
//       final distanceKm = _calculateDistance(start, end);
//       const avgSpeedKmH = 40; // Average city speed
//       return distanceKm / avgSpeedKmH;
//     } catch (e) {
//       await handleError(e, 'calculateETA');
//       return -1;
//     }
//   }
//
//   double _calculateDistance(GeoPoint start, GeoPoint end) {
//     // Simple Haversine formula
//     const R = 6371; // Earth's radius in km
//     final lat1 = start.latitude * pi / 180;
//     final lat2 = end.latitude * pi / 180;
//     final dLat = (end.latitude - start.latitude) * pi / 180;
//     final dLon = (end.longitude - start.longitude) * pi / 180;
//
//     final a = sin(dLat/2) * sin(dLat/2) +
//         cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2);
//     final c = 2 * atan2(sqrt(a), sqrt(1-a));
//     return R * c;
//   }
// }
//
// // lib/data/repositories/review/review_repository.dart
// class ReviewRepository extends BaseRepository {
//   // Add review
//   Future<void> addReview(String rideId, String revieweeId, double rating, String comment) async {
//     try {
//       if (currentUser == null) throw 'User not authenticated';
//
//       final batch = db.batch();
//
//       // Add review
//       final reviewRef = db.collection('reviews').doc();
//       batch.set(reviewRef, {
//         'rideId': rideId,
//         'reviewerId': currentUser!.uid,
//         'revieweeId': revieweeId,
//         'rating': rating,
//         'comment': comment,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//
//       // Update user's average rating
//       final userRef = db.collection('users').doc(revieweeId);
//       final userDoc = await userRef.get();
//
//       if (userDoc.exists) {
//         final currentRating = userDoc.data()?['rating'] ?? 0.0;
//         final totalReviews = userDoc.data()?['totalReviews'] ?? 0;
//         final newRating = ((currentRating * totalReviews) + rating) / (totalReviews + 1);
//
//         batch.update(userRef, {
//           'rating': newRating,
//           'totalReviews': totalReviews + 1,
//         });
//       }
//
//       await batch.commit();
//     } catch (e) {
//       await handleError(e, 'addReview');
//     }
//   }
//
//   // Get user reviews
//   Stream<QuerySnapshot> getUserReviews(String userId) {
//     return db.collection('reviews')
//         .where('revieweeId', isEqualTo: userId)
//         .orderBy('createdAt', descending: true)
//         .snapshots();
//   }
// }