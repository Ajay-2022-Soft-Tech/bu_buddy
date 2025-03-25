import 'package:bu_buddy/features/authentication/screens/login/widgets/login_form.dart';
import 'package:bu_buddy/features/authentication/screens/login/widgets/login_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/styles/spacing_styles.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_button.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/constants/texts.dart';
import '../../../../utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              // Logo , Title and sub title
              TLoginHeader(dark: dark),

              /// Form
              TLoginForm(),

              /// Divider
              TFormDivider(dividerText: TTexts.orSignInWith.capitalize!,),
              SizedBox(height: TSizes.spaceBtwSections,),

              /// Footer
              TSocialButtons(), // Row


            ],
          ),
        ),
      ),
    );
  }
}

