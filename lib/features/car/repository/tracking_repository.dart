// lib/data/repositories/tracking/tracking_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class TrackingRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update driver's current location
  Future<bool> updateDriverLocation(String rideId, double latitude, double longitude) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Verify driver owns this ride
      final rideDoc = await _db.collection('rides').doc(rideId).get();
      if (!rideDoc.exists) return false;

      final ride = rideDoc.data() as Map<String, dynamic>;
      if (ride['driverId'] != currentUser.uid) return false;

      // Update location
      await _db.collection('rides').doc(rideId).update({
        'currentLocation': GeoPoint(latitude, longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating driver location: $e');
      return false;
    }
  }

  // Get real-time updates on driver location
  Stream<DocumentSnapshot> getDriverLocationUpdates(String rideId) {
    return _db.collection('rides').doc(rideId).snapshots();
  }

  // Calculate ETA based on current location
  Future<int> calculateETA(String rideId, double destinationLat, double destinationLng) async {
    try {
      final rideDoc = await _db.collection('rides').doc(rideId).get();
      if (!rideDoc.exists) return -1;

      final ride = rideDoc.data() as Map<String, dynamic>;
      final currentLocation = ride['currentLocation'] as GeoPoint?;

      if (currentLocation == null) return -1;

      // Here you would typically use a directions API like Google Maps
      // For simplicity, we'll use a rough estimate based on distance
      final distanceInMeters = Geolocator.distanceBetween(
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLat,
        destinationLng,
      );

      // Assuming average speed of 40 km/h in city
      final estimatedTimeInMinutes = (distanceInMeters / 1000 / 40 * 60).round();

      return estimatedTimeInMinutes;
    } catch (e) {
      print('Error calculating ETA: $e');
      return -1;
    }
  }
}