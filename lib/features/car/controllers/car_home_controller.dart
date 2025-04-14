// lib/features/car/controllers/ride_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/ride_details.dart';
import '../../../utils/popus/loaders.dart';
import 'fetch_ride_controller.dart';
import 'ride_publish_controller.dart';
import 'ride_booking_controller.dart';
import 'ride_filter_controller.dart';

class RideController extends GetxController {
  static RideController get instance => Get.find();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Observable variables
  final isLoading = false.obs;
  final availableRides = <RideDetails>[].obs;
  final userRides = <RideDetails>[].obs;
  final filteredRides = <RideDetails>[].obs;
  final recommendedRides = <RideDetails>[].obs;
  final selectedRide = Rxn<RideDetails>();

  // Form controllers for create ride
  final pickupController = TextEditingController();
  final destinationController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final seatsController = TextEditingController();
  final fareController = TextEditingController();
  final notesController = TextEditingController();

  // Form controllers for find ride
  final findPickupController = TextEditingController();
  final findDestinationController = TextEditingController();
  final findDateController = TextEditingController();
  final findTimeController = TextEditingController();
  final findPassengersController = TextEditingController(text: "1");

  // Child controllers
  late RideFetchController _fetchController;
  late RidePublishController _publishController;
  late RideBookingController _bookingController;
  late RideFilterController _filterController;

  @override
  void onInit() {
    super.onInit();

    // Initialize child controllers
    _fetchController = RideFetchController(this);
    _publishController = RidePublishController(this);
    _bookingController = RideBookingController(this);
    _filterController = RideFilterController(this);

    // Initialize date controllers with today's date
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    findDateController.text = DateFormat('EEE, MMM d').format(DateTime.now());

    // Fetch initial data
    fetchAvailableRides();
    fetchUserRides();
    fetchRecommendedRides();
  }

  @override
  void onClose() {
    // Dispose of text controllers
    pickupController.dispose();
    destinationController.dispose();
    dateController.dispose();
    timeController.dispose();
    seatsController.dispose();
    fareController.dispose();
    notesController.dispose();
    findPickupController.dispose();
    findDestinationController.dispose();
    findDateController.dispose();
    findTimeController.dispose();
    findPassengersController.dispose();
    super.onClose();
  }

  // Fetch all available rides from Firebase
  Future<void> fetchAvailableRides() => _fetchController.fetchAvailableRides();

  // Fetch rides created by the current user
  Future<void> fetchUserRides() => _fetchController.fetchUserRides();

  // Fetch recommended rides for the user
  Future<void> fetchRecommendedRides() => _fetchController.fetchRecommendedRides();

  // Search rides based on find ride form inputs
  Future<void> searchRides() => _fetchController.searchRides();

  // Publish a new ride to Firebase
  Future<void> publishRide() => _publishController.publishRide();

  // Book a ride
  Future<void> bookRide(RideDetails ride) => _bookingController.bookRide(ride);

  // Apply filters to the rides
  void filterRides() => _filterController.filterRides();

  // Clear create ride form
  void clearCreateRideForm() {
    pickupController.clear();
    destinationController.clear();
    // Keep the date as today's date
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    timeController.clear();
    seatsController.clear();
    fareController.clear();
    notesController.clear();
  }

  // Cancel a ride (for drivers)
  Future<void> cancelRide(String rideId) => _bookingController.cancelRide(rideId);

  // Cancel a booking (for passengers)
  Future<void> cancelBooking(String bookingId) => _bookingController.cancelBooking(bookingId);

  // Getters for Firebase instances (used by child controllers)
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;
}