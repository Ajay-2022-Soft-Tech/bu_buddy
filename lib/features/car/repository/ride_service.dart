import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_details.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Join a ride
  Future<void> joinRide(RideDetails ride) async {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Get user data
    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    final userData = userDoc.data() ?? {};

    final String userName = userData['name'] ?? currentUser!.displayName ?? 'User';
    final String userAvatar = userData['avatar'] ?? currentUser!.photoURL ?? '';

    // First, update the ride document to decrease available seats
    await _firestore.collection('rides').doc(ride.id).update({
      'availableSeats': FieldValue.increment(-1),
      'passengers': FieldValue.arrayUnion([
        {
          'userId': currentUser!.uid,
          'userName': userName,
          'userAvatar': userAvatar,
          'joinedAt': FieldValue.serverTimestamp(),
        }
      ]),
    });

    // Then, add this ride to user's joined rides collection
    await _firestore.collection('users').doc(currentUser!.uid).collection('joinedRides').doc(ride.id).set({
      'rideId': ride.id,
      'userId': ride.userId,  // Ride owner's ID
      'userName': ride.userName,  // Ride owner's name
      'userAvatar': ride.userAvatar,  // Ride owner's avatar
      'pickupLocation': ride.pickupLocation,
      'destinationLocation': ride.destinationLocation,
      'rideDate': ride.rideDate,
      'rideTime': ride.rideTime,
      'price': ride.price,
      'joinedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    // Create a notification for the ride owner
    await _firestore.collection('notifications').add({
      'recipientId': ride.userId,
      'senderId': currentUser!.uid,
      'senderName': userName,
      'senderAvatar': userAvatar,
      'type': 'ride_join',
      'rideId': ride.id,
      'message': '$userName has joined your ride to ${ride.destinationLocation}',
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Leave a ride
  Future<void> leaveRide(RideDetails ride) async {
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    // Get user data for the notification
    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    final userData = userDoc.data() ?? {};
    final String userName = userData['name'] ?? currentUser!.displayName ?? 'User';

    // Update the ride document to increase available seats
    final rideDoc = await _firestore.collection('rides').doc(ride.id).get();
    final rideData = rideDoc.data() ?? {};
    final passengers = List<Map<String, dynamic>>.from(rideData['passengers'] ?? []);

    // Find and remove the current user from passengers array
    final passengersWithoutUser = passengers.where((p) => p['userId'] != currentUser!.uid).toList();

    await _firestore.collection('rides').doc(ride.id).update({
      'availableSeats': FieldValue.increment(1),
      'passengers': passengersWithoutUser,
    });

    // Remove this ride from user's joined rides
    await _firestore.collection('users').doc(currentUser!.uid).collection('joinedRides').doc(ride.id).delete();

    // Create a notification for the ride owner
    await _firestore.collection('notifications').add({
      'recipientId': ride.userId,
      'senderId': currentUser!.uid,
      'senderName': userName,
      'type': 'ride_leave',
      'rideId': ride.id,
      'message': '$userName has left your ride to ${ride.destinationLocation}',
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Get user's joined rides
  Stream<List<RideDetails>> getJoinedRidesStream() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('joinedRides')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<RideDetails> rides = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Get the actual ride data to ensure it's up to date
        final rideDoc = await _firestore.collection('rides').doc(data['rideId']).get();

        if (rideDoc.exists) {
          final rideData = rideDoc.data() ?? {};

          rides.add(RideDetails(
            id: doc.id,
            userId: rideData['userId'] ?? '',
            userName: rideData['userName'] ?? 'Unknown',
            userAvatar: rideData['userAvatar'] ?? '',
            pickupLocation: rideData['pickupLocation'] ?? 'Unknown',
            destinationLocation: rideData['destinationLocation'] ?? 'Unknown',
            rideDate: rideData['rideDate'] ?? 'Unknown',
            rideTime: rideData['rideTime'] ?? 'Unknown',
            availableSeats: rideData['availableSeats'] ?? 0,
            price: (rideData['price'] is num) ? (rideData['price'] as num).toDouble() : 0.0,
            createdAt: (rideData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isActive: true,
            isJoined: true,
          ));
        }
      }

      return rides;
    });
  }
}
