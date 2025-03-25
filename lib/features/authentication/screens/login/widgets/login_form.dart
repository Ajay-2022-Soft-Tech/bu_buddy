import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/login/login_controller.dart';
import '../../password_configuration/forget_password.dart';
import '../../signup/signup.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Form(
      key: controller.loginFormKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              controller: controller.email,
              validator: (value)=> TValidator.validateEmail(value),
              decoration: InputDecoration(prefixIcon: const Icon(Iconsax.direct_right), labelText: TTexts.email,
              ),
            ), // TextFormField
            const SizedBox(height: TSizes.spaceBtwInputFields),

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
            ), // Tex
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remember Me
                Row(
                  children: [
                    Obx(()=> Checkbox(value: controller.rememberMe.value, onChanged: (value) => controller.rememberMe.value = !controller.rememberMe.value)),
                    const Text(TTexts.rememberMe),
                  ],
                ), // Row

                /// Forget Password
                GestureDetector(
                  onTap: () {
                    // TODO: Implement navigation to Forgot Password screen
                    Get.to(() => const ForgetPassword());
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
                onPressed: () => controller.emailAndPasswordSignIn(),
                child: const Text(TTexts.signIn),
              ),
            ),

            const SizedBox(
              height: TSizes.defaultSpace,
            ),

            /// Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.to(() => SignUpScreen());
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
