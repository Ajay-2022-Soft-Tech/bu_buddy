import 'package:bu_buddy/features/car/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'dart:math' as math;

import '../../models/ride_details.dart';
import '../my_trips/my_trips.dart';

class RidePublishedConfirmationScreen extends StatefulWidget {
  final RideDetails rideDetails;

  const RidePublishedConfirmationScreen({
    Key? key,
    required this.rideDetails,
  }) : super(key: key);

  @override
  State<RidePublishedConfirmationScreen> createState() => _RidePublishedConfirmationScreenState();
}

class _RidePublishedConfirmationScreenState extends State<RidePublishedConfirmationScreen> with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundController;
  late ConfettiController _confettiController;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State variables
  bool _isLoading = true;
  RideDetails? _publishedRide;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    )..play();

    _fetchPublishedRide();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _fetchPublishedRide() async {
    try {
      final docSnapshot = await _firestore
          .collection('rides')
          .doc(widget.rideDetails.id)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        setState(() {
          _publishedRide = RideDetails(
            id: docSnapshot.id,
            userId: data['userId'] ?? '',
            userName: data['userName'] ?? 'Unknown',
            userAvatar: data['userAvatar'] ?? '',
            pickupLocation: data['pickupLocation'] ?? 'Unknown',
            destinationLocation: data['destinationLocation'] ?? 'Unknown',
            rideDate: data['rideDate'] ?? 'Unknown',
            rideTime: data['rideTime'] ?? 'Unknown',
            availableSeats: data['availableSeats'] ?? 0,
            price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isActive: data['isActive'] ?? true,
          );
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ride not found';
          _publishedRide = widget.rideDetails; // Fallback to the passed ride details
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _publishedRide = widget.rideDetails; // Fallback to the passed ride details
      });
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
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Confetti effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: const [
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.red,
                Colors.yellow,
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Success animation
                    _buildSuccessAnimation().animate()
                        .fadeIn(duration: 800.ms)
                        .scale(duration: 800.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 20),

                    // Success message
                    _buildSuccessMessage().animate()
                        .fadeIn(duration: 600.ms, delay: 400.ms)
                        .slideY(begin: 20, end: 0),

                    const SizedBox(height: 40),

                    // Ride summary
                    if (_isLoading)
                      _buildLoadingState()
                    else if (_errorMessage != null && _publishedRide == null)
                      _buildErrorState()
                    else
                      _buildRideSummary().animate()
                          .fadeIn(duration: 600.ms, delay: 800.ms)
                          .slideY(begin: 30, end: 0),

                    const SizedBox(height: 40),

                    // Action buttons
                    _buildActionButtons().animate()
                        .fadeIn(duration: 600.ms, delay: 1200.ms)
                        .slideY(begin: 30, end: 0),
                  ],
                ),
              ),
            ),
          ),
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
            isSuccess: true,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }

  Widget _buildSuccessAnimation() {
    return Lottie.network(
      'https://assets10.lottiefiles.com/packages/lf20_s2lryxtd.json',
      width: 200,
      height: 200,
      repeat: false,
    );
  }

  Widget _buildSuccessMessage() {
    return Column(
      children: [
        Text(
          'Ride Published!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your ride is now live and visible to other travelers',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching ride details...',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Iconsax.warning_2,
            color: Colors.red,
            size: 50,
          ),
          const SizedBox(height: 20),
          Text(
            'Error fetching ride details',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideSummary() {
    final ride = _publishedRide ?? widget.rideDetails;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),

          // Route information
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ride.pickupLocation,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'TO',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ride.destinationLocation,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Ride details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip(
                icon: Iconsax.calendar,
                label: ride.rideDate,
                color: Colors.purple,
              ),
              _buildDetailChip(
                icon: Iconsax.clock,
                label: ride.rideTime,
                color: Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailChip(
                icon: Iconsax.people,
                label: '${ride.availableSeats} seats',
                color: Colors.orange,
              ),
              _buildDetailChip(
                icon: Iconsax.money,
                label: '₹${ride.price.toStringAsFixed(0)}',
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Status badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.green.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active & Ready',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade500,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.to(() => MyTripsScreen()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.car),
                const SizedBox(width: 10),
                Text(
                  'View My Rides',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Get.offAll(() => CarHomeScreen()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.home),
              const SizedBox(width: 8),
              Text(
                'Back to Home',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  final bool isSuccess;

  BackgroundPainter({required this.animation, this.isSuccess = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Base gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [
        isSuccess ? const Color(0xFF0A2239) : const Color(0xFF101010),
        isSuccess ? const Color(0xFF153B50) : const Color(0xFF1A1A1A),
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
    final colors = isSuccess
        ? [
      Colors.blue.withOpacity(0.2),
      Colors.green.withOpacity(0.2),
      Colors.cyan.withOpacity(0.2),
    ]
        : [
      Colors.blue.withOpacity(0.15),
      Colors.purple.withOpacity(0.1),
      Colors.cyan.withOpacity(0.1),
    ];

    for (int i = 0; i < 50; i++) {
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
    for (int i = 0; i < 15; i++) {
      final xPos = size.width * random.nextDouble();
      final yPos = size.height * random.nextDouble();
      final baseRadius = 3.0 + random.nextDouble() * 8;
      final radius = baseRadius + 3.0 * math.sin(animation * 2 * math.pi + i);

      // Glow effect
      final color = colors[i % colors.length];
      final glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * 2,
        glowPaint,
      );

      // Core
      paint.color = color.withOpacity(0.8);
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
    paint.color = isSuccess
        ? Colors.blue.withOpacity(0.15)
        : Colors.blue.withOpacity(0.05);
    var path = Path();
    path.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.85 + 0.05 * math.sin(x / 50 + animValue));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    paint.color = isSuccess
        ? Colors.green.withOpacity(0.15)
        : Colors.purple.withOpacity(0.05);
    path = Path();
    path.moveTo(0, size.height * 0.9);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.9 + 0.04 * math.sin(x / 40 - animValue * 0.8));
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
