import 'dart:ui';
import 'package:bu_buddy/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:bu_buddy/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  bool _isImageExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Listen to scroll for showing/hiding floating button
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      } else if (_scrollController.offset <= 100 && _showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleImageExpansion() {
    setState(() => _isImageExpanded = !_isImageExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Iconsax.arrow_up_3),
        ),
      ),
      appBar: TAppBar(
        title: Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        showBackArrow: true,
      ),
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                isDark ? 'assets/images/pattern_dark.png' : 'assets/images/pattern_light.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),

          // Blurred app bar background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + kToolbarHeight,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: Column(
                        children: [
                          // Profile Picture Section with animations
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                // Animated profile picture
                                Hero(
                                  tag: 'profile_image',
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeOutBack,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: GestureDetector(
                                          onTap: _toggleImageExpansion,
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: _isImageExpanded ? 150 : 100,
                                            height: _isImageExpanded ? 150 : 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Theme.of(context).primaryColor,
                                                width: 3,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                            child: ClipOval(
                                              child: Image.asset(
                                                TImages.user,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Animated change profile picture button
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  builder: (context, value, child) {
                                    return Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 20 * (1 - value)),
                                        child: TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Iconsax.camera),
                                          label: const Text("Change Profile Picture"),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Theme.of(context).primaryColor,
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: TSizes.spaceBtwItems / 2),

                          // Animated divider
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Container(
                                width: MediaQuery.of(context).size.width * value,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Theme.of(context).dividerColor,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: TSizes.spaceBtwItems),

                          // Profile Information Section Header
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(-0.2, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                              ),
                            ),
                            child: FadeTransition(
                              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                                CurvedAnimation(
                                  parent: _animationController,
                                  curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: TSectionHeading(
                                  title: 'Profile Information',
                                  showActionButton: false,
                                ),
                              ),
                            ),
                          ),

                          // Staggered Menu Items
                          ..._buildStaggeredMenuItems(controller),

                          const SizedBox(height: TSizes.spaceBtwItems),

                          // Animated divider
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Container(
                                width: MediaQuery.of(context).size.width * value,
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Theme.of(context).dividerColor,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: TSizes.spaceBtwItems * 2),

                          // Delete Account Button with animation
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Center(
                                  child: TextButton.icon(
                                    onPressed: () => _showDeleteAccountDialog(context, controller),
                                    icon: const Icon(Iconsax.trash, color: Colors.red),
                                    label: const Text(
                                      'Close Account',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create staggered menu items
  List<Widget> _buildStaggeredMenuItems(UserController controller) {
    final menuItems = [
      {
        'title': 'Name',
        'value': controller.user.value.fullName,
        'icon': Iconsax.arrow_right_34,
        'onPressed': () => Get.to(() => const ChangeName(), transition: Transition.cupertino),
      },
      {
        'title': 'User ID',
        'value': controller.user.value.id,
        'icon': Iconsax.copy,
        'onPressed': () {},
      },
      {
        'title': 'E-mail',
        'value': controller.user.value.email,
        'icon': Iconsax.arrow_right_34,
        'onPressed': () {},
      },
      {
        'title': 'Phone Number',
        'value': controller.user.value.phoneNumber,
        'icon': Iconsax.arrow_right_34,
        'onPressed': () {},
      },
      {
        'title': 'Gender',
        'value': 'Male',
        'icon': Iconsax.arrow_right_34,
        'onPressed': () {},
      },
      {
        'title': 'Date of Birth',
        'value': '10 Oct, 2000',
        'icon': Iconsax.arrow_right_34,
        'onPressed': () {},
      },
    ];

    return List.generate(
      menuItems.length,
          (index) {
        final menuItem = menuItems[index];

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                0.4 + (index * 0.1),
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.4 + (index * 0.1),
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: TProfileMenu(
              title: menuItem['title'] as String,
              value: menuItem['value'] as String,
              icon: menuItem['icon'] as IconData,
              onPressed: menuItem['onPressed'] as VoidCallback,
            ),
          ),
        );
      },
    );
  }

  // Dialog for delete account confirmation
  void _showDeleteAccountDialog(BuildContext context, UserController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Delete Account",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  ),
                  const SizedBox(width: 10),
                  const Text("Delete Account"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/delete_account.json',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.deleteAccountWarningPopup();
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
