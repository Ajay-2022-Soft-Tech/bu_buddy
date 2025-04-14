import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../models/ride_details.dart';
import '../home/home.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class RidePublishedConfirmationScreen extends StatelessWidget {
  final RideDetails rideDetails;

  const RidePublishedConfirmationScreen({Key? key, required this.rideDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success animation
                // Lottie.network(
                //   'https://assets4.lottiefiles.com/packages/lf20_touohxv0.json',
                //   width: 200,
                //   height: 200,
                //   repeat: false,
                // ).animate!.sc(
                //   duration: 600.ms,
                //   curve: Curves.elasticOut,
                //   begin: Offset(0.5, 0.5),
                //   end: Offset(1, 1),
                // ),

                SizedBox(height: TSizes.spaceBtwSections - 10),

                // Success title
                Text(
                  'Ride Published Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                ).animate().fadeIn(
                  duration: 600.ms,
                  delay: 400.ms,
                ),

                SizedBox(height: 8),

                // Success subtitle
                Text(
                  'Your ride is now visible to other students',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ).animate().fadeIn(
                  duration: 600.ms,
                  delay: 600.ms,
                ),

                SizedBox(height: TSizes.spaceBtwSections),

                // Ride details card
                _buildRideDetailsCard(context, isDark)
                    .animate().fadeIn(
                  duration: 600.ms,
                  delay: 800.ms,
                )
                    .slideY(
                  begin: 50,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),

                SizedBox(height: TSizes.spaceBtwSections),

                // Action buttons
                _buildActionButtons(context, isDark)
                    .animate().fadeIn(
                  duration: 600.ms,
                  delay: 1000.ms,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideDetailsCard(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(TSizes.lg),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Route
          _buildDetailRow(
            icon: Iconsax.location,
            title: 'From',
            subtitle: rideDetails.pickupLocation,
            color: Colors.blue,
            isDark: isDark,
          ),

          _buildDivider(isDark),

          _buildDetailRow(
            icon: Iconsax.location_tick,
            title: 'To',
            subtitle: rideDetails.destinationLocation,
            color: Colors.red,
            isDark: isDark,
          ),

          _buildDivider(isDark),

          // Date, time and seats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailColumn(
                icon: Iconsax.calendar,
                title: 'Date',
                subtitle: rideDetails.rideDate,
                color: Colors.purple,
                isDark: isDark,
              ),
              _buildDetailColumn(
                icon: Iconsax.clock,
                title: 'Time',
                subtitle: rideDetails.rideTime,
                color: Colors.orange,
                isDark: isDark,
              ),
              _buildDetailColumn(
                icon: Iconsax.people,
                title: 'Seats',
                subtitle: '${rideDetails.availableSeats}',
                color: Colors.green,
                isDark: isDark,
              ),
            ],
          ),

          _buildDivider(isDark),

          // Price
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.money,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    '₹${rideDetails.price.toStringAsFixed(0)} per seat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
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
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
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
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 30,
      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Back to home button
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.offAll(() => CarHomeScreen()),
            style: OutlinedButton.styleFrom(
              foregroundColor: TColors.primary,
              side: BorderSide(color: TColors.primary, width: 2),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.home),
                SizedBox(width: 8),
                Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 16),

        // Share ride button
        Expanded(
          child: ElevatedButton(
            onPressed: () => null,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.share),
                SizedBox(width: 8),
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

//   void _shareRideDetails() {
//     final shareText = '''
// 🚗 Carpooling Ride Share 🚗
//
// From: ${rideDetails.pickupLocation}
// To: ${rideDetails.destinationLocation}
// Date: ${rideDetails.rideDate}
// Time: ${rideDetails.rideTime}
// Available Seats: ${rideDetails.availableSeats}
// Price: ₹${rideDetails.price.toStringAsFixed(0)} per seat
//
// Join me for this ride in the Student Carpooling App!
// ''';
//
//     Share.share(shareText);
//   }
}
