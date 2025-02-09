import 'package:bu_buddy/features/car/screens/category_selection/widgets/category_option.dart';
import 'package:bu_buddy/features/car/screens/home/home.dart';
import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'package:get/get.dart';  // Import GetX for navigation

class CategorySelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("BU Buddy"),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 4,
        toolbarHeight: TSizes.appBarHeight,
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // App Logo (if needed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: Image.asset(
                  'assets/images/selection_menu/car_pool.jpg',
                  height: TSizes.imageThumbSize,
                ),
              ),
            ),
            // Category Heading
            Center(
              child: Text(
                "Select Your Category",
                style: TextStyle(
                  fontSize: TSizes.fontSizeLg,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: TSizes.spaceBtwSections),

            // Category Options
            Expanded(
              child: ListView(
                children: [
                  TextButton(

                    onPressed: () { Get.to(CarHomeScreen()); },
                    child: CategoryOption(
                      title: 'Carpool',
                      imagePath: 'assets/images/selection_menu/car_pool.jpg',
                      // route: '/car_home_screen', // Passing the route for Carpool
                    ),
                  ),
                  TextButton(
                    onPressed: () { Get.to(CarHomeScreen()); },

                    child: CategoryOption(
                      title: 'Laundry',
                      imagePath: 'assets/images/selection_menu/laundry_image.jpg',
                      // route: '/laundry', // Passing the route for Laundry
                    ),
                  ),
                  TextButton(
                    onPressed: () { Get.to(CarHomeScreen()); },

                    child: CategoryOption(
                      title: 'Diet Plan',
                      imagePath: 'assets/images/selection_menu/diet_plan_image.jpg',
                      // route: '/dietplan', // Passing the route for Diet Plan
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
