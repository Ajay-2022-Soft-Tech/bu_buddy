import 'package:bu_buddy/features/car/screens/home/widgets/buttons.dart';
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
      appBar: _buildAnimatedAppBar(size),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TColors.primary.withOpacity(0.9),
              TColors.primary.withOpacity(0.5),
              Colors.white,
            ],
            stops: const [0.0, 0.2, 0.4],
          ),
        ),
        child: SafeArea(
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
                              // Welcome Section with Wave Animation
                              _buildWelcomeSection(controller),

                              // Stylish Card with Glass Effect
                              _buildFeatureCard(),

                              // Quick Action Buttons
                              _buildQuickActions(controller),

                              // Recent Carpools Section
                              _buildRecentCarpoolsSection(),

                              // Add some space at the bottom to prevent FAB overlap
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
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAnimatedAppBar(Size size) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Container(
        width: size.width * 0.55,
        height: 50,
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Carpool Home',
                style: TextStyle(
                  fontSize: TSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: TColors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ).animate()
          .fadeIn(duration: 800.ms)
          .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuint),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              Icon(Icons.notifications_rounded, color: TColors.white),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          onPressed: () {
            // Notification functionality
          },
        ).animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .moveX(begin: 20, end: 0, curve: Curves.easeOutQuint),
      ],
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
              'Good Morning,',
              style: TextStyle(
                fontSize: TSizes.fontSizeMd,
                color: TColors.white,
                fontWeight: FontWeight.w500,
              ),
            ).animate()
                .fadeIn(duration: 600.ms)
                .moveY(begin: 10, end: 0, curve: Curves.easeOutQuint),

            SizedBox(height: 5),

            Row(
              children: [
                Text(
                  '${controller.user.value.firstName}',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeLg * 1.3,
                    fontWeight: FontWeight.bold,
                    color: TColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
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
                        size: 14,
                      ),
                      SizedBox(width: 4),
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
                ).animate().fadeIn(delay: 300.ms),
              ],
            ).animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .moveY(begin: 10, end: 0, curve: Curves.easeOutQuint),
          ],
        );
      }),
    );
  }

  Widget _buildFeatureCard() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: TSizes.md),
      child: Stack(
        children: [
          // Main Card with Image and Glass Effect
          Card(
            elevation: 10,
            shadowColor: Colors.black45,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
              child: Container(
                height: 260,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    Image.asset(
                      'assets/images/selection_menu/car_pool.jpg',
                      fit: BoxFit.cover,
                    ).animate()
                        .fadeIn(duration: 1000.ms),

                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(TSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Glass effect container
                          Container(
                            padding: EdgeInsets.all(TSizes.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car_filled,
                                      color: TColors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Find Your Next Ride',
                                      style: TextStyle(
                                        fontSize: TSizes.fontSizeLg * 1.2,
                                        fontWeight: FontWeight.bold,
                                        color: TColors.white,
                                      ),
                                    ),
                                  ],
                                ).animate()
                                    .fadeIn(duration: 800.ms, delay: 400.ms)
                                    .moveX(begin: -20, end: 0),

                                SizedBox(height: TSizes.sm),

                                Text(
                                  'Connect with fellow travelers and reduce your carbon footprint',
                                  style: TextStyle(
                                    fontSize: TSizes.fontSizeSm,
                                    color: TColors.white.withOpacity(0.9),
                                  ),
                                ).animate()
                                    .fadeIn(duration: 800.ms, delay: 600.ms)
                                    .moveX(begin: -20, end: 0),

                                SizedBox(height: TSizes.md),

                                ElevatedButton(
                                  onPressed: () {
                                    // Find Ride action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: TColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: TSizes.lg,
                                      vertical: TSizes.sm,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                    shadowColor: TColors.primary.withOpacity(0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Find A Ride',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: TSizes.fontSizeMd,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                                ).animate()
                                    .fadeIn(duration: 800.ms, delay: 800.ms)
                                    .moveY(begin: 20, end: 0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
              .fadeIn(duration: 800.ms, delay: 300.ms)
              .moveY(begin: 30, end: 0, curve: Curves.easeOutQuint),

          // Floating indicator
          Positioned(
            right: 20,
            top: 20,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: TSizes.md,
                vertical: TSizes.xs,
              ),
              decoration: BoxDecoration(
                color: TColors.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: TColors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Popular',
                    style: TextStyle(
                      fontSize: TSizes.fontSizeSm * 0.9,
                      fontWeight: FontWeight.bold,
                      color: TColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 800.ms)
              .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
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
          ).animate()
              .fadeIn(duration: 600.ms, delay: 900.ms)
              .moveY(begin: 10, end: 0),

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
              : _buildEnhancedButtons(),
        ],
      ),
    );
  }

  Widget _buildEnhancedButtons() {
    return Container(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        children: [
          _buildActionButton(
            icon: Icons.search,
            label: 'Find Rides',
            color: Colors.blue.shade700,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.add_circle_outline,
            label: 'Offer Ride',
            color: Colors.green.shade700,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.history,
            label: 'History',
            color: Colors.purple.shade700,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.favorite,
            label: 'Saved',
            color: Colors.red.shade700,
            onTap: () {},
          ),
          _buildActionButton(
            icon: Icons.person_outline,
            label: 'Profile',
            color: Colors.orange.shade700,
            onTap: () {},
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 800.ms, delay: 1000.ms)
        .moveY(begin: 20, end: 0, curve: Curves.easeOutQuint);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 90,
      margin: EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
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
                onTap: onTap,
                borderRadius: BorderRadius.circular(15),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
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

  Widget _buildRecentCarpoolsSection() {
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

          // Carpool List - Expanded for more examples and better UI
          ...List.generate(
            3,
                (index) => buildRecentCarpoolItem(index),
          ),
        ],
      ),
    );
  }

  Widget buildRecentCarpoolItem(int index) {
    final List<Map<String, dynamic>> carpools = [
      {
        'from': 'Bennett',
        'to': 'Parichowk',
        'time': '3:30 PM',
        'date': 'Today',
        'seats': 3,
        'driver': 'Michael',
        'price': '₹50',
        'avatar': 'assets/images/avatars/avatar1.png',
      },
      {
        'from': 'Library',
        'to': 'Mall',
        'time': '5:00 PM',
        'date': 'Today',
        'seats': 2,
        'driver': 'Sarah',
        'price': '₹40',
        'avatar': 'assets/images/avatars/avatar2.png',
      },
      {
        'from': 'Campus',
        'to': 'Railway Station',
        'time': '6:15 PM',
        'date': 'Tomorrow',
        'seats': 1,
        'driver': 'David',
        'price': '₹60',
        'avatar': 'assets/images/avatars/avatar3.png',
      },
    ];

    // If we've reached the end of our actual data, don't try to render
    if (index >= carpools.length) return SizedBox();

    return Container(
      margin: EdgeInsets.only(bottom: TSizes.md),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Padding(
          padding: EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: TColors.primary,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                carpools[index]['from'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: TSizes.fontSizeMd,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: TColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                carpools[index]['to'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: TSizes.fontSizeMd,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: TColors.textSecondary,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${carpools[index]['time']} • ${carpools[index]['date']}',
                                      style: TextStyle(
                                        fontSize: TSizes.fontSizeSm * 0.85,
                                        color: TColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                carpools[index]['price'],
                                style: TextStyle(
                                  fontSize: TSizes.fontSizeSm,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.primary,
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
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: TColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${carpools[index]['seats']} seats available',
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm * 0.9,
                          color: TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Book ride functionality
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: TSizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 1200.ms + (index * 200).ms)
        .moveX(begin: 30, end: 0, curve: Curves.easeOutQuint);
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        // Create new carpool
      },
      backgroundColor: TColors.primary,
      label: Text(
        'Create Carpool',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Icon(Icons.add),
      elevation: 4,
    ).animate()
        .fadeIn(duration: 600.ms, delay: 1200.ms)
        .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0));
  }
}