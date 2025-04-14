// lib/features/car/controllers/ride_publish_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'car_home_controller.dart';

class RidePublishController {
  final RideController _parent;

  RidePublishController(this._parent);

  // Publish a new ride to Firebase
  Future<void> publishRide() async {
    try {
      // Validate form fields
      if (_parent.pickupController.text.isEmpty ||
          _parent.destinationController.text.isEmpty ||
          _parent.dateController.text.isEmpty ||
          _parent.timeController.text.isEmpty ||
          _parent.seatsController.text.isEmpty ||
          _parent.fareController.text.isEmpty) {
        Get.snackbar(
          'Missing Information',
          'Please fill in all required fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _parent.isLoading.value = true;

      // Get current user
      final user = _parent.auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Get user profile data
      final userDoc = await _parent.firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Parse date and time
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timeFormat = DateFormat('HH:mm');

      DateTime? date;
      TimeOfDay? time;

      try {
        date = dateFormat.parse(_parent.dateController.text);
        final timeString = _parent.timeController.text;
        final timeParts = timeString.split(':');
        if (timeParts.length == 2) {
          time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
        }
      } catch (e) {
        print('Error parsing date/time: $e');
        throw 'Invalid date or time format';
      }

      if (date == null || time == null) {
        throw 'Invalid date or time';
      }

      // Create departure time
      final departureTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      // Check if departure time is in the future
      if (departureTime.isBefore(DateTime.now())) {
        throw 'Departure time must be in the future';
      }

      // Create ride data
      final rideData = {
        'driverId': user.uid,
        'driverName': userData['displayName'] ?? user.displayName ?? 'Unknown',
        'driverPhotoUrl': userData['profilePicture'] ?? user.photoURL,
        'pickupLocation': _parent.pickupController.text,
        'destinationLocation': _parent.destinationController.text,
        'rideDate': _parent.dateController.text,
        'rideTime': _parent.timeController.text,
        'departureTime': Timestamp.fromDate(departureTime),
        'totalSeats': int.parse(_parent.seatsController.text),
        'availableSeats': int.parse(_parent.seatsController.text),
        'fare': double.parse(_parent.fareController.text),
        'notes': _parent.notesController.text,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'genderPreference': userData['gender'] ?? 'Any',
      };

      // Add vehicle details if available
      final vehicleDoc = await _parent.firestore.collection('vehicles')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (vehicleDoc.docs.isNotEmpty) {
        final vehicleData = vehicleDoc.docs.first.data();
        rideData['vehicleType'] = vehicleData['type'];
        rideData['vehicleModel'] = vehicleData['model'];
        rideData['vehicleColor'] = vehicleData['color'];
        rideData['vehiclePlate'] = vehicleData['licensePlate'];
      }

      // Save to Firestore
      final docRef = await _parent.firestore.collection('rides').add(rideData);

      // Add to user's trips collection
      await _parent.firestore.collection('userTrips').doc(user.uid).collection('trips').add({
        'rideId': docRef.id,
        'role': 'driver',
        'origin': {'name': _parent.pickupController.text},
        'destination': {'name': _parent.destinationController.text},
        'departureTime': Timestamp.fromDate(departureTime),
        'fare': double.parse(_parent.fareController.text),
        'status': 'active',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear form
      _parent.clearCreateRideForm();

      // Show success message
      Get.snackbar(
        'Success',
        'Your ride has been published successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Refresh rides list
      _parent.fetchUserRides();

      // Navigate back
      Get.back();

    } catch (e) {
      print('Error publishing ride: $e');
      Get.snackbar(
        'Error',
        'Failed to publish ride: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }
}