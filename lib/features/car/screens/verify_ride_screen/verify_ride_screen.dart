// RIDE VERIFICATION SCREEN
import 'package:bu_buddy/features/car/models/ride_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path/path.dart';

class RideVerificationScreen extends StatelessWidget {
  const RideVerificationScreen({super.key, required RideDetails rideDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildDetailsCard(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Iconsax.tick_circle, size: 80, color: Colors.blue)
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text('Verify Ride Details'),
        const SizedBox(height: 10),
        Text('Please confirm your ride information',
            style: TextStyle(color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade900,
      ),
      child: Column(
        children: [
          _buildDetailRow('From', 'New York City', Iconsax.location),
          const Divider(color: Colors.grey),
          _buildDetailRow('To', 'Los Angeles', Iconsax.location_tick),
          const Divider(color: Colors.grey),
          _buildDetailRow('Date', 'April 20, 2025', Iconsax.calendar),
          const Divider(color: Colors.grey),
          _buildDetailRow('Time', '09:30 AM', Iconsax.clock),
          const Divider(color: Colors.grey),
          _buildDetailRow('Seats', '3 Available', Iconsax.people),
          const Divider(color: Colors.grey),
          _buildDetailRow('Price', '\$50 per seat', Iconsax.money),
        ],
      ).animate().slideX(
        begin: -20,
        end: 0,
        delay: 200.ms,
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 15),
          Text(title, style: TextStyle(color: Colors.grey.shade400)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            icon: const Icon(Iconsax.edit),
            label: const Text('Edit'),
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Iconsax.tick_circle),
            label: const Text('Confirm'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ),
      ],
    );
  }
}
