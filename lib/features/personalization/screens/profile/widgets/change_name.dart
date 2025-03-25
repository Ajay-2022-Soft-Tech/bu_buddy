import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../controllers/update_name_controller.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpdateNameController());
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Change Name', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use real name for easy verification. This name will appear on several pages.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            SizedBox(height: TSizes.spaceBtwSections),
            // Text field and Button
            Form(
              key: controller.updateUserNameFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: controller.firstName,
                    validator: (value) => TValidator.validateEmptyText('First name', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  ),
                  SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: controller.lastName,
                    validator: (value) => TValidator.validateEmptyText('Last name', value),
                    expands: false,
                    decoration: const InputDecoration(labelText: TTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  ),
                ],
              ),
            ),
             SizedBox(height: TSizes.spaceBtwSections),
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.updateUserName(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
