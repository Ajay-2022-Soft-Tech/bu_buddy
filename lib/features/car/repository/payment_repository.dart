// lib/data/repositories/payments/payment_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Process a payment for a ride
  Future<Map<String, dynamic>> processPayment(String rideId, double amount, String paymentMethod) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return {'success': false, 'message': 'User not authenticated'};

      // Get the ride details
      final rideDoc = await _db.collection('rides').doc(rideId).get();
      if (!rideDoc.exists) return {'success': false, 'message': 'Ride not found'};

      final ride = rideDoc.data() as Map<String, dynamic>;

      // In a real app, you would integrate with a payment gateway like Stripe, PayPal, etc.
      // For this example, we'll just simulate a successful payment

      // Record the payment
      final paymentDoc = await _db.collection('payments').add({
        'rideId': rideId,
        'userId': currentUser.uid,
        'driverId': ride['driverId'],
        'amount': amount,
        'paymentMethod': paymentMethod,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the ride to mark payment as complete
      await _db.collection('rides').doc(rideId).update({
        'paymentStatus': 'paid',
        'paymentId': paymentDoc.id,
      });

      // Update the booking to mark payment as complete
      final bookingSnapshot = await _db.collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (bookingSnapshot.docs.isNotEmpty) {
        await _db.collection('bookings').doc(bookingSnapshot.docs.first.id).update({
          'paymentStatus': 'paid',
          'paymentId': paymentDoc.id,
        });
      }

      return {
        'success': true,
        'paymentId': paymentDoc.id,
        'message': 'Payment processed successfully',
      };
    } catch (e) {
      print('Error processing payment: $e');
      return {'success': false, 'message': 'Payment processing failed: $e'};
    }
  }

  // Get payment history for user
  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      final paymentsSnapshot = await _db.collection('payments')
          .where('userId', isEqualTo: currentUser.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return paymentsSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      }).toList();
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }
}