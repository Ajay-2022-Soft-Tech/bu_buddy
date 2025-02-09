

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/texts.dart';
import '../../category_selection/category_selection_screen.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Disable default back button
        title: Text('Carpool Home'),
        backgroundColor: TColors.primary,  // Using the primary color from TColors
        elevation: 0,
        toolbarHeight: TSizes.appBarHeight, // Using the app bar height from TSizes
        leading: IconButton(
          icon: Icon(Icons.arrow_back),  // Back arrow icon
          onPressed: () {
            Get.to(CategorySelectionScreen());  // Navigate back to the previous screen
          },
        ),
      ),
    );
  }
}

