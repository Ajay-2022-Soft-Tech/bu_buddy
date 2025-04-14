import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_details.dart';

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get rides published by the given user
  Future<List<RideDetails>> getPublishedRides(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RideDetails.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching published rides: $e');
      rethrow;
    }
  }

  /// Get rides booked by the given user
  Future<List<RideDetails>> getBookedRides(String userId) async {
    try {
      // Get all chat documents where the user is a participant
      final chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      final List<RideDetails> bookedRides = [];
      final Set<String> processedRideIds = {}; // To avoid duplicates

      // For each chat, extract the ride details if it exists
      for (final chatDoc in chatSnapshot.docs) {
        final data = chatDoc.data();
        if (data.containsKey('ride')) {
          final rideMap = data['ride'] as Map<String, dynamic>;

          // Skip if no ride data or if user is the ride creator
          if (rideMap.isEmpty) continue;

          // Find the other participant (likely the ride creator)
          final otherParticipantId = (data['participants'] as List<dynamic>)
              .firstWhere((id) => id != userId, orElse: () => null);

          if (otherParticipantId != null && otherParticipantId != userId) {
            // Get full ride details from rides collection
            try {
              // Try to match the ride using more precise criteria
              final QuerySnapshot rideQuery = await _firestore
                  .collection('rides')
                  .where('userId', isEqualTo: otherParticipantId)
                  .where('pickupLocation', isEqualTo: rideMap['from'])
                  .where('destinationLocation', isEqualTo: rideMap['to'])
                  .get();

              if (rideQuery.docs.isNotEmpty) {
                for (final rideDoc in rideQuery.docs) {
                  // Avoid duplicates
                  if (!processedRideIds.contains(rideDoc.id)) {
                    processedRideIds.add(rideDoc.id);
                    bookedRides.add(RideDetails.fromMap(rideDoc.data() as Map<String, dynamic>, rideDoc.id));
                  }
                }
              } else {
                // If no exact match, try a broader search with just the userId
                final backupQuery = await _firestore
                    .collection('rides')
                    .where('userId', isEqualTo: otherParticipantId)
                    .limit(1)
                    .get();

                if (backupQuery.docs.isNotEmpty && !processedRideIds.contains(backupQuery.docs.first.id)) {
                  processedRideIds.add(backupQuery.docs.first.id);
                  bookedRides.add(RideDetails.fromMap(
                      backupQuery.docs.first.data() as Map<String, dynamic>,
                      backupQuery.docs.first.id
                  ));
                }
              }
            } catch (e) {
              print('Error finding ride details: $e');
              // Create a temporary ride object from chat data if we can't find the full details
              if (rideMap.containsKey('from') && rideMap.containsKey('to')) {
                final tempRideId = 'temp_${otherParticipantId}_${rideMap['from']}_${rideMap['to']}';
                if (!processedRideIds.contains(tempRideId)) {
                  processedRideIds.add(tempRideId);

                  String userName = 'Unknown User';
                  try {
                    final userDoc = await _firestore.collection('users').doc(otherParticipantId).get();
                    if (userDoc.exists) {
                      userName = userDoc.data()?['name'] ?? 'Unknown User';
                    }
                  } catch (_) {}

                  bookedRides.add(RideDetails(
                    id: tempRideId,
                    userId: otherParticipantId,
                    userName: userName,
                    pickupLocation: rideMap['from'] ?? 'Unknown',
                    destinationLocation: rideMap['to'] ?? 'Unknown',
                    rideDate: rideMap['date'] ?? 'Unknown',
                    rideTime: rideMap['time'] ?? 'Unknown',
                    availableSeats: int.tryParse(rideMap['seats']?.toString() ?? '0') ?? 0,
                    price: double.tryParse(rideMap['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0,
                    createdAt: DateTime.now(),
                    isActive: true,
                  ));
                }
              }
            }
          }
        }
      }

      return bookedRides;
    } catch (e) {
      print('Error fetching booked rides: $e');
      rethrow;
    }
  }

  /// Update the active status of a ride
  Future<void> updateRideStatus(String rideId, bool isActive) async {
    try {
      await _firestore
          .collection('rides')
          .doc(rideId)
          .update({'isActive': isActive});
    } catch (e) {
      print('Error updating ride status: $e');
      rethrow;
    }
  }

  /// Delete a ride completely (use with caution)
  Future<void> deleteRide(String rideId) async {
    try {
      await _firestore
          .collection('rides')
          .doc(rideId)
          .delete();
    } catch (e) {
      print('Error deleting ride: $e');
      rethrow;
    }
  }

  /// Get ride details by ID
  Future<RideDetails?> getRideById(String rideId) async {
    try {
      final doc = await _firestore
          .collection('rides')
          .doc(rideId)
          .get();

      if (doc.exists) {
        return RideDetails.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting ride by ID: $e');
      rethrow;
    }
  }
}
