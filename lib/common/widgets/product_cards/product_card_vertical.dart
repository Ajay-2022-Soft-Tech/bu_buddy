import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../styles/rounded_container.dart';
import '../../styles/shadows.dart';
import '../../styles/t_rounded_image.dart';
import '../icons/t_circular_icon.dart';
import '../text/product_price_text.dart';
import '../text/product_title_text.dart';
import '../text/t_brand_title_text.dart';
import '../text/t_brand_title_text_with_verified_icon.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = THelperFunctions.isDarkMode(context);

    /// Container with side paddings, color, edges, radius and shadow.
    return GestureDetector(
      onTap: (){},
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ), // BoxDecoration
        child: Column(
          children: [
            /// Thumbnail, Wishlist Button, Discount Tag
            TRoundedContainer(
              height: 180,
              padding: const EdgeInsets.all(TSizes.sm),
              backgroundColor: dark ? TColors.dark : TColors.light,
              child: Stack(
                children: [
                  /// -- Thumbnail Image
                  const TRoundedImage(
                    imageUrl: TImages.productImage1,
                    applyImageRadius: true,
                  ),


                  /// -- Sale Tag
                  Positioned(
                    top: 12,
                    child: TRoundedContainer(
                      radius: TSizes.sm,
                      backgroundColor: TColors.secondary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm, vertical: TSizes.xs),
                      child: Text('25%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.apply(color: TColors.black)),
                    ),
                  ),

                  /// -- Favourite Icon Button
                  Positioned(
                    top: 0,
                      right: 0,
                      child: TCircularIcon(
                    icon: Iconsax.heart5,
                    color: Colors.red,
                  )),
                ],
              ),
            ),
            SizedBox(height: TSizes.spaceBtwItems/2,),

            /// Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TProductTitleText(title: 'Green Nike Air Shoes', smallSize: true),
                const SizedBox(height: TSizes.spaceBtwItems / 2),
                TBrandTitleWithVerifiedIcon(title: 'Nike'),


              ],
            ), // Padding
            Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Price
                Padding(
                  padding: const EdgeInsets.only(left:TSizes.sm),
                  child: const TProductPriceText(price: '3500.0'),
                ),
                // Text

                Container(
                  decoration: const BoxDecoration(
                    color: TColors.dark,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(TSizes.cardRadiusMd),
                      bottomRight: Radius.circular(TSizes.productImageRadius),
                    ), // BorderRadius.only
                  ), // BoxDecoration
                  child: const SizedBox(
                    width: TSizes.iconLg * 1.2,
                    height: TSizes.iconLg * 1.2,
                    child: Center(child: Icon(Iconsax.add, color: TColors.white)),
                  ), // SizedBox
                ), // Container
              ],
            ), //

          ],
        ), // Column
      ),
    ); // Container
  }
}

