import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingNextButton extends StatelessWidget {
  const OnBoardingNextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    final dark = THelperFunctions.isDarkMode(context);

    return Positioned(
        right: TSizes.defaultSpace,
        bottom: TDeviceUtils.getBottomNavigationBarHeight(),
        child: ElevatedButton(
            onPressed: OnBoardingController.instance.nextPage,
            style: ElevatedButton.styleFrom(shape: CircleBorder(),backgroundColor: dark ? TColors.primary :TColors.dark) ,
            child: const Icon(Icons.arrow_forward_ios,color: Colors.white,)));
  }
}