import 'package:bu_buddy/features/personalization/screens/address/widgets/single_address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'add_new_address.dart';


class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: ()=> Get.to(()=> AddNewAddressScreen()),
      child: Icon(Iconsax.add, color: TColors.white,),
        backgroundColor: TColors.primary,
      ),
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Addresses', style: Theme.of(context).textTheme.headlineSmall,),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            TSingleAddress(selectedAddress: false),
            TSingleAddress(selectedAddress: true),

          ],

        ),
        ),
      ),

    );
  }
}
