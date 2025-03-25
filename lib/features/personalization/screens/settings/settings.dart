import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/list_tile/settings_menu_tile.dart';
import '../../../../common/widgets/list_tile/user_profile.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/login/login_controller.dart';
import '../../../authentication/screens/login/login.dart';
import '../address/address.dart';
import '../profile/profile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(LoginController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Header
            TPrimaryHeaderContainer(
                child: Column(
              children: [
                TAppBar(
                  title: Text('Account',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: TColors.white)),
                ),
                SizedBox(height: TSizes.spaceBtwSections),

                ///   User Profile Card
                TUserProfileTile(
                    onPressed: () => Get.to(() => ProfileScreen())),
                SizedBox(
                  height: TSizes.spaceBtwSections,
                ),

                /// -- Body
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Account Settings
                  const TSectionHeading(
                    title: 'Account Settings',
                    showActionButton: false,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                      icon: Iconsax.safe_home,
                      title: 'My Addresses',
                      subTitle: 'Set shopping delivery address',
                      onTap: () => Get.to(() => const UserAddressScreen())),
                  TSettingsMenuTile(
                      icon: Iconsax.shopping_cart,
                      title: 'My Cart',
                      subTitle: 'Add, remove products and move to checkout'),
                  TSettingsMenuTile(
                      icon: Iconsax.bag_tick,
                      title: 'My Orders',
                      subTitle: 'In-progress and Completed Orders',
                    // onTap: () => Get.to(() => const OrderScreen())
                  ),
                  TSettingsMenuTile(
                      icon: Iconsax.bank,
                      title: 'Bank Account',
                      subTitle: 'Withdraw balance to registered bank account'),
                  TSettingsMenuTile(
                      icon: Iconsax.discount_shape,
                      title: 'My Coupons',
                      subTitle: 'List of all the discounted coupons'),
                  TSettingsMenuTile(
                      icon: Iconsax.notification,
                      title: 'Notifications',
                      subTitle: 'Set any kind of notification message'),
                  TSettingsMenuTile(
                      icon: Iconsax.security_card,
                      title: 'Account Privacy',
                      subTitle: 'Manage data usage and connected accounts'),

                  SizedBox(height: TSizes.spaceBtwSections),
                  TSectionHeading(
                      title: 'App Settings', showActionButton: false),
                  SizedBox(height: TSizes.spaceBtwItems),
                  TSettingsMenuTile(
                      icon: Iconsax.document_upload,
                      title: 'Load Data',
                      subTitle: 'Upload Data to your Cloud Firebase'),

                  /// -- App Settings
                  SizedBox(height: TSizes.spaceBtwSections),
                  TSectionHeading(
                      title: 'App Settings', showActionButton: false),
                  SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.location,
                    title: 'Geolocation',
                    subTitle: 'Set recommendation based on location',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  // TSettingsMenuTile

                  TSettingsMenuTile(
                    icon: Iconsax.security_user,
                    title: 'Safe Mode',
                    subTitle: 'Search result is safe for all ages',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  // TSettingsMenuTile

                  TSettingsMenuTile(
                    icon: Iconsax.image,
                    title: 'HD Image Quality',
                    subTitle: 'Set image quality to be seen',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),

                  TSettingsMenuTile(
                    icon: Iconsax.document_upload,
                    title: 'Load Data',
                    subTitle: 'Upload Data to your Cloud Firebase',
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Perform logout actions
                        controller.userController.onClose(); // Assuming this clears the user session

                        // After logging out, navigate to the SignInScreen
                        Get.offAll(() => const LoginScreen()); // Navigate to the sign-in screen
                      },
                      child: const Text('Logout'),
                    ), // OutlinedButton
                  ), // SizedBox
                  // SizedBox
                  const SizedBox(height: TSizes.spaceBtwSections * 2.5),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
