// lib/features/car/controllers/search_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/ride_details.dart';

class SearchRideController extends GetxController {
  static SearchRideController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final isLoading = false.obs;
  final allRides = <RideDetails>[].obs;
  final filteredRides = <RideDetails>[].obs;

  // Filter variables
  final minPrice = 0.0.obs;
  final maxPrice = 1000.0.obs;
  final currentPriceRange = RxList<double>([0.0, 1000.0]);
  final selectedGenderPreference = "All".obs;
  final searchQuery = "".obs;

  // Form controllers for find ride
  final findPickupController = TextEditingController();
  final findDestinationController = TextEditingController();
  final findDateController = TextEditingController();
  final findTimeController = TextEditingController();
  final findPassengersController = TextEditingController(text: "1");

  @override
  void onInit() {
    super.onInit();
    // Initialize date controller with today's date
    findDateController.text = DateFormat('EEE, MMM d').format(DateTime.now());

    // Listen to search queries to perform filtering
    searchQuery.listen((_) => filterRides());
    currentPriceRange.listen((_) => filterRides());
    selectedGenderPreference.listen((_) => filterRides());
  }

  @override
  void onClose() {
    findPickupController.dispose();
    findDestinationController.dispose();
    findDateController.dispose();
    findTimeController.dispose();
    findPassengersController.dispose();
    super.onClose();
  }

  // Update rides from main controller
  void updateRides(List<RideDetails> rides) {
    allRides.assignAll(rides);
    filteredRides.assignAll(rides);

    // Set price range based on available rides
    if (rides.isNotEmpty) {
      final prices = rides.map((ride) => ride.fare).toList();
      minPrice.value = prices.reduce((curr, next) => curr < next ? curr : next);
      maxPrice.value = prices.reduce((curr, next) => curr > next ? curr : next);
      currentPriceRange.value = [minPrice.value, maxPrice.value];
    }
  }

  // Search rides based on find ride form inputs
  Future<void> searchRides() async {
    try {
      if (findPickupController.text.isEmpty || findDestinationController.text.isEmpty) {
        Get.snackbar(
          'Missing Information',
          'Please provide pickup and destination locations',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;

      // Parse the selected date
      DateTime? selectedDate;
      try {
        if (findDateController.text.isNotEmpty) {
          selectedDate = DateFormat('EEE, MMM d').parse(findDateController.text);
        }
      } catch (e) {
        print('Error parsing date: $e');
        selectedDate = null;
      }

      // Build the query
      Query query = _firestore.collection('rides')
          .where('status', isEqualTo: 'active')
          .where('availableSeats', isGreaterThanOrEqualTo: int.parse(findPassengersController.text));

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
      final pickupLower = findPickupController.text.toLowerCase();
      final destinationLower = findDestinationController.text.toLowerCase();

      final List<RideDetails> rides = snapshot.docs
          .map((doc) => RideDetails.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .where((ride) =>
      ride.pickupLocation.toLowerCase().contains(pickupLower) &&
          ride.destinationLocation.toLowerCase().contains(destinationLower))
          .toList();

      allRides.assignAll(rides);
      filteredRides.assignAll(rides);

      // Set price range based on available rides
      if (rides.isNotEmpty) {
        final prices = rides.map((ride) => ride.fare).toList();
        minPrice.value = prices.reduce((curr, next) => curr < next ? curr : next);
        maxPrice.value = prices.reduce((curr, next) => curr > next ? curr : next);
        currentPriceRange.value = [minPrice.value, maxPrice.value];
      }

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
      isLoading.value = false;
    }
  }

  // Filter rides based on current filters
  void filterRides() {
    if (allRides.isEmpty) return;

    final filtered = allRides.where((ride) {
      // Price filter
      final priceInRange = ride.fare >= currentPriceRange[0] && ride.fare <= currentPriceRange[1];

      // Gender preference filter
      bool matchesGender = true;

      // Search query filter
      bool matchesSearch = true;
      if (searchQuery.value.isNotEmpty) {
        final query = searchQuery.value.toLowerCase();
        matchesSearch = ride.pickupLocation.toLowerCase().contains(query) ||
            ride.destinationLocation.toLowerCase().contains(query) ||
            ride.driverName.toLowerCase().contains(query) ||
            ride.rideDate.toLowerCase().contains(query) ||
            ride.rideTime.toLowerCase().contains(query);
      }

      return priceInRange && matchesGender && matchesSearch;
    }).toList();

    filteredRides.assignAll(filtered);
  }

  // Reset all filters
  void resetFilters() {
    searchQuery.value = "";
    selectedGenderPreference.value = "All";
    currentPriceRange.value = [minPrice.value, maxPrice.value];
  }
}