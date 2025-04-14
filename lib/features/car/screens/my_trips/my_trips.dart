import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/ride_details.dart';
import '../../controllers/trip_controller.dart';
import '../chat_screen/chat_screen.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TripController _tripController = Get.put(TripController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tripController.fetchTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background with animated gradient
          _buildAnimatedBackground(isDark),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),

                // Tab bar
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: isDark ? Colors.white : TColors.primary,
                    unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    indicator: BoxDecoration(
                      color: isDark ? TColors.primary.withOpacity(0.2) : TColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: TColors.primary.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    tabs: [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Past'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripsList(true, isDark),  // Upcoming trips
                      _buildTripsList(false, isDark),  // Past trips
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Color(0xFF121212), Color(0xFF1E1E24)]
              : [Color(0xFFF5F7FB), Color(0xFFE4E9F2)],
        ),
      ),
      child: CustomPaint(
        painter: BackgroundPainter(isDark: isDark),
        child: Container(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : TColors.primary,
              ),
            ),
            onPressed: () => Get.back(),
          ),
          SizedBox(width: 16),
          Text(
            'My Trips',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TColors.textPrimary,
            ),
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Iconsax.filter,
              color: isDark ? Colors.white : TColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(bool isUpcoming, bool isDark) {
    return Obx(() {
      if (_tripController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: TColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Loading your trips...',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }

      final trips = isUpcoming
          ? _tripController.upcomingTrips
          : _tripController.pastTrips;

      if (trips.isEmpty) {
        return _buildEmptyState(isUpcoming, isDark);
      }

      return ListView.builder(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, isDark, index)
              .animate()
              .fadeIn(duration: 400.ms, delay: (100 * index).ms)
              .slideY(begin: 30, end: 0, curve: Curves.easeOutQuint);
        },
      );
    });
  }

  Widget _buildEmptyState(bool isUpcoming, bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              isUpcoming
                  ? 'https://assets3.lottiefiles.com/packages/lf20_ucbyrun5.json'  // Car animation
                  : 'https://assets8.lottiefiles.com/temp/lf20_nXwOJj.json',  // History animation
              width: 200,
              height: 200,
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              isUpcoming ? 'No Upcoming Trips' : 'No Past Trips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : TColors.textPrimary,
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems / 2),
            Text(
              isUpcoming
                  ? 'You don\'t have any upcoming trips. Book or publish a ride to get started.'
                  : 'Your past trips will appear here once you complete some rides.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            ElevatedButton(
              onPressed: () => isUpcoming
                  ? Get.offAllNamed('/home')
                  : _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: TColors.primary.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isUpcoming ? Iconsax.add_circle : Iconsax.arrow_up_1),
                  SizedBox(width: 8),
                  Text(
                    isUpcoming ? 'Find a Ride' : 'View Upcoming',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(RideDetails trip, bool isDark, int index) {
    final bool isMyRide = trip.userId == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.grey.shade700.withOpacity(0.5)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header with curved corners and status badge
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.grey.shade700.withOpacity(0.5)
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: TColors.primary.withOpacity(isDark ? 0.3 : 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isMyRide ? Iconsax.car : Iconsax.user,
                          color: TColors.primary,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMyRide ? 'Your Published Ride' : 'Ride with ${trip.userName}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : TColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Iconsax.calendar,
                                  size: 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  trip.rideDate,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.green.withOpacity(isDark ? 0.4 : 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '₹${trip.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Route info with animated route line
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        _buildAnimatedRouteLine(),
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                trip.pickupLocation,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : TColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TO',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                trip.destinationLocation,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : TColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Trip info chips in a row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildInfoChip(
                        icon: Iconsax.clock,
                        label: trip.rideTime,
                        color: Colors.purple,
                        isDark: isDark,
                      ),
                      SizedBox(width: 10),
                      _buildInfoChip(
                        icon: Iconsax.people,
                        label: '${trip.availableSeats} seats',
                        color: Colors.orange,
                        isDark: isDark,
                      ),
                      SizedBox(width: 10),
                      _buildStatusChip(
                        trip.isActive,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          isMyRide ? Iconsax.trash : Iconsax.support,
                          size: 18,
                        ),
                        label: Text(
                          isMyRide ? 'Cancel Ride' : 'Support',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: isMyRide ?
                            () => _tripController.cancelRide(trip) :
                            () => _showSupportDialog(context, isDark),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isMyRide ? Colors.red : Colors.grey.shade700,
                          side: BorderSide(
                            color: isMyRide ? Colors.red.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isMyRide ? Iconsax.eye : Iconsax.message,
                          size: 18,
                        ),
                        label: Text(
                          isMyRide ? 'View Details' : 'Message',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          final rideDetailsMap = {
                            'from': trip.pickupLocation,
                            'to': trip.destinationLocation,
                            'time': trip.rideTime,
                            'date': trip.rideDate,
                            'price': '₹${trip.price.toStringAsFixed(0)}',
                            'seats': trip.availableSeats.toString(),
                            'student': trip.userName,
                            'studentId': trip.userId,
                          };

                          Get.to(() => ChatScreen(
                            receiverId: trip.userId,
                            receiverName: trip.userName,
                            rideDetails: rideDetailsMap,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedRouteLine() {
    return Container(
      width: 2,
      height: 40,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(2, constraints.maxHeight),
            painter: DashedLinePainter(),
          );
        },
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? color.withOpacity(0.9) : color,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? color.withOpacity(0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, {required bool isDark}) {
    final Color color = isActive ? Colors.green : Colors.grey;
    final String label = isActive ? 'Active' : 'Completed';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Iconsax.tick_circle : Iconsax.tick_square,
            size: 16,
            color: isDark ? color.withOpacity(0.9) : color,
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? color.withOpacity(0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.support, color: TColors.primary),
            ),
            SizedBox(width: 12),
            Text('Contact Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What issue are you facing with this ride?',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Support Request Sent',
                'Our team will contact you shortly',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(10),
                borderRadius: 10,
                duration: Duration(seconds: 3),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background
class BackgroundPainter extends CustomPainter {
  final bool isDark;

  BackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // First shape
    paint.color = (isDark ? TColors.primary.withOpacity(0.05) : TColors.primary.withOpacity(0.03));
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.2,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, paint);

    // Second shape
    paint.color = (isDark ? Colors.purple.withOpacity(0.05) : Colors.blue.withOpacity(0.03));
    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.9,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Painter for dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.8)
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
