import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/ride_details.dart';  // Model for ride details

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // Fetch ride details from Firestore
  Future<List<RideDetails>> _fetchRides() async {
    final snapshot = await FirebaseFirestore.instance.collection('rides').get();
    return snapshot.docs.map((doc) {
      return RideDetails(
        pickupLocation: doc['pickupLocation'],
        destinationLocation: doc['destinationLocation'],
        rideDate: doc['rideDate'],
        rideTime: doc['rideTime'],
        availableSeats: doc['availableSeats'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Rides"),
        backgroundColor: Colors.blueAccent,
        elevation: 10,
      ),
      body: FutureBuilder<List<RideDetails>>(
        future: _fetchRides(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error fetching rides"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No available rides found"));
          }

          final rides = snapshot.data!;
          return ListView.builder(
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Optionally add navigation to detailed page if needed
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRow(Iconsax.location, "Pickup: ${ride.pickupLocation}"),
                          SizedBox(height: 10),
                          _buildRow(Iconsax.location_tick, "Destination: ${ride.destinationLocation}"),
                          SizedBox(height: 10),
                          _buildRow(Icons.calendar_today, "Date: ${ride.rideDate}"),
                          SizedBox(height: 10),
                          _buildRow(Icons.access_time, "Time: ${ride.rideTime}"),
                          SizedBox(height: 10),
                          _buildRow(Icons.person, "Available Seats: ${ride.availableSeats}"),
                          SizedBox(height: 15),
                          _buildViewDetailsButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Custom method to build rows with icon and text
  Widget _buildRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // Custom method for the "View Details" button with animation
  Widget _buildViewDetailsButton() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the detailed ride information
          // Get.to(() => AvailableRidesScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: Size(double.infinity, 60),
        ),
        child: Text(
          "View Details",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
