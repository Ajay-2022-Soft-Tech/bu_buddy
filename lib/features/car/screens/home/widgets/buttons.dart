import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Find a ride button
          ElevatedButton(
            onPressed: () {
              // Navigate to Find a ride screen
              // Get.toNamed('/find_ride');  // Navigate to the "Find a ride" screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary, // Button color from TColors
              padding: EdgeInsets.symmetric(vertical: TSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.buttonRadius),
              ),
            ),
            child: Text(
              TTexts.findRide,  // Dynamic text from TTexts
              style: TextStyle(fontSize: TSizes.fontSizeMd),
            ),
          ),
          SizedBox(height: 16), // Adjusted spacing between buttons

          // Publish a ride button
          ElevatedButton(
            onPressed: () {
              // Navigate to Publish a ride screen
              // Get.toNamed('/publish_ride');  // Navigate to the "Publish a ride" screen
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: TColors.primary,
              backgroundColor: Colors.white,  // Button background color
              padding: EdgeInsets.symmetric(vertical: TSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.buttonRadius),
                side: BorderSide(color: TColors.primary),
              ),
            ),
            child: Text(
              TTexts.publishRide,  // Dynamic text from TTexts
              style: TextStyle(fontSize: TSizes.fontSizeMd),
            ),
          ),
        ],
      ),
    );
  }
}
