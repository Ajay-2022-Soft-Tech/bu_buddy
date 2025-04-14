import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addReview(ReviewModel review) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // Add the review
      final reviewRef = _firestore.collection('reviews').doc();
      batch.set(reviewRef, review.toMap());

      // Update user's rating
      final userRef = _firestore.collection('users').doc(review.revieweeId);
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentRating = userData['rating'] ?? 0.0;
        final totalRides = userData['totalRides'] ?? 0;

        final newTotalRides = totalRides + 1;
        final newRating = ((currentRating * totalRides) + review.rating) / newTotalRides;

        batch.update(userRef, {
          'rating': newRating,
          'totalRides': newTotalRides,
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw FirebaseException(plugin: 'ReviewRepository', message: e.toString());
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reviews')
          .where('revieweeId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return ReviewModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw FirebaseException(plugin: 'ReviewRepository', message: e.toString());
    }
  }
}
