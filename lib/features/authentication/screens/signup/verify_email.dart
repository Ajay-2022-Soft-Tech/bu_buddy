import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../common/widgets/success_screen/success_screen.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../login/login.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            icon: const Icon(CupertinoIcons.clear),
          )
        ],
      ),
      body: SingleChildScrollView(
        // Padding to Give Default Equal Space on all sides in all screens.
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
              children: [
          // Image
          Image(
          image: const AssetImage(TImages.delivered_EmoilIllustration),
          width: THelperFunctions.screenWidth() * 0.6,
        ),
        SizedBox(height: TSizes.spaceBtwSections),
        // Title & Subtitle
        Text(
          TTexts.confirmEmail,
          style: Theme
              .of(context)
              .textTheme
              .headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: TSizes.spaceBtwItems),
        Text('support@codingwitht.com', style: Theme
            .of(context)
            .textTheme
            .labelLarge, textAlign: TextAlign.center),
        SizedBox(height: TSizes.spaceBtwItems),
        Text(TTexts.confirmEmailSubTitle, style: Theme
            .of(context)
            .textTheme
            .labelMedium, textAlign: TextAlign.center),
        SizedBox(height: TSizes.spaceBtwSections),

        /// Buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
              onPressed:
                  () =>
                  Get.offAll(() =>
                  SuccessScreen(image: TImages.staticSuccessIllustration,
                      title: TTexts.yourAccountCreatedTitle,
                      subTitle: TTexts.yourAccountCreatedSubTitle,
                      onPressed: ()=> Get.to (()=> const LoginScreen())))
          ,
          child: const Text(TTexts.tContinue),
        ),
      ),
      SizedBox(height: TSizes.spaceBtwItems),
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () {

          },
          child: const Text(TTexts.resendEmail),
        ),
      ),

      ],
    ),)
    ,
    )
    ,
    );
  }
}
