import 'package:bu_buddy/features/car/screens/home/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';

class CarHomeScreen extends StatelessWidget {
  const CarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance; // Get the controller instance

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Disable default back button
        title: Text(
          'Carpool Home',
          style: TextStyle(
            fontSize: TSizes.fontSizeLg,
            fontWeight: FontWeight.bold,
            color: TColors.white,
          ),
        ),
        backgroundColor: TColors.primary,  // Using primary color from TColors
        elevation: 5,  // Light shadow effect for the AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),  // Consistent padding around the content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section - Greeting User with a Clean, Centered Layout
              Padding(
                padding: EdgeInsets.symmetric(vertical: TSizes.md),
                child: Center(
                  child: Obx(() {
                    // Display the user's name dynamically from Firebase
                    return controller.profileLoading.value
                        ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 200,
                        height: 30,
                        color: Colors.white,
                      ),
                    )
                        : FadeTransition(
                      opacity: AlwaysStoppedAnimation(1.0), // Smooth fade-in
                      child: Text(
                        'Good Morning, ${controller.user.value.firstName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: TSizes.fontSizeLg,
                          fontWeight: FontWeight.bold,
                          color: TColors.textPrimary,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Subheading for clarity and focus
              Padding(
                padding: EdgeInsets.symmetric(vertical: TSizes.sm),
                child: Center(
                  child: Text(
                    'Ready to find your next carpool?',
                    style: TextStyle(
                      fontSize: TSizes.fontSizeMd,
                      color: TColors.textSecondary,
                    ),
                  ),
                ),
              ),

              // Car Image with proper styling
              ClipRRect(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0), // Fade in effect for image
                    child: controller.profileLoading.value
                        ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.white,
                      ),
                    )
                        : Image.asset(
                      'assets/images/selection_menu/car_pool.jpg',  // Replace with actual image path
                      height: 200,  // Image height adjusted for a better fit
                      width: double.infinity,  // Ensures the image spans the entire width
                      fit: BoxFit.cover,  // Maintains the aspect ratio while covering the space
                    ),
                  ),
                ),
              ),

              SizedBox(height: TSizes.spaceBtwSections),  // Add space between sections

              // Call to Action - Buttons (Example)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
                child: controller.profileLoading.value
                    ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    color: Colors.white,
                  ),
                )
                    : Buttons(),  // Assuming Buttons widget is added here
              ),
            ],
          ),
        ),
      ),
    );
  }
}
