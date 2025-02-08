
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../navigation_menu.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../password_configuration/forget_password.dart';
import '../../signup/signup.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.direct_right),
                labelText: TTexts.email,
              ),
            ), // TextFormField
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            TextFormField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: TTexts.password,
                suffixIcon: const Icon(Iconsax.eye_slash),
              ),
            ), // InputDecoration
            // TextFormField
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// Remember Me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(TTexts.rememberMe),
                  ],
                ), // Row

                /// Forget Password
                GestureDetector(
                  onTap: () {
                    // TODO: Implement navigation to Forgot Password screen
                    Get.to(()=> const ForgetPassword());
                  },
                  child: Text(
                    TTexts.forgetPassword,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ), // Row

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ()=> Get.to(()=> const NavigationMenu())  ,
                child: const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(height: TSizes.defaultSpace,),


            /// Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(()=> SignUpScreen());
                },
                child: const Text(TTexts.createAccount),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
