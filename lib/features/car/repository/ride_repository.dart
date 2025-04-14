import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/ride_model.dart';

class RideRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new ride
  Future<String> publishRide(RideModel ride) async {
    try {
      final docRef = await _firestore.collection('rides').add(ride.toMap());

      // Also add this ride to user's trip history
      await _addToUserTrips(
        userId: ride.driverId,
        rideId: docRef.id,
        role: 'driver',
        origin: ride.origin,
        destination: ride.destination,
        departureTime: ride.departureTime,
        fare: ride.totalFare,
        status: ride.status,
      );

      return docRef.id;
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Get available rides
  Stream<List<RideModel>> getAvailableRides() {
    try {
      return _firestore
          .collection('rides')
          .where('status', isEqualTo: 'active')
          .where('departureTime', isGreaterThan: DateTime.now())
          .where('availableSeats', isGreaterThan: 0)
          .orderBy('departureTime')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return RideModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Get rides created by the current user
  Stream<List<RideModel>> getUserCreatedRides() {
    try {
      return _firestore
          .collection('rides')
          .where('driverId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('departureTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return RideModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Get a specific ride
  Future<RideModel> getRide(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return RideModel.fromMap(doc.data()!, doc.id);
      } else {
        throw 'Ride not found';
      }
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Update ride status
  Future<void> updateRideStatus(String rideId, String status) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Update available seats
  Future<void> updateAvailableSeats(String rideId, int seats) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'availableSeats': seats,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Search rides by destination
  Future<List<RideModel>> searchRidesByDestination(String destination) async {
    try {
      // This is a simple search, you might want to implement more complex searching
      final snapshot = await _firestore
          .collection('rides')
          .where('status', isEqualTo: 'active')
          .where('departureTime', isGreaterThan: DateTime.now())
          .where('availableSeats', isGreaterThan: 0)
          .get();

      final rides = snapshot.docs.map((doc) => RideModel.fromMap(doc.data(), doc.id)).toList();

      // Filter rides by destination (case-insensitive)
      return rides.where((ride) {
        final destName = ride.destination['name'].toString().toLowerCase();
        return destName.contains(destination.toLowerCase());
      }).toList();
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }

  // Add to user trip history
  Future<void> _addToUserTrips({
    required String userId,
    required String rideId,
    required String role,
    required Map<String, dynamic> origin,
    required Map<String, dynamic> destination,
    required DateTime departureTime,
    required double fare,
    required String status,
  }) async {
    try {
      await _firestore.collection('userTrips').doc(userId).collection('trips').add({
        'rideId': rideId,
        'role': role,
        'origin': origin,
        'destination': destination,
        'departureTime': departureTime,
        'fare': fare,
        'status': status,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      throw FirebaseException(plugin: 'RideRepository', message: e.toString());
    }
  }
}
