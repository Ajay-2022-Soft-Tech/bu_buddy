import 'package:bu_buddy/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:bu_buddy/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    return Scaffold(
      appBar: TAppBar(
        title: Text('Profile'),
        showBackArrow: true,

      ),
      body: SingleChildScrollView(

        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                  /// Profile Picture
                    TCircularImage(image: TImages.user,width: 80,height: 80,),
                    TextButton(onPressed: (){}, child: Text("Change Profile Picture"))
                  ],
                ),
              ),
              SizedBox(height: TSizes.spaceBtwItems / 2),
              Divider(),
              SizedBox(height: TSizes.spaceBtwItems),
              TSectionHeading(title: 'Profile Information',showActionButton: false,),
              SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu( title: 'Name', value: controller.user.value.fullName,onPressed: () => Get.to(()=> ChangeName())),
              TProfileMenu(title: 'User ID', value: controller.user.value.id,icon: Iconsax.copy, onPressed: () {}),
              TProfileMenu(title: 'E-mail', value: controller.user.value.email, onPressed: () {}),
              TProfileMenu(title: 'Phone Number', value: controller.user.value.phoneNumber, onPressed: () {}),
              TProfileMenu(title: 'Gender', value: 'Male', onPressed: () {}),
              TProfileMenu(title: 'Date of Birth', value: '10 Oct, 2000', onPressed: () {}),

              const Divider(),
              SizedBox(height: TSizes.spaceBtwItems),
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup() ,
                  child: const Text(
                    'Close Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),



            ],
          ),
        ),
        /// Details


      ),
    );
  }
}

