

import 'package:bu_buddy/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';

class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headings
            Text(
              TTexts.forgetPasswordTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              TTexts.forgetPasswordSubTitle,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: TSizes.spaceBtwSections * 2),

            // Text field
            TextFormField(
              decoration: const InputDecoration(labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct_right)),
            ),
            SizedBox(height: TSizes.spaceBtwSections),

            // Submit Button
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: ()=> Get.off(()=> const ResetPassword()), child:  Text(TTexts.submit)))
          ],
        ),
      ),
    );
  }
}
