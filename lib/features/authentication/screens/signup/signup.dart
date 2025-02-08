import 'package:bu_buddy/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_button.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              TTexts.signupTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: TSizes.spaceBtwSections,
            ),

            //   Form
            TSignupForm(),

            SizedBox(height: TSizes.spaceBtwSections),


            /// Divider
            TFormDivider(dividerText: TTexts.orSignUpWith.capitalize!),
            SizedBox(height: TSizes.spaceBtwSections),

            /// Social Buttons
            const TSocialButtons(),
          ],
        ),
      ),
    );
  }
}

