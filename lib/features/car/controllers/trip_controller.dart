import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../models/ride_details.dart';

class TripController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = false.obs;
  final RxBool isIndexError = false.obs;
  final RxString indexUrl = "".obs;
  final RxList<RideDetails> upcomingTrips = <RideDetails>[].obs;
  final RxList<RideDetails> pastTrips = <RideDetails>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    isLoading.value = true;
    isIndexError.value = false;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch published rides (rides created by the current user)
      final publishedRides = await _getPublishedRides(userId);

      // Fetch booked rides (rides where the current user is a passenger)
      final bookedRides = await _getBookedRides(userId);

      // Sort and categorize all trips
      _processRidesList([...publishedRides, ...bookedRides]);

    } catch (e) {
      _handleFetchError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Modified to avoid complex queries requiring indexes
  Future<List<RideDetails>> _getPublishedRides(String userId) async {
    try {
      // Simplified query to avoid index requirements
      final querySnapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => RideDetails.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching published rides: $e');
      rethrow;
    }
  }

  Future<List<RideDetails>> _getBookedRides(String userId) async {
    try {
      // Simplified query for booked rides
      final chatSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get();

      final List<RideDetails> bookedRides = [];

      for (final chatDoc in chatSnapshot.docs) {
        final data = chatDoc.data();

        // Skip if chat doesn't have ride info
        if (!data.containsKey('ride') || data['ride'] == null) continue;

        final rideMap = data['ride'] as Map<String, dynamic>;
        if (rideMap.isEmpty) continue;

        // Get the other participant (likely the ride creator)
        final participants = List<String>.from(data['participants'] ?? []);
        final otherParticipantId = participants.firstWhere(
              (id) => id != userId,
          orElse: () => "",
        );

        if (otherParticipantId.isEmpty || otherParticipantId == userId) continue;

        // Try to find the actual ride in the rides collection
        try {
          final rideQuery = await _firestore
              .collection('rides')
              .where('userId', isEqualTo: otherParticipantId)
              .get();

          // Filter rides that match origin/destination in the chat
          for (final rideDoc in rideQuery.docs) {
            final rideData = rideDoc.data();

            if (rideData['pickupLocation'] == rideMap['from'] &&
                rideData['destinationLocation'] == rideMap['to']) {
              bookedRides.add(RideDetails.fromMap(rideData, rideDoc.id));
              break;
            }
          }
        } catch (e) {
          print('Error matching booked ride: $e');
          // Continue to next chat
        }
      }

      return bookedRides;
    } catch (e) {
      print('Error fetching booked rides: $e');
      return [];
    }
  }

  // Process rides in memory instead of using complex Firestore queries
  void _processRidesList(List<RideDetails> allRides) {
    // Do manual sorting in memory rather than in Firestore
    allRides.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final now = DateTime.now();
    final upcoming = <RideDetails>[];
    final past = <RideDetails>[];

    for (var ride in allRides) {
      // Parse the ride date and time
      final DateTime rideDateTime = _parseRideDateTime(ride);

      if (rideDateTime.isAfter(now) && ride.isActive) {
        upcoming.add(ride);
      } else {
        past.add(ride);
      }
    }

    upcomingTrips.value = upcoming;
    pastTrips.value = past;
  }

  DateTime _parseRideDateTime(RideDetails ride) {
    try {
      final DateTime date = _parseDate(ride.rideDate);
      final TimeOfDay time = _parseTime(ride.rideTime);

      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    } catch (e) {
      print('Error parsing date/time for ride: $e');
      // Return yesterday as a fallback
      return DateTime.now().subtract(const Duration(days: 1));
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      // Try various date formats
      final formats = [
        'MMM d, yyyy', // Apr 15, 2025
        'yyyy-MM-dd',   // 2025-04-15
        'dd/MM/yyyy',   // 15/04/2025
        'MM/dd/yyyy',   // 04/15/2025
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(dateStr);
        } catch (_) {
          // Try next format
        }
      }

      // If no format works, throw an error
      throw Exception('Could not parse date: $dateStr');
    } catch (e) {
      print('Error parsing date: $dateStr - $e');
      return DateTime.now();
    }
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        // Parse 12-hour format (e.g., "10:30 AM")
        final parts = timeStr.split(' ');
        final timePart = parts[0].split(':');
        final hour = int.parse(timePart[0]);
        final minute = int.parse(timePart[1]);
        final isPM = parts[1].toUpperCase() == 'PM';

        // Convert to 24-hour format
        final hour24 = isPM && hour < 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
        return TimeOfDay(hour: hour24, minute: minute);
      } else {
        // Parse 24-hour format (e.g., "14:30")
        final parts = timeStr.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing time: $timeStr - $e');
      return TimeOfDay.now();
    }
  }

  Future<void> cancelRide(RideDetails ride) async {
    try {
      await _firestore
          .collection('rides')
          .doc(ride.id)
          .update({'isActive': false});

      // Refresh the trips list
      fetchTrips();

      Get.snackbar(
        'Success',
        'Your ride has been cancelled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error cancelling ride: $e');

      Get.snackbar(
        'Error',
        'Failed to cancel ride: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Handle the specific Firebase index error
  void _handleFetchError(dynamic error) {
    String errorMessage = error.toString();

    // Check if this is an index error
    if (errorMessage.contains('index') && errorMessage.contains('https://console.firebase')) {
      isIndexError.value = true;

      // Extract the URL for creating the index
      final urlMatch = RegExp(r'https://console\.firebase\.google\.com/[^\s]+').firstMatch(errorMessage);
      if (urlMatch != null) {
        indexUrl.value = urlMatch.group(0) ?? "";
      }

      print('Index error detected. URL: ${indexUrl.value}');
    } else {
      Get.snackbar(
        'Error',
        'Failed to fetch trips: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Launch the Firebase Console URL to create the required index
  void launchIndexCreationUrl() async {
    if (indexUrl.value.isNotEmpty) {
      try {
        final uri = Uri.parse(indexUrl.value);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Get.snackbar(
            'Error',
            'Could not open browser to create index',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }
}
