import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class CategoryOption extends StatelessWidget {
  final String title;
  final String imagePath;
  // final String route;

  const CategoryOption({
    Key? key,
    required this.title,
    required this.imagePath,
    // required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => Get.toNamed(route),  // Navigate to the specified route
      child: Card(
        margin: EdgeInsets.symmetric(vertical: TSizes.sm, horizontal: TSizes.md),
        elevation: TSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Column(
          children: [
            // Image Box with BoxFit to ensure proper fitting
            Container(
              height: 130, // Use TSizes for consistent size
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(TSizes.cardRadiusMd)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,  // Ensures the image covers the space
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(TSizes.sm),
              child: Text(
                title,
                style: TextStyle(fontSize: TSizes.fontSizeMd, fontWeight: FontWeight.w600, color: TColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
