import 'package:bu_buddy/features/authentication/screens/signup/widgets/terms_and_conditions_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../verify_email.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({
    super.key,

  });



  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(

                  expands: false,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),
                    labelText: TTexts.firstName,
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  expands: false,
                  decoration: InputDecoration(
                    labelText: TTexts.lastName,
                    labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          // Username
          /// Username
          TextFormField(
            expands: false,
            decoration: InputDecoration(
              labelText: TTexts.username,
              labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),

              prefixIcon: const Icon(Iconsax.user_edit),
            ), // TextFormField
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          /// Email
          TextFormField(
            decoration: InputDecoration(
              labelText: TTexts.email,
              labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),
              prefixIcon: const Icon(Iconsax.direct),
            ), // TextFormField
          ),
          SizedBox(height: TSizes.spaceBtwInputFields),

          /// Phone Number
          TextFormField(
            decoration: InputDecoration(
              labelText: TTexts.phonoNo,
              labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),

              prefixIcon: const Icon(Iconsax.call),
            ), // TextFormField
          ),
          SizedBox(height: TSizes.spaceBtwInputFields),

          /// Password
          TextFormField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: TTexts.password,
              labelStyle: TextStyle(color: dark ? TColors.white : TColors.black),

              prefixIcon: const Icon(Iconsax.password_check),
              suffixIcon: const Icon(Iconsax.eye_slash),
            ), // InputDecoration
          ), // TextFormField
          SizedBox(height: TSizes.spaceBtwSections),

          /// Terms & Conditions Checkbox
          TTermsAndConditionCheckbox(),

          //   Sign Up Button
          SizedBox(height: TSizes.spaceBtwSections),

          /// Sign Up Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.to(()=>VerifyEmailScreen() );
              },
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],

      ),
    );
  }
}

