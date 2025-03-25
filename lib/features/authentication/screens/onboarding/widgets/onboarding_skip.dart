import 'package:flutter/material.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: TDeviceUtils.getAppBarHeight(),
      right: TSizes.defaultSpace,
      child: TextButton(
        onPressed: OnBoardingController.instance.skipPage,
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFF4b68ff).withOpacity(0.1), // Light background color
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          "Skip",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
