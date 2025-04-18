import 'package:bu_buddy/features/car/screens/home/widgets/feature_card.dart';
import 'package:bu_buddy/features/personalization/screens/chat_bot/chat_bot.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

import '../../models/ride_details.dart';
import '../my_trips/my_trips.dart';
import '../publish_ride/publish_ride.dart';
import '../../controllers/trip_controller.dart';
import 'find_a_ride.dart';

class CarHomeScreen extends StatefulWidget {
  const CarHomeScreen({Key? key}) : super(key: key);

  @override
  State<CarHomeScreen> createState() => _CarHomeScreenState();
}

class _CarHomeScreenState extends State<CarHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TripController _tripController = Get.put(TripController());

  String _userName = 'User';
  bool _isLoading = true;
  bool _hasNotifications = false;
  List<RideDetails> _recentRides = [];
  bool _isLoadingRides = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _getCurrentUser(),
      _fetchRecentRides(),
    ]);
  }

  Future<void> _getCurrentUser() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Try to get username from display name first
      if (currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
        _userName = currentUser.displayName!.split(' ').first;
      } else {
        // Otherwise try Firestore
        try {
          final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null) {
              _userName = userData['name']?.toString().split(' ').first ??
                  userData['firstName'] ??
                  userData['fullName']?.toString().split(' ').first ??
                  'User';
            }
          }
        } catch (e) {
          developer.log('Error fetching user data: $e');
        }
      }

      // Check for notifications
      try {
        final notificationsSnapshot = await _firestore
            .collection('chat_bot')
            .where('userId', isEqualTo: currentUser.uid)
            .where('read', isEqualTo: false)
            .limit(1)
            .get();

        _hasNotifications = notificationsSnapshot.docs.isNotEmpty;
      } catch (e) {
        developer.log('Error fetching notifications: $e');
      }
    } catch (e) {
      developer.log('Error getting user data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchRecentRides() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRides = true;
      _errorMessage = null;
    });

    try {
      if (_auth.currentUser == null) throw Exception("User not logged in");

      // Simple query to avoid index issues
      final querySnapshot = await _firestore
          .collection('rides')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .limit(5)
          .get();

      final List<RideDetails> rides = [];
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          rides.add(RideDetails(
            id: doc.id,
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
          ));
        } catch (e) {
          developer.log('Error parsing ride: $e');
        }
      }

      // Sort by newest first
      rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _recentRides = rides;
          _isLoadingRides = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching rides: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingRides = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _getCurrentUser(),
      _fetchRecentRides(),
      _tripController.fetchTrips(),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => CustomPaint(
              painter: BackgroundPainter(animation: _animationController.value),
              child: Container(width: double.infinity, height: double.infinity),
            ),
          ),

          // Main content
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                : RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.blue,
              backgroundColor: Colors.grey.shade900,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // App bar with logo and actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildAppBar(),
                        ),

                        const SizedBox(height: 24),

                        // User greeting section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildGreetingSection(),
                        ).animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -20, end: 0, curve: Curves.easeOutQuad),

                        const SizedBox(height: 30),

                        // Available rides section
                        const RideOfferSlider().animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms),

                        const SizedBox(height: 30),

                        // Quick actions
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildQuickActionsSection(),
                        ).animate()
                            .fadeIn(duration: 600.ms, delay: 600.ms)
                            .slideY(begin: 20, end: 0),

                        const SizedBox(height: 30),

                        // Recent carpools
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildRecentCarpoolsSection(),
                        ).animate()
                            .fadeIn(duration: 600.ms, delay: 900.ms),

                        const SizedBox(height: 100), // Bottom padding for FAB
                      ],
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

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo and app name
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade800]),
              ),
              child: const Center(
                child: Text('B',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('BuBuddy',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // Search and notification icons
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => Get.to(() => FindARideScreen()),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 16),
            _buildNotificationIcon(),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => Get.to(() => ChatbotScreen()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
        if (_hasNotifications)
          Positioned(
            right: 0, top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning,' : (hour < 17 ? 'Good Afternoon,' : 'Good Evening,');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greeting,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Flexible(
              child: Text(_userName,
                style: const TextStyle(
                  color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text('Top Rider',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with icon
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.flash_1, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text('Quick Actions',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Action buttons - horizontally scrollable
        SizedBox(
          height: 110, // Fixed height for the scroll area
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildActionButton(Iconsax.search_normal, 'Find Rides', Colors.blue,
                      () => Get.to(() => FindARideScreen())),
              const SizedBox(width: 16),
              _buildActionButton(Iconsax.add, 'Publish Ride', Colors.green,
                      () => Get.to(() => PublishRideScreen())!.then((_) => _fetchRecentRides())),
              const SizedBox(width: 16),
              _buildActionButton(Iconsax.clock, 'History', Colors.purple,
                      () => Get.to(() => MyTripsScreen())),
              const SizedBox(width: 16),
              _buildActionButton(Iconsax.heart, 'Save', Colors.red, () {}),
              const SizedBox(width: 16),
              _buildActionButton(Iconsax.map, 'Locations', Colors.orange, () {}),
              // Add more buttons here as needed
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCarpoolsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.clock, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                const Text('Recent Carpools',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            TextButton(
              onPressed: () => Get.to(() => MyTripsScreen()),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All', style: TextStyle(color: Colors.blue)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Content based on state
        if (_isLoadingRides)
          _buildCarpoolsLoadingState()
        else if (_errorMessage != null)
          _buildCarpoolsErrorState()
        else if (_recentRides.isEmpty)
            _buildEmptyCarpoolsState()
          else
            Column(
              children: _recentRides.take(3).map((trip) => _buildCarpoolItem(trip)).toList(),
            ),
      ],
    );
  }

  Widget _buildCarpoolsLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: const Column(
        children: [
          CircularProgressIndicator(color: Colors.blue, strokeWidth: 3),
          SizedBox(height: 20),
          Text('Loading your recent rides...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCarpoolsErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('Something went wrong',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage ?? 'Failed to load your recent carpools',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchRecentRides,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCarpoolsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(Iconsax.car, color: Colors.blue.withOpacity(0.3), size: 48),
          const SizedBox(height: 16),
          const Text('No recent carpools',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text('Your recent rides will appear here',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.to(() => PublishRideScreen())!.then((_) => _fetchRecentRides()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Publish a Ride'),
          ),
        ],
      ),
    );
  }

  Widget _buildCarpoolItem(RideDetails trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          // From/To row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('From', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(trip.pickupLocation,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('To', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(trip.destinationLocation,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 16),

          // Details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Time and date
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text('${trip.rideTime} • ${trip.rideDate}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              // Price
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('₹${trip.price.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Seats and view details row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Seats
              Row(
                children: [
                  const Icon(Icons.person_outline, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text('${trip.availableSeats} seats',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              // View details button
              ElevatedButton(
                onPressed: () => Get.to(() => MyTripsScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animation;
  BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    canvas.drawColor(Colors.black, BlendMode.src);

    final colors = [
      Colors.blue.withOpacity(0.15),
      Colors.purple.withOpacity(0.1),
      Colors.cyan.withOpacity(0.1),
    ];

    // Small particles
    for (int i = 0; i < 20; i++) {
      final xPos = (size.width * 0.1) + (size.width * 0.8 * ((i * 7919) % 100) / 100);
      final yPos = (size.height * 0.1) + (size.height * 0.8 * ((i * 6733) % 100) / 100);
      final radius = 2.0 + 5.0 * math.sin(animation * 2 * math.pi + i);

      final paint = Paint()..color = colors[i % colors.length].withOpacity(0.1);
      canvas.drawCircle(Offset(xPos, yPos), radius, paint);
    }

    // Larger glowing particles
    for (int i = 0; i < 8; i++) {
      final color = colors[i % colors.length];
      final xPos = (size.width * 0.1) + (size.width * 0.8 * ((i * 5039) % 100) / 100);
      final yPos = (size.height * 0.1) + (size.height * 0.8 * ((i * 4271) % 100) / 100);
      final radius = 10.0 + 15.0 * math.sin(animation * 2 * math.pi + i);

      // Glow effect
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
      canvas.drawCircle(Offset(xPos, yPos), radius * 1.5, glowPaint);

      // Core
      final corePaint = Paint()..color = color;
      canvas.drawCircle(Offset(xPos, yPos), radius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

