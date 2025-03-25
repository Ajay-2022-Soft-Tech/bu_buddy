import 'package:bu_buddy/features/authentication/screens/signup/widgets/terms_and_conditions_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/signup/signup_controller.dart';
import '../verify_email.dart';

class TSignupForm extends StatelessWidget {
  const TSignupForm({
    super.key,

  });



  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());

    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                   controller: controller.firstName,
                  validator: (value) => TValidator.validateEmptyText('First name', value),
                  expands: false,
                  decoration: InputDecoration(
                    labelText: TTexts.firstName,
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(

                  validator: (value) => TValidator.validateEmptyText('Last name', value),
                  controller: controller.lastName,
                  expands: false,
                  decoration: InputDecoration(
                    labelText: TTexts.lastName,
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
            validator: (value) => TValidator.validateEmptyText('Username', value),
            controller: controller.username,
            expands: false,
            decoration: InputDecoration(
              labelText: TTexts.username,

              prefixIcon: const Icon(Iconsax.user_edit),
            ), // TextFormField
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),

          /// Email
          TextFormField(
            validator: (value) => TValidator.validateEmail(value),
            controller: controller.email,
            decoration: InputDecoration(
              labelText: TTexts.email,
              prefixIcon: const Icon(Iconsax.direct),
            ), // TextFormField
          ),
          SizedBox(height: TSizes.spaceBtwInputFields),

          /// Phone Number
          TextFormField(
            validator: (value) => TValidator.validatePhoneNumber(value),
            controller: controller.phoneNumber,
            decoration: InputDecoration(
              labelText: TTexts.phonoNo,

              prefixIcon: const Icon(Iconsax.call),
            ), // TextFormField
          ),
          SizedBox(height: TSizes.spaceBtwInputFields),

          /// Password
          Obx(() => TextFormField(
              validator: (value) => TValidator.validatePassword(value),
              controller: controller.password,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: TTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                    onPressed: ()=> controller.hidePassword.value = !controller.hidePassword.value,
                    icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                ),
              ), // InputDecoration
            ),
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
              controller.signup();  // ✅ Correct
              },
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],

      ),
    );
  }
}

