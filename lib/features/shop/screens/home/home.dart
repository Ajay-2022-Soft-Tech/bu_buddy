import 'package:bu_buddy/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:bu_buddy/features/shop/screens/home/widgets/home_categories.dart';
import 'package:bu_buddy/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/product_cards/product_card_vertical.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header - Tutorial [Section # 3, Video # 2]
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  // AppBar
                  THomeAppBar(),

                  //   SearchBar
                  SizedBox(height: TSizes.spaceBtwSections),
                  TSearchContainer(text: "Search in store"),
                  SizedBox(height: TSizes.spaceBtwSections),

                  //   Categories
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        // Heading
                        TSectionHeading(
                          title: "Popular Categories",
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: TSizes.defaultSpace),

                        //   Categories
                        THomeCategories()
                      ],
                    ),
                  )
                ],
              ),
            ),

            /// Body -- Tutorial [Section # 3, Video # 5]
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// Promo Slider -- Tutorial [Section # 3, Video # 6]
                  const TPromoSlider(banners: [TImages.promoBanner1, TImages.promoBanner2, TImages.promoBanner3]),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// Heading
                  const TSectionHeading(title: 'Popular Products', onPressed: null),
                  SizedBox(height: TSizes.spaceBtwItems),

                  /// Popular Products -- Tutorial [Section # 3, Video # 7]
                  TGridLayout(itemCount: 10, itemBuilder: (_, index) => const TProductCardVertical()),

                ],
              ),
            ),




          ],
        ),
      ),
    );
  }
}
