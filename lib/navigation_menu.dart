import 'package:bu_buddy/features/car/screens/available_rides/available_rides.dart';
import 'package:bu_buddy/features/car/screens/my_trips/my_trips.dart';
import 'package:bu_buddy/features/personalization/screens/notifications/notifications.dart';
import 'package:bu_buddy/features/personalization/screens/profile/profile.dart';
import 'package:bu_buddy/features/personalization/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bu_buddy/utils/constants/colors.dart';
import 'package:bu_buddy/utils/helpers/helper_functions.dart';

import 'features/car/screens/home/home.dart';

// Root navigation menu with bottom navigation
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize NavigationController using Get.put() to make sure it's available
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(() {
        return NavigationBar(
          height: 70,  // Height of the bottom navigation bar
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode ? TColors.black : Colors.white,
          indicatorColor: darkMode
              ? TColors.white.withOpacity(0.1)
              : TColors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Iconsax.home, size: 30),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.car, size: 30),
              label: 'Trips',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.notification, size: 30),
              label: 'Notifications',
            ),
            NavigationDestination(
              icon: Icon(Iconsax.user, size: 30),
              label: 'Profile',
            ),
          ],
        );
      }),
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;  // To keep track of the selected tab index

  // List of screens to be displayed based on the selected tab
  final screens = [
    CarHomeScreen(),  // First screen: CarHomeScreen for "Home"
    TripsScreen(),
    NotificationsScreen(),
    SettingsScreen(),
  ];
}
