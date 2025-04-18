import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_details.dart';
import '../repository/ride_service.dart';

class TripController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RideService _rideService = RideService();

  final RxBool isLoading = false.obs;
  final RxList<RideDetails> upcomingTrips = <RideDetails>[].obs;
  final RxList<RideDetails> pastTrips = <RideDetails>[].obs;

  // Stream subscriptions to track
  late StreamSubscription<List<RideDetails>> _joinedRidesSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchTrips();

    // Listen for changes in joined rides
    _joinedRidesSubscription = _rideService.getJoinedRidesStream().listen((joinedRides) {
      // When joined rides change, we need to refresh our trips
      _updateTripsWithJoinedRides(joinedRides);
    });
  }

  @override
  void onClose() {
    _joinedRidesSubscription.cancel();
    super.onClose();
  }

  Future<void> fetchTrips() async {
    if (_auth.currentUser == null) return;

    isLoading.value = true;

    try {
      // Get published rides (rides created by the user)
      final publishedRidesSnapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .get();

      // Process the published rides
      final List<RideDetails> publishedRides = publishedRidesSnapshot.docs.map((doc) {
        final data = doc.data();
        return RideDetails(
          id: doc.id,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? 'Unknown',
          userAvatar: data['userAvatar'] ?? '',
          pickupLocation: data['pickupLocation'] ?? 'Unknown',
          destinationLocation: data['destinationLocation'] ?? 'Unknown',
          rideDate: data['rideDate'] ?? 'Unknown',
          rideTime: data['rideTime'] ?? 'Unknown',
          availableSeats: data['availableSeats'] ?? 0,
          price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isActive: data['isActive'] ?? true,
          isJoined: false,
          isOwner: true,
        );
      }).toList();

      // Get joined rides
      final joinedRides = await _rideService.getJoinedRidesStream().first;

      // Combine both types of rides and filter into upcoming and past
      final allRides = [...publishedRides, ...joinedRides];

      // Sort rides by date and time
      _sortAndFilterRides(allRides);

    } catch (e) {
      print('Error fetching trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateTripsWithJoinedRides(List<RideDetails> joinedRides) {
    // Get existing published rides (not joined ones)
    final publishedUpcoming = upcomingTrips.where((trip) => !trip.isJoined).toList();
    final publishedPast = pastTrips.where((trip) => !trip.isJoined).toList();

    // Add joined rides to the lists
    final allRides = [...publishedUpcoming, ...publishedPast, ...joinedRides];

    // Re-sort and filter
    _sortAndFilterRides(allRides);
  }

  void _sortAndFilterRides(List<RideDetails> allRides) {
    // Parse dates for comparison
    DateTime now = DateTime.now();

    // Sort rides by date and time
    allRides.sort((a, b) {
      try {
        final aDate = _parseRideDateTime(a.rideDate, a.rideTime);
        final bDate = _parseRideDateTime(b.rideDate, b.rideTime);
        return aDate.compareTo(bDate);
      } catch (e) {
        return 0;
      }
    });

    // Filter into upcoming and past
    upcomingTrips.value = allRides.where((trip) {
      try {
        final tripDate = _parseRideDateTime(trip.rideDate, trip.rideTime);
        return tripDate.isAfter(now) && trip.isActive;
      } catch (e) {
        return false;
      }
    }).toList();

    pastTrips.value = allRides.where((trip) {
      try {
        final tripDate = _parseRideDateTime(trip.rideDate, trip.rideTime);
        return tripDate.isBefore(now) || !trip.isActive;
      } catch (e) {
        return true;
      }
    }).toList();
  }

  DateTime _parseRideDateTime(String date, String time) {
    // This is a simplified parsing logic - adjust based on your date/time format
    try {
      final dateParts = date.replaceAll(',', '').split(' ');
      final monthStr = dateParts[0];
      final day = int.parse(dateParts[1]);
      final year = int.parse(dateParts[2]);

      final timeParts = time.split(' ');
      final hourMinute = timeParts[0].split(':');
      final hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      final isPM = timeParts[1].toLowerCase() == 'pm';

      final adjustedHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
      };

      return DateTime(year, months[monthStr] ?? 1, day, adjustedHour, minute);
    } catch (e) {
      // Fallback to current date if parsing fails
      return DateTime.now();
    }
  }
}
