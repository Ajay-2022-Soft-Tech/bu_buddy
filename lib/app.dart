import 'package:bu_buddy/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:bu_buddy/features/car/screens/home/find_a_ride.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'features/authentication/screens/onboarding/onboarding.dart';
import 'features/car/screens/home/home.dart';
import 'features/authentication/screens/login/login.dart';
import 'features/authentication/screens/signup/signup.dart';
import 'package:bu_buddy/utils/theme/theme.dart';

import 'features/car/screens/publish_ride/publish_ride.dart';
import 'navigation_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize any services like Firebase, SharedPreferences, etc.

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,  // Light Theme
      darkTheme: TAppTheme.darkTheme,  // Dark Theme
      initialRoute: '/',
      // home: OnBoardingScreen(),
      getPages: [
        GetPage(name: '/', page: () => NavigationMenu()),  // Root navigation menu
        // GetPage(name: '/car_home_screen', page: () => CarHomeScreen()),  // Onboarding screen
        GetPage(name: '/login', page: () => LoginScreen()),  // Login screen
        GetPage(name: '/signup', page: () => SignUpScreen()),  // Signup screen
        GetPage(name: '/forgot_password', page: () => ForgetPassword()),  // Forgot password screen

        // Carpool Screens
        GetPage(name: '/find_ride', page: () => FindARideScreen()),  // Car Home screen
        // GetPage(name: '/laundry', page: () => CarHomeScreen()),  // Find a ride screen
        // GetPage(name: '/dietplan', page: () => CarHomeScreen()),  // Find a ride screen
        // GetPage(name: '/publish_ride', page: () => PublishRideScreen()),  // Publish a ride screen
        // GetPage(name: '/my_trips', page: () => MyTripsScreen()),  // My trips screen
        // GetPage(name: '/ride_details', page: () => RideDetailsScreen()),  // Ride details screen
        // GetPage(name: '/carpool_dashboard', page: () => CarpoolDashboardScreen()),  // Carpool dashboard (optional)
        //
        // // Profile & Settings Screens
        // GetPage(name: '/profile', page: () => ProfileScreen()),  // Profile screen
        // GetPage(name: '/settings', page: () => SettingsScreen()),  // Settings screen
        //
        // // Other screens
        // GetPage(name: '/notifications', page: () => NotificationsScreen()),  // Notifications screen
        // GetPage(name: '/help', page: () => HelpScreen()),  // Help & support screen
        // GetPage(name: '/terms_conditions', page: () => TermsConditionsScreen()),  // Terms and conditions screen
        // GetPage(name: '/privacy_policy', page: () => PrivacyPolicyScreen()),  // Privacy policy screen
      ],
    );
  }
}
