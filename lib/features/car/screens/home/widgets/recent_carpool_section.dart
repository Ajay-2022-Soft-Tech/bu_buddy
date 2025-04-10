// File: recent_carpools_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../widgets/recent_carpool_item.dart';

class RecentCarpoolsSection extends StatelessWidget {
  const RecentCarpoolsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reference to Firestore collection
    final carPoolsCollection = FirebaseFirestore.instance.collection('carpools');
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      margin: EdgeInsets.only(top: TSizes.spaceBtwSections),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: TColors.primary,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Recent Carpools',
                    style: TextStyle(
                      fontSize: TSizes.fontSizeLg,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  // View all functionality
                  // Navigate to a dedicated page with all carpools
                },
                icon: Text(
                  'View All',
                  style: TextStyle(
                    color: TColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                label: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: TColors.primary,
                ),
              ),
            ],
          ).animate()
              .fadeIn(duration: 600.ms, delay: 1100.ms)
              .moveY(begin: 10, end: 0),

          SizedBox(height: TSizes.sm),

          // StreamBuilder to listen to real-time updates from Firebase
          StreamBuilder<QuerySnapshot>(
            stream: carPoolsCollection
                .orderBy('createdAt', descending: true)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              // Handle loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(TSizes.lg),
                    child: CircularProgressIndicator(
                      color: TColors.primary,
                    ),
                  ),
                );
              }

              // Handle error state
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(TSizes.lg),
                    child: Text(
                      'Error loading carpools',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: TSizes.fontSizeMd,
                      ),
                    ),
                  ),
                );
              }

              // Handle empty data
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(TSizes.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.no_transfer_rounded,
                          size: 40,
                          color: TColors.textSecondary.withOpacity(0.7),
                        ),
                        SizedBox(height: TSizes.sm),
                        Text(
                          'No carpools available at the moment',
                          style: TextStyle(
                            color: TColors.textSecondary,
                            fontSize: TSizes.fontSizeMd,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Build list with available data
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // Get the document data
                  final carpoolDoc = snapshot.data!.docs[index];
                  final carpoolData = carpoolDoc.data() as Map<String, dynamic>;

                  // Create a RecentCarpoolItem for each carpool
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(carpoolData['driverId'])
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: EdgeInsets.all(TSizes.sm),
                          child: Center(child: LinearProgressIndicator()),
                        );
                      }

                      // Get driver information
                      final userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

                      return RecentCarpoolItem(
                        from: carpoolData['from'] ?? 'Unknown',
                        to: carpoolData['to'] ?? 'Unknown',
                        time: carpoolData['time'] ?? 'TBA',
                        date: carpoolData['date'] ?? 'TBA',
                        seats: carpoolData['availableSeats'] ?? 0,
                        driver: userData['displayName'] ?? 'Unknown Driver',
                        price: carpoolData['price'] != null
                            ? '₹${carpoolData['price']}'
                            : 'Free',
                        avatar: userData['photoURL'] ?? 'assets/images/avatars/default_avatar.png',
                        index: index,
                        onBookPressed: () {
                          // Book the ride functionality
                          _bookRide(context, carpoolDoc.id, currentUser?.uid ?? '');
                        },
                      );
                    },
                  );
                },
              ).animate()
                  .fadeIn(duration: 600.ms, delay: 1000.ms);
            },
          ),
        ],
      ),
    );
  }

  // Method to handle booking a ride
  void _bookRide(BuildContext context, String carpoolId, String userId) async {
    if (userId.isEmpty) {
      // User is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to book a ride')),
      );
      return;
    }

    try {
      // Start a transaction to ensure data consistency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current carpool document
        DocumentSnapshot carpoolDoc = await transaction.get(
            FirebaseFirestore.instance.collection('carpools').doc(carpoolId)
        );

        if (!carpoolDoc.exists) {
          throw Exception("Carpool doesn't exist!");
        }

        Map<String, dynamic> carpoolData = carpoolDoc.data() as Map<String, dynamic>;

        // Check if there are available seats
        int availableSeats = carpoolData['availableSeats'] ?? 0;

        if (availableSeats <= 0) {
          throw Exception("No seats available!");
        }

        // Check if user has already booked this ride
        List<dynamic> passengers = carpoolData['passengerIds'] ?? [];
        if (passengers.contains(userId)) {
          throw Exception("You've already booked this ride!");
        }

        // Update the carpool document
        transaction.update(
          FirebaseFirestore.instance.collection('carpools').doc(carpoolId),
          {
            'availableSeats': availableSeats - 1,
            'passengerIds': FieldValue.arrayUnion([userId]),
          },
        );

        // Create a booking record
        transaction.set(
          FirebaseFirestore.instance.collection('bookings').doc(),
          {
            'carpoolId': carpoolId,
            'userId': userId,
            'bookedAt': FieldValue.serverTimestamp(),
            'status': 'confirmed',
          },
        );
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ride booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}