import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';  // Optional: For custom icons
import '../../models/ride_details.dart';
import '../available_rides/available_rides.dart';

class RideVerificationScreen extends StatelessWidget {
  final RideDetails rideDetails;

  RideVerificationScreen({required this.rideDetails});

  // Method to save the ride data to Firestore
  void _confirmRide(BuildContext context) async {
    try {
      // Saving ride data to Firestore
      await FirebaseFirestore.instance.collection('rides').add({
        'pickupLocation': rideDetails.pickupLocation,
        'destinationLocation': rideDetails.destinationLocation,
        'rideDate': rideDetails.rideDate,
        'rideTime': rideDetails.rideTime,
        'availableSeats': rideDetails.availableSeats,
      });

      // After saving, navigate to AvailableRidesScreen
      Get.back();
    } catch (e) {
      // Handle error
      print("Error saving ride details to Firebase: $e");
      // Optionally show an error dialog
      Get.snackbar("Error", "There was an issue saving the ride details.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Ride Details"),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Location
              _buildDetailCard("Pickup Location: ", rideDetails.pickupLocation),
              SizedBox(height: 20),

              // Destination Location
              _buildDetailCard("Destination Location: ", rideDetails.destinationLocation),
              SizedBox(height: 20),

              // Ride Date
              _buildDetailCard("Ride Date: ", rideDetails.rideDate),
              SizedBox(height: 20),

              // Ride Time
              _buildDetailCard("Ride Time: ", rideDetails.rideTime),
              SizedBox(height: 20),

              // Available Seats
              _buildDetailCard("Available Seats: ", "${rideDetails.availableSeats}"),
              SizedBox(height: 40),

              // Confirm Button with Animation
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                child: ElevatedButton(
                  onPressed: () => _confirmRide(context), // Store the data when pressed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 60),
                  ),
                  child: Text(
                    'Confirm Ride',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Cancel Button
              GestureDetector(
                onTap: () {
                  // Navigate back to PublishRideScreen if user wants to cancel
                  Get.back();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A custom method to build the details UI with animated containers and styling
  Widget _buildDetailCard(String title, String value) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Iconsax.info_circle, color: Colors.blueAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$title $value",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
