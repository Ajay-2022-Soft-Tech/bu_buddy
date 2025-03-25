import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../data/repositories/authentication/autentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/http/network_manager.dart';
import '../../../../utils/popus/full_screen_loader.dart';
import '../../../../utils/popus/loaders.dart';
import '../../screens/password_configuration/reset_password.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  // Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  // Send Reset Password Email
  sendPasswordResetEmail() async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Processing your request...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) { // <-- Correct logic
        TFullScreenLoader.stopLoading();
        return;
      }


      // send the email to resent
      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      // Remove the Loader
      TFullScreenLoader.stopLoading();

      // Show Success Screen
      TLoaders.successSnackBar(title: 'Email Sent', message: 'Email Link Sent to Reset your Password'.tr);

// Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());

    }
  }
  resendPasswordResetEmail(String email) async {
    try {
      // Start Loading
      TFullScreenLoader.openLoadingDialog('Processing your request...', TImages.docerAnimation);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Send Email to Reset Password
      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show Success Screen
      TLoaders.successSnackBar(title: 'Email Sent', message: 'Email Link Sent to Reset your Password'.tr);
    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

}
