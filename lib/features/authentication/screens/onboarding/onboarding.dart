import 'package:bu_buddy/features/authentication/screens/onboarding/widgets/onboarding_navigation.dart';
import 'package:bu_buddy/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:bu_buddy/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:bu_buddy/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/texts.dart';
import '../../controllers/onboarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        //   Horizontal Scrollable Pages
        children: [
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,

            children: const [
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle2,
                subTitle: TTexts.onBoardingSubTitle2,
              ),
              OnBoardingPage(
                image: TImages.onBoardingImage3,
                title: TTexts.onBoardingTitle3,
                subTitle: TTexts.onBoardingSubTitle3,
              ),
            ],
          ),

          //   Skip Button
          const OnBoardingSkip(),

          //   dot Navigation SmoothPageIndicator

          const OnBoardingDotNavigation(),

        //   Circular Button
          OnBoardingNextButton()
        ],

      ),
    );
  }
}





