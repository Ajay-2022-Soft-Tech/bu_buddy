// lib/features/car/controllers/ride_filter_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'car_home_controller.dart';

class RideFilterController {
  final RideController _parent;

  // Filter variables
  final minPrice = 0.0.obs;
  final maxPrice = 1000.0.obs;
  final currentPriceRange = RxList<double>([0.0, 1000.0]);
  final selectedGenderPreference = "All".obs;
  final searchQuery = "".obs;
  final sortBy = "price_low_to_high".obs;

  RideFilterController(this._parent) {
    // Initialize price range based on available rides when they are loaded
    ever(_parent.availableRides, (_) {
      _updatePriceRangeFromRides();
    });
  }

  // Update price range based on available rides
  void _updatePriceRangeFromRides() {
    if (_parent.availableRides.isNotEmpty) {
      final prices = _parent.availableRides.map((ride) => ride.fare).toList();
      minPrice.value = prices.reduce((curr, next) => curr < next ? curr : next);
      maxPrice.value = prices.reduce((curr, next) => curr > next ? curr : next);

      // Only update current range if it's still at default values
      if (currentPriceRange.value[0] == 0.0 && currentPriceRange.value[1] == 1000.0) {
        currentPriceRange.value = [minPrice.value, maxPrice.value];
      }
    }
  }

  // Apply filters to the rides
  void filterRides() {
    if (_parent.availableRides.isEmpty) return;

    final filtered = _parent.availableRides.where((ride) {
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

    // Apply sorting
    _sortFilteredRides(filtered);

    _parent.filteredRides.assignAll(filtered);
  }

  // Sort filtered rides based on selected sort option
  void _sortFilteredRides(List<dynamic> rides) {
    switch (sortBy.value) {
      case "price_low_to_high":
        rides.sort((a, b) => a.fare.compareTo(b.fare));
        break;
      case "price_high_to_low":
        rides.sort((a, b) => b.fare.compareTo(a.fare));
        break;
      case "departure_earliest":
        rides.sort((a, b) {
          final aDateTime = _parseDateTime(a.rideDate, a.rideTime);
          final bDateTime = _parseDateTime(b.rideDate, b.rideTime);
          return aDateTime.compareTo(bDateTime);
        });
        break;
      case "departure_latest":
        rides.sort((a, b) {
          final aDateTime = _parseDateTime(a.rideDate, a.rideTime);
          final bDateTime = _parseDateTime(b.rideDate, b.rideTime);
          return bDateTime.compareTo(aDateTime);
        });
        break;
      case "seats_most":
        rides.sort((a, b) => b.availableSeats.compareTo(a.availableSeats));
        break;
    }
  }

  // Parse date and time strings to DateTime
  DateTime _parseDateTime(String dateStr, String timeStr) {
    try {
      // Try to parse date in yyyy-MM-dd format
      final dateParts = dateStr.split('-');
      if (dateParts.length == 3) {
        final year = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final day = int.parse(dateParts[2]);

        // Try to parse time in HH:mm format
        final timeParts = timeStr.split(':');
        if (timeParts.length == 2) {
          final hour = int.parse(timeParts[0]);
          final minute = int.parse(timeParts[1]);

          return DateTime(year, month, day, hour, minute);
        }
      }
    } catch (e) {
      print('Error parsing date/time: $e');
    }

    // Return current time if parsing fails
    return DateTime.now();
  }

  // Reset all filters to default values
  void resetFilters() {
    currentPriceRange.value = [minPrice.value, maxPrice.value];
    selectedGenderPreference.value = "All";
    searchQuery.value = "";
    sortBy.value = "price_low_to_high";
    filterRides();
  }

  // Update price range filter
  void updatePriceRange(List<double> range) {
    currentPriceRange.value = range;
    filterRides();
  }

  // Update gender preference filter
  void updateGenderPreference(String preference) {
    selectedGenderPreference.value = preference;
    filterRides();
  }

  // Update search query filter
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterRides();
  }

  // Update sort option
  void updateSortBy(String option) {
    sortBy.value = option;
    filterRides();
  }
}