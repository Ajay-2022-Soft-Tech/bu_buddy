// lib/features/car/controllers/ride_fetch_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/ride_details.dart';
import 'car_home_controller.dart';

class RideFetchController {
  final RideController _parent;

  RideFetchController(this._parent);

  // Fetch all available rides from Firebase
  Future<void> fetchAvailableRides() async {
    try {
      _parent.isLoading.value = true;

      // Query Firestore for active rides with available seats
      final QuerySnapshot snapshot = await _parent.firestore.collection('rides')
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThan: 0)
          .where('departureTime', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('departureTime')
          .get();

      // Convert query snapshots to RideDetails objects
      final List<RideDetails> rides = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RideDetails(
          id: doc.id,
          driverId: data['driverId'] ?? '',
          driverName: data['driverName'] ?? 'Unknown',
          pickupLocation: data['pickupLocation'] ?? '',
          destinationLocation: data['destinationLocation'] ?? '',
          rideDate: data['rideDate'] ?? DateFormat('yyyy-MM-dd').format(
              (data['departureTime'] as Timestamp).toDate()),
          rideTime: data['rideTime'] ?? DateFormat('HH:mm').format(
              (data['departureTime'] as Timestamp).toDate()),
          availableSeats: data['availableSeats'] ?? 0,
          fare: (data['fare'] ?? 0.0).toDouble(),
          vehicleType: data['vehicleType'],
          vehicleModel: data['vehicleModel'],
          vehicleColor: data['vehicleColor'],
          vehiclePlate: data['vehiclePlate'],
          status: data['status'] ?? 'active',
          pickupCoordinates: data['pickupCoordinates'],
          destinationCoordinates: data['destinationCoordinates'],
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
          updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
        );
      }).toList();

      _parent.availableRides.assignAll(rides);
      _parent.filteredRides.assignAll(rides);

    } catch (e) {
      print('Error fetching available rides: $e');
      Get.snackbar(
        'Error',
        'Failed to load available rides',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }

  // Fetch rides created by the current user
  Future<void> fetchUserRides() async {
    try {
      _parent.isLoading.value = true;

      final user = _parent.auth.currentUser;
      if (user == null) {
        return;
      }

      final QuerySnapshot snapshot = await _parent.firestore.collection('rides')
          .where('driverId', isEqualTo: user.uid)
          .orderBy('departureTime', descending: true)
          .get();

      final List<RideDetails> rides = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return RideDetails(
          id: doc.id,
          driverId: data['driverId'] ?? '',
          driverName: data['driverName'] ?? 'Unknown',
          pickupLocation: data['pickupLocation'] ?? '',
          destinationLocation: data['destinationLocation'] ?? '',
          rideDate: data['rideDate'] ?? '',
          rideTime: data['rideTime'] ?? '',
          availableSeats: data['availableSeats'] ?? 0,
          fare: (data['fare'] ?? 0.0).toDouble(),
          vehicleType: data['vehicleType'],
          vehicleModel: data['vehicleModel'],
          vehicleColor: data['vehicleColor'],
          vehiclePlate: data['vehiclePlate'],
          status: data['status'] ?? 'active',
          pickupCoordinates: data['pickupCoordinates'],
          destinationCoordinates: data['destinationCoordinates'],
          createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
          updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
        );
      }).toList();

      _parent.userRides.assignAll(rides);

    } catch (e) {
      print('Error fetching user rides: $e');
    } finally {
      _parent.isLoading.value = false;
    }
  }

  // Search rides based on find ride form inputs
  Future<void> searchRides() async {
    try {
      if (_parent.findPickupController.text.isEmpty || _parent.findDestinationController.text.isEmpty) {
        Get.snackbar(
          'Missing Information',
          'Please provide pickup and destination locations',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _parent.isLoading.value = true;

      // Parse the selected date
      DateTime? selectedDate;
      try {
        if (_parent.findDateController.text.isNotEmpty) {
          selectedDate = DateFormat('EEE, MMM d').parse(_parent.findDateController.text);
        }
      } catch (e) {
        print('Error parsing date: $e');
        selectedDate = null;
      }

      // Build the query
      Query query = _parent.firestore.collection('rides')
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThanOrEqualTo: int.parse(_parent.findPassengersController.text));

      // Add date filter if available
      if (selectedDate != null) {
        final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

        query = query
            .where('departureTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .where('departureTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      } else {
        // If no date specified, show future rides
        query = query.where('departureTime', isGreaterThan: Timestamp.fromDate(DateTime.now()));
      }

      // Execute the query
      final QuerySnapshot snapshot = await query.get();

      // Filter results manually for pickup and destination
      final pickupLower = _parent.findPickupController.text.toLowerCase();
      final destinationLower = _parent.findDestinationController.text.toLowerCase();

      final List<RideDetails> rides = snapshot.docs
          .map((doc) => RideDetails.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((ride) =>
      ride.pickupLocation.toLowerCase().contains(pickupLower) &&
          ride.destinationLocation.toLowerCase().contains(destinationLower))
          .toList();

      _parent.availableRides.assignAll(rides);
      _parent.filteredRides.assignAll(rides);

    } catch (e) {
      print('Error searching rides: $e');
      Get.snackbar(
        'Error',
        'Failed to search for rides',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      _parent.isLoading.value = false;
    }
  }

  // Get recommended rides
  Future<void> fetchRecommendedRides() async {
    try {
      final user = _parent.auth.currentUser;
      if (user == null) return;

      // Get user's frequent routes
      final userTripsRef = _parent.firestore.collection('userTrips').doc(user.uid);
      final userTripsDoc = await userTripsRef.get();

      List<String> frequentDestinations = [];

      if (userTripsDoc.exists && userTripsDoc.data() != null) {
        final userData = userTripsDoc.data()!;
        if (userData.containsKey('frequentDestinations')) {
          frequentDestinations = List<String>.from(userData['frequentDestinations']);
        }
      } else {
        // If no history, fallback to query user's trips
        final tripsQuery = await userTripsRef.collection('trips').orderBy('timestamp', descending: true).limit(5).get();
        frequentDestinations = tripsQuery.docs
            .map((doc) => (doc.data()['destination'] as Map<String, dynamic>)['name'] as String)
            .toList();
      }

      if (frequentDestinations.isEmpty) return;

      // Find rides matching frequent destinations
      final now = DateTime.now();
      final query = await _parent.firestore.collection('rides')
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThan: 0)
          .where('departureTime', isGreaterThan: Timestamp.fromDate(now))
          .limit(10)
          .get();

      final allRides = query.docs.map((doc) =>
          RideDetails.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

      // Filter for destinations the user frequently travels to
      final recommended = allRides.where((ride) =>
          frequentDestinations.any((dest) =>
              ride.destinationLocation.toLowerCase().contains(dest.toLowerCase()))).toList();

      _parent.recommendedRides.assignAll(recommended);

    } catch (e) {
      print('Error fetching recommended rides: $e');
    }
  }
}