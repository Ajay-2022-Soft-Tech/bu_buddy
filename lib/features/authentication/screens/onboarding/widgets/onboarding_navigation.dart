import 'package:flutter/cupertino.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/onboarding/onboarding_controller.dart';

class OnBoardingDotNavigation extends StatelessWidget {
  const OnBoardingDotNavigation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = THelperFunctions.isDarkMode(context);

    return Positioned(
        bottom: TDeviceUtils.getBottomNavigationBarHeight() + 25,
        left: TSizes.defaultSpace,
        child: SmoothPageIndicator(
          effect: ExpandingDotsEffect(
              activeDotColor: dark ? TColors.light : TColors.dark,
              dotHeight: 6),
          controller: controller.pageController,
          onDotClicked: controller.dotNavigationClick,
          count: 3,
        ));
  }
}
