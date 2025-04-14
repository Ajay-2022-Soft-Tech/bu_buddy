import 'package:bu_buddy/features/car/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../models/ride_details.dart';

class RidePublishedConfirmationScreen extends StatelessWidget {
  final RideDetails rideDetails;

  const RidePublishedConfirmationScreen({Key? key, required this.rideDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lottie Animation
                Lottie.asset(
                  'assets/animations/ride_published.json', // You'll need to add this Lottie animation
                  width: 250,
                  height: 250,
                  repeat: false,
                ),

                SizedBox(height: 32),

                // Success Title
                Text(
                  'Ride Published Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C63FF),
                  ),
                ),

                SizedBox(height: 16),

                // Ride Details Card
                _buildRideDetailsCard(),

                SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideDetailsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Iconsax.location,
            title: 'From',
            subtitle: rideDetails.pickupLocation,
          ),
          Divider(height: 24, color: Colors.grey[300]),
          _buildDetailRow(
            icon: Iconsax.location_tick,
            title: 'To',
            subtitle: rideDetails.destinationLocation,
          ),
          Divider(height: 24, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailColumn(
                icon: Iconsax.calendar,
                title: 'Date',
                subtitle: rideDetails.rideDate,
              ),
              _buildDetailColumn(
                icon: Iconsax.clock,
                title: 'Time',
                subtitle: rideDetails.rideTime,
              ),
              _buildDetailColumn(
                icon: Iconsax.people,
                title: 'Seats',
                subtitle: '${rideDetails.availableSeats}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF2C63FF), size: 24),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailColumn({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF2C63FF), size: 24),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back to Home Button
        ElevatedButton(
          onPressed: () {
            // Navigate back to the home screen or dashboard
            Get.offAll(() => CarHomeScreen()); // Replace with your actual home screen
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2C63FF),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Color(0xFF2C63FF), width: 2),
            ),
          ),
          child: Row(
            children: [
              Icon(Iconsax.home_1),
              SizedBox(width: 8),
              Text('Back to Home'),
            ],
          ),
        ),

        SizedBox(width: 16),

        // Share Ride Button
        ElevatedButton(
          onPressed: () {
            // Implement share functionality
            _shareRideDetails();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2C63FF),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Row(
            children: [
              Icon(Iconsax.share),
              SizedBox(width: 8),
              Text('Share Ride'),
            ],
          ),
        ),
      ],
    );
  }

  void _shareRideDetails() {
    // Implement your share logic here
    // This could use a package like share_plus to share ride details
    final shareText = '''
    🚗 Ride Shared! 

    From: ${rideDetails.pickupLocation}
    To: ${rideDetails.destinationLocation}
    Date: ${rideDetails.rideDate}
    Time: ${rideDetails.rideTime}
    Available Seats: ${rideDetails.availableSeats}
    ''';

    // Example using share_plus package
    // Share.share(shareText);
  }
}

// Modify the _publishRide method in PublishRideScreen to navigate to this screen
// Replace the existing navigation with:
// Get.to(() => RidePublishedConfirmationScreen(rideDetails: rideDetails));