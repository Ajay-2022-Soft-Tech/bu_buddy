import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new booking
  Future<String> createBooking(BookingModel booking) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // Create the booking
      final bookingRef = _firestore.collection('bookings').doc();
      batch.set(bookingRef, booking.toMap());

      // Update available seats in the ride
      final rideRef = _firestore.collection('rides').doc(booking.rideId);
      final rideDoc = await rideRef.get();

      if (!rideDoc.exists) {
        throw 'Ride not found';
      }

      final rideData = rideDoc.data()!;
      final availableSeats = rideData['availableSeats'] as int;

      if (availableSeats <= 0) {
        throw 'No seats available';
      }

      batch.update(rideRef, {
        'availableSeats': availableSeats - 1,
        'updatedAt': DateTime.now(),
      });

      // Add to user trip history
      final userTripRef = _firestore
          .collection('userTrips')
          .doc(booking.passengerId)
          .collection('trips')
          .doc();

      batch.set(userTripRef, {
        'rideId': booking.rideId,
        'role': 'passenger',
        'origin': booking.pickupLocation,
        'destination': booking.dropoffLocation,
        'departureTime': rideData['departureTime'],
        'fare': booking.fare,
        'status': booking.status,
        'timestamp': DateTime.now(),
      });

      // Commit the batch
      await batch.commit();
      return bookingRef.id;
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Get bookings for the current user
  Stream<List<BookingModel>> getUserBookings() {
    try {
      return _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return BookingModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Get bookings for a specific ride
  Stream<List<BookingModel>> getRideBookings(String rideId) {
    try {
      return _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return BookingModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });

      // If the booking is cancelled, update the ride's available seats
      if (status == 'cancelled') {
        final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
        if (bookingDoc.exists) {
          final bookingData = bookingDoc.data()!;
          final rideId = bookingData['rideId'] as String;

          final rideDoc = await _firestore.collection('rides').doc(rideId).get();
          if (rideDoc.exists) {
            final rideData = rideDoc.data()!;
            final availableSeats = rideData['availableSeats'] as int;

            await _firestore.collection('rides').doc(rideId).update({
              'availableSeats': availableSeats + 1,
              'updatedAt': DateTime.now(),
            });
          }
        }
      }

      // Update the user trip status
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data()!;
        final passengerId = bookingData['passengerId'] as String;
        final rideId = bookingData['rideId'] as String;

        // Query to find the specific trip
        final tripQuery = await _firestore
            .collection('userTrips')
            .doc(passengerId)
            .collection('trips')
            .where('rideId', isEqualTo: rideId)
            .where('role', isEqualTo: 'passenger')
            .get();

        if (tripQuery.docs.isNotEmpty) {
          final tripDoc = tripQuery.docs.first;
          await _firestore
              .collection('userTrips')
              .doc(passengerId)
              .collection('trips')
              .doc(tripDoc.id)
              .update({'status': status});
        }
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Get a specific booking
  Future<BookingModel> getBooking(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromMap(doc.data()!, doc.id);
      } else {
        throw 'Booking not found';
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Get all bookings for a user as a passenger
  Future<List<BookingModel>> getUserBookingsAsList() async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('passengerId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return BookingModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Get pending bookings for a ride (for driver to approve/reject)
  Stream<List<BookingModel>> getPendingBookingsForRide(String rideId) {
    try {
      return _firestore
          .collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return BookingModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Accept a booking request (for drivers)
  Future<void> acceptBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, 'accepted');

      // Send notification to passenger
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data()!;
        final passengerId = bookingData['passengerId'] as String;

        // Add notification
        await _firestore.collection('chat_bot').add({
          'userId': passengerId,
          'title': 'Booking Accepted',
          'message': 'Your ride request has been accepted by the driver.',
          'type': 'booking_accepted',
          'relatedId': bookingId,
          'isRead': false,
          'createdAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Reject a booking request (for drivers)
  Future<void> rejectBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, 'rejected');

      // Send notification to passenger
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data()!;
        final passengerId = bookingData['passengerId'] as String;

        // Add notification
        await _firestore.collection('chat_bot').add({
          'userId': passengerId,
          'title': 'Booking Rejected',
          'message': 'Your ride request has been rejected by the driver.',
          'type': 'booking_rejected',
          'relatedId': bookingId,
          'isRead': false,
          'createdAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Complete a booking (for drivers)
  Future<void> completeBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, 'completed');

      // Send notification to passenger
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data()!;
        final passengerId = bookingData['passengerId'] as String;

        // Add notification
        await _firestore.collection('chat_bot').add({
          'userId': passengerId,
          'title': 'Ride Completed',
          'message': 'Your ride has been marked as completed. Please rate your experience.',
          'type': 'booking_completed',
          'relatedId': bookingId,
          'isRead': false,
          'createdAt': DateTime.now(),
        });
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }

  // Cancel a booking (for passengers)
  Future<void> cancelBooking(String bookingId) async {
    try {
      await updateBookingStatus(bookingId, 'cancelled');

      // Send notification to driver
      final bookingDoc = await _firestore.collection('bookings').doc(bookingId).get();
      if (bookingDoc.exists) {
        final bookingData = bookingDoc.data()!;
        final rideId = bookingData['rideId'] as String;

        final rideDoc = await _firestore.collection('rides').doc(rideId).get();
        if (rideDoc.exists) {
          final rideData = rideDoc.data()!;
          final driverId = rideData['driverId'] as String;

          // Add notification
          await _firestore.collection('chat_bot').add({
            'userId': driverId,
            'title': 'Booking Cancelled',
            'message': 'A passenger has cancelled their booking for your ride.',
            'type': 'booking_cancelled',
            'relatedId': bookingId,
            'isRead': false,
            'createdAt': DateTime.now(),
          });
        }
      }
    } catch (e) {
      throw FirebaseException(plugin: 'BookingRepository', message: e.toString());
    }
  }
}
