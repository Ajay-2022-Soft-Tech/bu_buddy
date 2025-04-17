import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_tile/settings_menu_tile.dart';
import '../../../../common/widgets/list_tile/user_profile.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/login/login_controller.dart';
import '../../../authentication/screens/login/login.dart';
import '../address/address.dart';
import '../profile/profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  // Switch states
  bool _geoLocationEnabled = true;
  bool _safeModeEnabled = false;
  bool _hdImageEnabled = true;

  // Animation states
  bool _showHeaderDetails = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Show header details after a short delay for sequential animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showHeaderDetails = true);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _slideController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Background pattern for depth
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    isDark ? 'assets/images/pattern_dark.png' : 'assets/images/pattern_light.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),

              // Main content with animations
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Animated Header
                  SliverToBoxAdapter(
                    child: _buildAnimatedHeader(context),
                  ),

                  // Settings content with staggered animations
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
                            CurvedAnimation(
                              parent: _slideController,
                              curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Account Settings Section
                              _buildSettingsSection(
                                title: 'Account Settings',
                                icon: Iconsax.user,
                                children: [
                                  _buildAnimatedSettingsTile(
                                    index: 0,
                                    icon: Iconsax.safe_home,
                                    title: 'My Addresses',
                                    subtitle: 'Set shopping delivery address',
                                    onTap: () => Get.to(() => const UserAddressScreen(), transition: Transition.rightToLeft),
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 1,
                                    icon: Iconsax.car,
                                    title: 'My Rides',
                                    subtitle: 'In-progress and Completed Orders',
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 2,
                                    icon: Iconsax.coin,
                                    title: 'Account Coins',
                                    subtitle: 'Withdraw balance to Ride More',
                                    isSpecial: true,
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 3,
                                    icon: Iconsax.discount_shape,
                                    title: 'My Coupons',
                                    subtitle: 'List of all the discounted coupons',
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 4,
                                    icon: Iconsax.notification,
                                    title: 'Notifications',
                                    subtitle: 'Set any kind of notification message',
                                    showBadge: true,
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 5,
                                    icon: Iconsax.security_card,
                                    title: 'Account Privacy',
                                    subtitle: 'Manage data usage and connected accounts',
                                  ),
                                ],
                              ),

                              // App Settings Section
                              _buildSettingsSection(
                                title: 'App Settings',
                                icon: Iconsax.setting_2,
                                startIndex: 6,
                                children: [
                                  _buildAnimatedSettingsTile(
                                    index: 6,
                                    icon: Iconsax.location,
                                    title: 'Geolocation',
                                    subtitle: 'Set recommendation based on location',
                                    trailing: _buildAnimatedSwitch(
                                      value: _geoLocationEnabled,
                                      onChanged: (value) => setState(() => _geoLocationEnabled = value),
                                    ),
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 7,
                                    icon: Iconsax.security_user,
                                    title: 'Safe Mode',
                                    subtitle: 'Search result is safe for all ages',
                                    trailing: _buildAnimatedSwitch(
                                      value: _safeModeEnabled,
                                      onChanged: (value) => setState(() => _safeModeEnabled = value),
                                    ),
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 8,
                                    icon: Iconsax.image,
                                    title: 'HD Image Quality',
                                    subtitle: 'Set image quality to be seen',
                                    trailing: _buildAnimatedSwitch(
                                      value: _hdImageEnabled,
                                      onChanged: (value) => setState(() => _hdImageEnabled = value),
                                    ),
                                  ),
                                  _buildAnimatedSettingsTile(
                                    index: 9,
                                    icon: Iconsax.document_upload,
                                    title: 'Load Data',
                                    subtitle: 'Upload Data to your Cloud Firebase',
                                  ),
                                ],
                              ),

                              // Logout Button with animation
                              _buildAnimatedLogoutButton(context, controller),

                              const SizedBox(height: TSizes.spaceBtwSections * 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnimatedHeader(BuildContext context) {
    return TPrimaryHeaderContainer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeOut,
        child: Column(
          key: ValueKey<bool>(_showHeaderDetails),
          children: [
            // Animated AppBar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: TAppBar(
                      title: Text(
                        'Account',
                        style: Theme.of(context).textTheme.headlineMedium!.apply(
                          color: TColors.white,
                          fontWeightDelta: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            // User Profile Tile with slide-in animation
            if (_showHeaderDetails)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(MediaQuery.of(context).size.width * (1 - value), 0),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'user_profile_card',
                          child: TUserProfileTile(
                            onPressed: () => Get.to(
                                  () => const ProfileScreen(),
                              transition: Transition.rightToLeft,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

            if (_showHeaderDetails)
              const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    int startIndex = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TSizes.spaceBtwSections),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated section header
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(-20 * (1 - value), 0),
                child: Opacity(
                  opacity: value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Animated divider
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Container(
                margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
                width: MediaQuery.of(context).size.width * 0.7 * value,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            },
          ),

          // List of settings items
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnimatedSettingsTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isSpecial = false,
    bool showBadge = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: isSpecial
                  ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.purple.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              )
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: isSpecial
                      ? ImageFilter.blur(sigmaX: 5, sigmaY: 5)
                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Stack(
                    children: [
                      TSettingsMenuTile(
                        icon: icon,
                        title: title,
                        subTitle: subtitle,
                        trailing: trailing,
                        onTap: onTap,
                      ),

                      // Notification badge if enabled
                      if (showBadge)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 0.8 + (_pulseController.value * 0.2),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.5),
                                        blurRadius: 4 + (_pulseController.value * 4),
                                        spreadRadius: _pulseController.value * 2,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
            activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogoutButton(BuildContext context, LoginController controller) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Padding(
            padding: const EdgeInsets.only(top: TSizes.spaceBtwSections),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade300,
                      Colors.red.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => _showLogoutConfirmation(context, controller),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.logout,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Logout',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, LoginController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Logout",
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
                    child: const Icon(Iconsax.logout, color: Colors.red),
                  ),
                  const SizedBox(width: 16),
                  const Text("Logout"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/animations/logout.json',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Are you sure you want to logout? You'll need to login again to access your account.",
                    textAlign: TextAlign.center,
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
                    // Close the dialog
                    Navigator.of(context).pop();

                    // Show logout animation
                    _showLogoutAnimation(context, controller);
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutAnimation(BuildContext context, LoginController controller) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Logging Out",
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Lottie.asset(
                      'assets/animations/loading.json',
                      width: 100,
                      height: 100,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Logging Out...",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Simulate logout process and navigate
    Future.delayed(const Duration(seconds: 2), () {
      // Clear user session
      controller.userController.onClose();

      // Navigate to the login screen
      Get.offAll(
            () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 800),
      );
    });
  }
}
