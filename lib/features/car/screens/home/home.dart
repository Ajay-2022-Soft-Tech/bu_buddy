import 'package:bu_buddy/features/car/screens/category_selection/category_selection_screen.dart';
import 'package:bu_buddy/features/car/screens/home/widgets/buttons.dart';
import 'package:bu_buddy/features/car/screens/home/widgets/home_appbar.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import 'package:get/get.dart';  // For GetX navigation
class CarHomeScreen extends StatelessWidget {
  final String userName = 'Siffat';  // Can be dynamic if needed

  const CarHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Disable default back button
        title: Text('Carpool Home'),
        backgroundColor: TColors.primary,  // Using the primary color from TColors
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),  // Back arrow icon
        //   onPressed: () {
        //     // Get.to(CategorySelectionScreen());  // Navigate back to the previous screen
        //   },
        // ),
      ),
      body: Column(
        children: [
          // Wrap the header section with TPrimaryHeaderContainer

          Center(
            child: Text(
              'Good Morning  $userName',
              style: Theme.of(context).textTheme.headlineSmall!.apply(
                color: THelperFunctions.isDarkMode(context)
                    ? TColors.white
                    : TColors.black,
              ),
            ),
          ),
          SizedBox(height: 50),


          // Car Image
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Image.asset(
                'assets/images/selection_menu/car_pool.jpg', // Replace with the actual image path
                height: 180, // Adjust image height to match the design
                width: double.infinity, // Full width to match the car design
                fit: BoxFit.fitWidth,  // Ensures the image stretches but maintains aspect ratio
              ),
            ),
          ),
          Buttons(),  // Assuming Buttons widget is added here

        ],
      ),
    );
  }
}