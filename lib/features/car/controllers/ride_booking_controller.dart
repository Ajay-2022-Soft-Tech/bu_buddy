// lib/features/car/controllers/ride_booking_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ride_details.dart';
import 'car_home_controller.dart';

class RideBookingController {
  final RideController _parent;

  RideBookingController(this._parent);

  // Book a ride
  Future<void> bookRide(RideDetails ride) async {
    try {
      final user = _parent.auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      _parent.isLoading.value = true;

      // Get user profile
      final userDoc = await _parent.firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Check if seats are still available
      final rideDoc = await _parent.firestore.collection('rides').doc(ride.id).get();
      if (!rideDoc.exists) {
        throw 'Ride no longer exists';
      }

      final rideData = rideDoc.data()!;
      final availableSeats = rideData['availableSeats'] as int;

      if (availableSeats < 1) {
        throw 'No seats available for this ride';
      }

      // Create booking
      final bookingData = {
        'rideId': ride.id,
        'passengerId': user.uid,
        'passengerName': userData['displayName'] ?? user.displayName ?? 'Unknown',
        'passengerPhotoUrl': userData['profilePicture'] ?? user.photoURL,
        'pickupLocation': {
          'name': ride.pickupLocation,
          'coordinates': ride.pickupCoordinates
        },
        'dropoffLocation': {
          'name': ride.destinationLocation,
          'coordinates': ride.destinationCoordinates
        },
        'fare': ride.fare,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Start a batch write
      final batch = _parent.firestore.batch();

      // Create booking document
      final bookingRef = _parent.firestore.collection('bookings').doc();
      batch.set(bookingRef, bookingData);

      // Update ride with reduced seats
      batch.update(rideDoc.reference, {
        'availableSeats': availableSeats - 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add to user's trips
      final userTripRef = _parent.firestore.collection('userTrips').doc(user.uid).collection('trips').doc();
      batch.set(userTripRef, {
        'rideId': ride.id,
        'bookingId': bookingRef.id,
        'role': 'passenger',
        'origin': {'name': ride.pickupLocation},
        'destination': {'name': ride.destinationLocation},
        'departureTime': rideDoc.data()!['departureTime'],
        'fare': ride.fare,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Create chat room if it doesn't exist
      final existingChatQuery = await _parent.firestore.collection('chatRooms')
          .where('rideId', isEqualTo: ride.id)
          .where('participantIds', arrayContains: user.uid)
          .limit(1)
          .get();

      if (existingChatQuery.docs.isEmpty) {
        final chatRoomRef = _parent.firestore.collection('chatRooms').doc();
        batch.set(chatRoomRef, {
          'rideId': ride.id,
          'bookingId': bookingRef.id,
          'participantIds': [user.uid, ride.driverId],
          'lastMessage': 'Booking requested',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Add initial system message
        final messageRef = _parent.firestore.collection('chatRooms').doc(chatRoomRef.id).collection('messages').doc();
        batch.set(messageRef, {
          'senderId': 'system',
          'message': 'Booking requested for ride from ${ride.pickupLocation} to ${ride.destinationLocation}',
          'timestamp': FieldValue.serverTimestamp(),
          'isSystemMessage': true,
        });
      }

      // Send notification to driver
      final notificationRef = _parent.firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': ride.driverId,
        'title': 'New Booking Request',
        'message': '${userData['displayName'] ?? user.displayName ?? 'Someone'} wants to book your ride',
        'type': 'booking_request',
        'relatedId': bookingRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Commit the batch
      await batch.commit();

      // Show success message
      Get.snackbar(
        'Success',
        'Your booking request has been sent',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Refresh rides
      _parent.fetchAvailableRides();

    } catch (e) {
      print('Error booking ride: $e');
      Get.snackbar(
        'Error',
        'Failed to book ride: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }

  // Cancel a ride (for drivers)
  Future<void> cancelRide(String rideId) async {
    try {
      _parent.isLoading.value = true;

      // Get current user
      final user = _parent.auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Get the ride
      final rideDoc = await _parent.firestore.collection('rides').doc(rideId).get();
      if (!rideDoc.exists) {
        throw 'Ride not found';
      }

      // Check if user is the driver
      final rideData = rideDoc.data()!;
      if (rideData['driverId'] != user.uid) {
        throw 'You are not authorized to cancel this ride';
      }

      // Update ride status
      await _parent.firestore.collection('rides').doc(rideId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user trips
      await _parent.firestore.collection('userTrips')
          .doc(user.uid)
          .collection('trips')
          .where('rideId', isEqualTo: rideId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({
            'status': 'cancelled',
          });
        }
      });

      // Get all bookings for this ride
      final bookingsQuery = await _parent.firestore.collection('bookings')
          .where('rideId', isEqualTo: rideId)
          .get();

      // Start a batch write for notifications
      final batch = _parent.firestore.batch();

      // Notify all passengers
      for (var bookingDoc in bookingsQuery.docs) {
        final bookingData = bookingDoc.data();
        final passengerId = bookingData['passengerId'];

        // Update booking status
        batch.update(bookingDoc.reference, {
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Add notification
        final notificationRef = _parent.firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': passengerId,
          'title': 'Ride Cancelled',
          'message': 'The ride from ${rideData['pickupLocation']} to ${rideData['destinationLocation']} has been cancelled by the driver',
          'type': 'ride_cancelled',
          'relatedId': rideId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update passenger's trip
        final passengerTripsQuery = await _parent.firestore.collection('userTrips')
            .doc(passengerId)
            .collection('trips')
            .where('rideId', isEqualTo: rideId)
            .get();

        for (var tripDoc in passengerTripsQuery.docs) {
          batch.update(tripDoc.reference, {
            'status': 'cancelled',
          });
        }
      }

      // Commit batch
      await batch.commit();

      // Show success message
      Get.snackbar(
        'Success',
        'Your ride has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Refresh rides
      _parent.fetchUserRides();

    } catch (e) {
      print('Error cancelling ride: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel ride: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }

  // Cancel a booking (for passengers)
  Future<void> cancelBooking(String bookingId) async {
    try {
      _parent.isLoading.value = true;

      // Get current user
      final user = _parent.auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Get the booking
      final bookingDoc = await _parent.firestore.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) {
        throw 'Booking not found';
      }

      // Check if user is the passenger
      final bookingData = bookingDoc.data()!;
      if (bookingData['passengerId'] != user.uid) {
        throw 'You are not authorized to cancel this booking';
      }

      final rideId = bookingData['rideId'];

      // Start a batch write
      final batch = _parent.firestore.batch();

      // Update booking status
      batch.update(bookingDoc.reference, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Increment available seats in the ride
      final rideDoc = await _parent.firestore.collection('rides').doc(rideId).get();
      if (rideDoc.exists) {
        final rideData = rideDoc.data()!;
        final availableSeats = rideData['availableSeats'] as int;

        batch.update(rideDoc.reference, {
          'availableSeats': availableSeats + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Send notification to driver
        final notificationRef = _parent.firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': rideData['driverId'],
          'title': 'Booking Cancelled',
          'message': '${bookingData['passengerName']} has cancelled their booking',
          'type': 'booking_cancelled',
          'relatedId': bookingId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Update user trip
      final userTripsQuery = await _parent.firestore.collection('userTrips')
          .doc(user.uid)
          .collection('trips')
          .where('bookingId', isEqualTo: bookingId)
          .get();

      for (var tripDoc in userTripsQuery.docs) {
        batch.update(tripDoc.reference, {
          'status': 'cancelled',
        });
      }

      // Add system message to chat if exists
      final chatRoomQuery = await _parent.firestore.collection('chatRooms')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();

      if (chatRoomQuery.docs.isNotEmpty) {
        final chatRoomId = chatRoomQuery.docs.first.id;
        final messageRef = _parent.firestore.collection('chatRooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc();

        batch.set(messageRef, {
          'senderId': 'system',
          'message': 'Booking has been cancelled by the passenger',
          'timestamp': FieldValue.serverTimestamp(),
          'isSystemMessage': true,
        });

        // Update chat room last message
        batch.update(chatRoomQuery.docs.first.reference, {
          'lastMessage': 'Booking cancelled',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();

      // Show success message
      Get.snackbar(
        'Success',
        'Your booking has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

    } catch (e) {
      print('Error cancelling booking: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel booking: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }
}