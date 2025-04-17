import 'package:bu_buddy/features/car/screens/available_rides/available_rides.dart';
import 'package:bu_buddy/features/car/screens/home/find_a_ride.dart';
import 'package:bu_buddy/features/car/screens/my_trips/my_trips.dart';
import 'package:bu_buddy/features/car/screens/publish_ride/publish_ride.dart';
import 'package:bu_buddy/features/personalization/screens/chat_bot/chat_bot.dart';
import 'package:bu_buddy/features/personalization/screens/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bu_buddy/utils/constants/colors.dart';
import 'package:bu_buddy/utils/helpers/helper_functions.dart';

import 'features/car/screens/home/home.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _navBarAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _navBarSlideAnimation;

  // For water ripple effect on FAB tap
  final List<Ripple> _ripples = [];

  @override
  void initState() {
    super.initState();

    // Setup FAB animation
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Setup navbar animation
    _navBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _navBarSlideAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _navBarAnimationController,
        curve: Curves.easeOutQuint,
      ),
    );

    // Start animations
    _fabAnimationController.forward();
    _navBarAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _navBarAnimationController.dispose();
    super.dispose();
  }

  void _addRipple() {
    setState(() {
      _ripples.add(Ripple(
        key: UniqueKey(),
        onComplete: _removeRipple,
      ));
    });
  }

  void _removeRipple(Key key) {
    setState(() {
      _ripples.removeWhere((element) => element.key == key);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);

    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: darkMode ? TColors.darkerGrey : Colors.white,
      systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBody: true,
      floatingActionButton: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effects
          ..._ripples,

          // Main FAB with scale animation
          ScaleTransition(
            scale: _fabScaleAnimation,
            child: GestureDetector(
              onTap: () {
                // Add ripple effect
                _addRipple();

                // Show ride options
                Future.delayed(const Duration(milliseconds: 200), () {
                  _showRideOptionsSheet(context, darkMode);
                });
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.primary,
                      darkMode ? Colors.blueAccent : TColors.primary.withBlue(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.add,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBuilder(
        animation: _navBarAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 70 * _navBarSlideAnimation.value),
            child: child,
          );
        },
        child: Obx(() {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: darkMode
                    ? [
                  TColors.darkerGrey.withOpacity(0.9),
                  TColors.darkerGrey,
                ]
                    : [
                  Colors.white.withOpacity(0.9),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: BottomAppBar(
                height: 75,
                padding: EdgeInsets.zero,
                notchMargin: 10,
                elevation: 0,
                color: Colors.transparent,
                shape: const CircularNotchedRectangle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Iconsax.home, Iconsax.home, 'Home', controller, darkMode),
                    _buildNavItem(1, Iconsax.car, Iconsax.car, 'Trips', controller, darkMode),
                    const SizedBox(width: 60), // Space for FAB
                    _buildNavItem(2, Iconsax.chart_3, Iconsax.chart_3, 'Bot', controller, darkMode),
                    _buildNavItem(3, Iconsax.user, Iconsax.user, 'Profile', controller, darkMode),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      body: Stack(
        children: [
          // Main screen content
          Obx(() {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(controller.selectedIndex.value),
                child: controller.screens[controller.selectedIndex.value],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index,
      IconData filledIcon,
      IconData outlineIcon,
      String label,
      NavigationController controller,
      bool darkMode
      ) {
    final isSelected = controller.selectedIndex.value == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.selectedIndex.value = index;
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (darkMode
                      ? TColors.primary.withOpacity(0.2)
                      : TColors.primary.withOpacity(0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isSelected ? filledIcon : outlineIcon,
                    key: ValueKey<bool>(isSelected),
                    size: 26,
                    color: isSelected
                        ? TColors.primary
                        : darkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? TColors.primary
                      : darkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
                child: Text(label),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isSelected ? 20 : 0,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: TColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRideOptionsSheet(BuildContext context, bool darkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: darkMode
                  ? [
                TColors.darkerGrey.withOpacity(0.95),
                TColors.darkerGrey,
              ]
                  : [
                Colors.white.withOpacity(0.95),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 5,
                width: 60,
                decoration: BoxDecoration(
                  color: darkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // Title with gradient
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TColors.primary.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.car5,
                      color: TColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'New Ride',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkMode ? Colors.white : TColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Main options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSuperOptionButton(
                      icon: Iconsax.car,
                      label: 'Find a Ride',
                      description: 'Browse available rides',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => FindARideScreen());
                      },
                      darkMode: darkMode,
                    ),
                    const SizedBox(width: 16),
                    _buildSuperOptionButton(
                      icon: Iconsax.driver,
                      label: 'Offer a Ride',
                      description: 'Share your journey',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => PublishRideScreen());
                      },
                      darkMode: darkMode,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Additional options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSecondaryOptionButton(
                      icon: Iconsax.calendar,
                      label: 'Schedule',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to schedule screen
                      },
                      darkMode: darkMode,
                    ),
                    _buildSecondaryOptionButton(
                      icon: Iconsax.medal_star,
                      label: 'Premium',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to premium rides
                      },
                      darkMode: darkMode,
                    ),
                    _buildSecondaryOptionButton(
                      icon: Iconsax.message_favorite,
                      label: 'Favorites',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to favorite rides
                      },
                      darkMode: darkMode,
                    ),
                    _buildSecondaryOptionButton(
                      icon: Iconsax.location,
                      label: 'Near me',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to nearby rides
                      },
                      darkMode: darkMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuperOptionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
    required bool darkMode,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(darkMode ? 0.2 : 0.1),
                color.withOpacity(darkMode ? 0.08 : 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(darkMode ? 0.4 : 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: darkMode ? Colors.white : TColors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: darkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool darkMode,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(darkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(darkMode ? 0.4 : 0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: darkMode ? Colors.grey.shade300 : TColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Ripple Animation for FAB
class Ripple extends StatefulWidget {
  final Function(Key) onComplete;

  const Ripple({required Key key, required this.onComplete}) : super(key: key);

  @override
  State<Ripple> createState() => _RippleState();
}

class _RippleState extends State<Ripple> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete(widget.key!);
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 64 + (100 * _animation.value),
          height: 64 + (100 * _animation.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: TColors.primary.withOpacity(0.4 * (1 - _animation.value)),
          ),
        );
      },
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;  // To keep track of the selected tab index

  // List of screens to be displayed based on the selected tab
  final screens = [
    CarHomeScreen(),
    MyTripsScreen(),
    ChatbotScreen(),
    ProfileScreen(), // Changed from SettingsScreen to ProfileScreen for better UX
  ];
}