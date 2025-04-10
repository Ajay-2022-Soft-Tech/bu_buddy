import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class CarpoolHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CarpoolHomeAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: _buildTitle(size),
      actions: [
        _buildNotificationButton(),
      ],
    );
  }

  Widget _buildTitle(Size size) {
    return Container(
      width: size.width * 0.58,
      height: 52,
      decoration: BoxDecoration(
        // Dynamic gradient background for better visual appeal
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TColors.primary.withOpacity(0.8),
            TColors.primary.withOpacity(0.5),
            TColors.primary.withOpacity(0.65),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          // Inner glow effect
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated car icon with glow effect
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            // Text with shadow for better readability
            Text(
              'Carpool Home',
              style: TextStyle(
                fontSize: TSizes.fontSizeLg,
                fontWeight: FontWeight.bold,
                color: TColors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: -0.2, end: 0, curve: Curves.easeOutQuint);
  }

  Widget _buildNotificationButton() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.transparent,
          ],
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: IconButton(
        icon: Stack(
          children: [
            const Icon(
              Icons.notifications_rounded,
              color: TColors.white,
              size: 26,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  // Add glow effect to notification indicator
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          // Notification functionality
        },
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 400.ms)
        .moveX(begin: 20, end: 0, curve: Curves.easeOutQuint)
    // Add subtle pulse animation to notification icon
        .then()
        .custom(
      duration: 1500.ms,
      builder: (context, value, child) => Transform.scale(
        scale: 1.0 + 0.05 * sin(value * 2 * 3.14159),
        child: child,
      ),
    );
  }
}