

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../controllers/forget_password/forget_password_controller.dart';
import '../login/login.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [IconButton(onPressed: () => Get.back(), icon: const Icon(CupertinoIcons.clear))],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Image
              Image(image: const AssetImage(TImages.delivered_EmoilIllustration), width: THelperFunctions.screenWidth() * 0.6),
              SizedBox(height: TSizes.spaceBtwSections),

              // Title & Subtitle
              Text(
                email,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.changeYourPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.offAll(() => const LoginScreen()),
                  child: const Text(TTexts.done),
                ),
              ), // SizedBox

              const SizedBox(height: TSizes.spaceBtwItems),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => ForgetPasswordController.instance.resendPasswordResetEmail(email), // Passing email here
                  child: const Text(TTexts.resendEmail),
                ),
              ), // SizedBox

            ],
          ),
        ),
      ),
    );
  }
}
