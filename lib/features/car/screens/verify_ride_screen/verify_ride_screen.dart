import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

import '../../models/ride_details.dart';
import '../publish_ride/publish_ride_confirmation_screen.dart';

class RideVerificationScreen extends StatefulWidget {
  final RideDetails rideDetails;

  const RideVerificationScreen({
    Key? key,
    required this.rideDetails,
  }) : super(key: key);

  @override
  State<RideVerificationScreen> createState() => _RideVerificationScreenState();
}

class _RideVerificationScreenState extends State<RideVerificationScreen> with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundController;

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _publishRide() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('You must be logged in to publish a ride');
      }

      // Convert RideDetails to a Map
      final Map<String, dynamic> rideData = {
        'userId': widget.rideDetails.userId,
        'userName': widget.rideDetails.userName,
        'userAvatar': widget.rideDetails.userAvatar,
        'pickupLocation': widget.rideDetails.pickupLocation,
        'destinationLocation': widget.rideDetails.destinationLocation,
        'rideDate': widget.rideDetails.rideDate,
        'rideTime': widget.rideDetails.rideTime,
        'availableSeats': widget.rideDetails.availableSeats,
        'price': widget.rideDetails.price,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'isActive': true,
      };

      // Add to Firestore
      final docRef = await _firestore.collection('rides').add(rideData);

      // Update the ride with the document ID
      final updatedRideDetails = widget.rideDetails.copyWith(
        id: docRef.id,
      );

      // Navigate to confirmation screen with the updated ride details
      Get.off(() => RidePublishedConfirmationScreen(rideDetails: updatedRideDetails));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to publish ride: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        icon: const Icon(Iconsax.warning_2, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.arrow_left,
              color: Colors.white,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Verify Ride Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Header section
                    _buildHeader().animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -20, end: 0),

                    const SizedBox(height: 30),

                    // Ride details card
                    _buildRideDetailsCard().animate()
                        .fadeIn(duration: 600.ms, delay: 200.ms)
                        .slideY(begin: 30, end: 0),

                    const SizedBox(height: 40),

                    // Action buttons
                    _buildActionButtons().animate()
                        .fadeIn(duration: 700.ms, delay: 400.ms)
                        .slideY(begin: 30, end: 0),
                  ],
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            animation: _backgroundController.value,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.verify,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost There!',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Please verify your ride details before publishing',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Route details
          _buildDetailRow(
            title: 'From',
            value: widget.rideDetails.pickupLocation,
            icon: Iconsax.location,
            iconColor: Colors.blue,
          ),
          const Divider(color: Colors.grey, height: 30),
          _buildDetailRow(
            title: 'To',
            value: widget.rideDetails.destinationLocation,
            icon: Iconsax.location_tick,
            iconColor: Colors.red,
          ),
          const Divider(color: Colors.grey, height: 30),

          // Schedule details
          _buildDetailRow(
            title: 'Date',
            value: widget.rideDetails.rideDate,
            icon: Iconsax.calendar,
            iconColor: Colors.purple,
          ),
          const Divider(color: Colors.grey, height: 30),
          _buildDetailRow(
            title: 'Time',
            value: widget.rideDetails.rideTime,
            icon: Iconsax.clock,
            iconColor: Colors.amber,
          ),
          const Divider(color: Colors.grey, height: 30),

          // Ride configurations
          _buildDetailRow(
            title: 'Available Seats',
            value: '${widget.rideDetails.availableSeats}',
            icon: Iconsax.people,
            iconColor: Colors.orange,
          ),
          const Divider(color: Colors.grey, height: 30),
          _buildDetailRow(
            title: 'Price per Seat',
            value: '₹${widget.rideDetails.price.toStringAsFixed(0)}',
            icon: Iconsax.money,
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              side: BorderSide(color: Colors.grey.shade600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.edit),
                const SizedBox(width: 8),
                Text(
                  'Edit Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade500,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade700.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _publishRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.tick_circle),
                  const SizedBox(width: 8),
                  Text(
                    'Publish Ride',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets6.lottiefiles.com/packages/lf20_x62chJ.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Publishing your ride...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: Text(
                'Please wait while we process your information',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;

  BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Base gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF101010),
        const Color(0xFF1A1A1A),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw animated particles
    _drawParticles(canvas, size, paint);

    // Draw animated waves at bottom
    _drawWaves(canvas, size, paint);
  }

  void _drawParticles(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);

    // Different color particles
    final colors = [
      Colors.blue.withOpacity(0.15),
      Colors.purple.withOpacity(0.1),
      Colors.cyan.withOpacity(0.1),
    ];

    for (int i = 0; i < 40; i++) {
      final xPos = size.width * random.nextDouble();
      final yPos = size.height * random.nextDouble();
      final radius = 1.0 + 3.0 * math.sin(animation * 2 * math.pi + i);

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius,
        paint,
      );
    }

    // Draw larger glowing particles
    for (int i = 0; i < 10; i++) {
      final xPos = size.width * random.nextDouble();
      final yPos = size.height * random.nextDouble();
      final baseRadius = 3.0 + random.nextDouble() * 8;
      final radius = baseRadius + 3.0 * math.sin(animation * 2 * math.pi + i);

      // Glow effect
      final color = colors[i % colors.length];
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * 2,
        glowPaint,
      );

      // Core
      paint.color = color.withOpacity(0.7);
      canvas.drawCircle(
        Offset(xPos, yPos),
        radius,
        paint,
      );
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final animValue = animation * 2 * math.pi;

    // First wave
    paint.color = Colors.blue.withOpacity(0.05);
    var path = Path();
    path.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.85 + 0.04 * math.sin(x / 50 + animValue));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    paint.color = Colors.purple.withOpacity(0.05);
    path = Path();
    path.moveTo(0, size.height * 0.9);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.9 + 0.03 * math.sin(x / 40 - animValue * 0.8));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
