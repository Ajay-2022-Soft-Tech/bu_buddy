import 'dart:math';
import 'dart:ui';

import 'package:bu_buddy/features/car/screens/home/find_a_ride.dart';
import 'package:bu_buddy/features/car/screens/home/widgets/carpool_home_appbar.dart';
import 'package:bu_buddy/features/car/screens/home/widgets/feature_card.dart';
import 'package:bu_buddy/features/car/screens/home/widgets/recent_carpool_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';

class CarHomeScreen extends StatefulWidget {
  const CarHomeScreen({super.key});

  @override
  State<CarHomeScreen> createState() => _CarHomeScreenState();
}

class _CarHomeScreenState extends State<CarHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // For parallax effect - using ValueNotifier to avoid excessive rebuilds
  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  // Reduced number of particles
  final List<Color> _particleColors = [
    Colors.white.withOpacity(0.3),
    Colors.white.withOpacity(0.2),
    Colors.white.withOpacity(0.25),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _controller.forward();

    // Add scroll listener with throttling
    _scrollController.addListener(_throttledScrollListener);
  }

  // Last update time for throttling
  DateTime _lastScrollUpdate = DateTime.now();

  // Throttled scroll listener to reduce update frequency
  void _throttledScrollListener() {
    final now = DateTime.now();
    if (now.difference(_lastScrollUpdate) > Duration(milliseconds: 100)) {
      _scrollOffset.value = _scrollController.offset;
      _lastScrollUpdate = now;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: CarpoolHomeAppBar(),
      body: Stack(
        children: [
          // Static gradient background instead of animated
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  TColors.primary.withOpacity(0.95),
                  TColors.primary.withOpacity(0.5),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.5],
              ),
            ),
          ),

          // Static particles instead of animated
          _buildStaticParticles(),

          // Main content with optimized animations
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return RefreshIndicator(
                  color: TColors.primary,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    // Add refresh functionality here
                    return Future.delayed(Duration(seconds: 1));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(TSizes.defaultSpace),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Welcome Section with simplified animation
                                _buildWelcomeSection(controller),

                                // Feature card without parallax
                                ImprovedFeatureCard(),

                                // Optimized quick action buttons
                                _buildQuickActions(controller),

                                // Recent carpools section without transform
                                RecentCarpoolsSection(),

                                // Add some space at the bottom
                                SizedBox(height: 70),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _scrollOffset,
        builder: (context, offset, child) {
          return AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: offset > 100 ? 1.0 : 0.0,
            child: FloatingActionButton(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                // Scroll to top
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Icon(Icons.arrow_upward),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaticParticles() {
    // Generate static particle positions instead of animating them
    final random = Random();
    return CustomPaint(
      painter: StaticParticlePainter(
        particleCount: 10, // Reduced from 15
        colors: _particleColors,
        random: random,
      ),
      size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
    );
  }

  Widget _buildWelcomeSection(UserController controller) {
    return Container(
      margin: EdgeInsets.only(top: TSizes.lg, bottom: TSizes.md),
      child: Obx(() {
        return controller.profileLoading.value
            ? Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 250,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getTimeOfDay()},',
              style: TextStyle(
                fontSize: TSizes.fontSizeMd,
                color: TColors.white,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  '${controller.user.value.firstName}',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeLg * 1.5,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                _buildSimplifiedBadge(),
              ],
            ),
          ],
        );
      }),
    );
  }

  // Simpler badge without animations
  Widget _buildSimplifiedBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            'Top Rider',
            style: TextStyle(
              fontSize: TSizes.fontSizeSm * 0.9,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(UserController controller) {
    return Container(
      margin: EdgeInsets.only(top: TSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bolt,
                color: TColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: TSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: TSizes.md),
          controller.profileLoading.value
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
            ),
          )
              : _buildQuickActionButtons(),
        ],
      ),
    );
  }

  // More efficient button rendering without per-index animations
  Widget _buildQuickActionButtons() {
    final actions = [
      {
        'icon': Icons.search,
        'label': 'Find Rides',
        'color': Colors.blue.shade700,
      },
      {
        'icon': Icons.add_circle_outline,
        'label': 'Offer Ride',
        'color': Colors.green.shade700,

      },
      {
        'icon': Icons.history,
        'label': 'History',
        'color': Colors.purple.shade700,
      },
      {
        'icon': Icons.favorite,
        'label': 'Saved',
        'color': Colors.red.shade700,
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profile',
        'color': Colors.orange.shade700,
      },
    ];

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return _buildActionButton(
            icon: actions[index]['icon'] as IconData,
            label: actions[index]['label'] as String,
            color: actions[index]['color'] as Color,

          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(18),
                splashColor: color.withOpacity(0.2),
                highlightColor: color.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm,
              fontWeight: FontWeight.w600,
              color: TColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}

// Optimized static particle painter that doesn't animate
class StaticParticlePainter extends CustomPainter {
  final int particleCount;
  final List<Color> colors;
  final Random random;
  late final List<Offset> positions;
  late final List<double> sizes;
  late final List<Color> particleColors;

  StaticParticlePainter({
    required this.particleCount,
    required this.colors,
    required this.random,
  }) {
    // Generate static positions and sizes once
    positions = List.generate(particleCount, (_) =>
        Offset(random.nextDouble() * 400, random.nextDouble() * 800)
    );

    sizes = List.generate(particleCount, (_) =>
    2 + random.nextDouble() * 6
    );

    particleColors = List.generate(particleCount, (_) =>
    colors[random.nextInt(colors.length)]
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particleCount; i++) {
      final paint = Paint()
        ..color = particleColors[i]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(positions[i], sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}