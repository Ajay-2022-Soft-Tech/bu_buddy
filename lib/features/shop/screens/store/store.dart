import 'package:flutter/material.dart';
import '../../../../common/styles/rounded_container.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/search_container.dart';
import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/products/cart/cart_menu.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../common/widgets/text/t_brand_title_text_with_verified_icon.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text('Store', style: Theme.of(context).textTheme.headlineMedium,),
        actions: [

          TCartCounterIcon(onPressed: (){}, iconColor: Colors.black,)
        ],
      ),
      body: NestedScrollView(headerSliverBuilder: (_,innerBoxIsScrolled){
        return [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: true,
            backgroundColor: THelperFunctions.isDarkMode(context)? TColors.black : TColors.white,
            expandedHeight: 440,

            flexibleSpace: Padding(
              padding: EdgeInsets.all(TSizes.defaultSpace),
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [

                  SizedBox(height: TSizes.spaceBtwItems ,),
                  TSearchContainer(text: 'Search in Store',showBorder: true,showBackground: false,padding: EdgeInsets.zero,),
                  SizedBox(height: TSizes.spaceBtwSections ,),


                //   Featured Brands

                  TSectionHeading(title: 'Featured Brands', onPressed: () {}),
                  SizedBox(height: TSizes.spaceBtwItems / 1.5),


                  TGridLayout(itemCount: 4,mainAxisExtent: 80, itemBuilder: (_,index){

                    return GestureDetector(
                      onTap: null,
                      child: TRoundedContainer(
                        padding: const EdgeInsets.all(TSizes.sm),
                        showBorder: true,
                        backgroundColor: Colors.transparent,
                        child: Row(
                          children: [

                            ///   Icon
                            /// -- Icon
                            Flexible(
                              child: TCircularImage(
                                isNetworkImage: false,
                                image: TImages.clothIcon,
                                backgroundColor: Colors.transparent,
                                overlayColor: THelperFunctions.isDarkMode(context) ? TColors.white : TColors.black,
                              ),
                            ), // TCircularImage
                            const SizedBox(width: TSizes.spaceBtwItems/2,),


                            //   Text
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TBrandTitleWithVerifiedIcon(title: 'Nike',brandTextSize: TextSizes.large,),
                                  Text('256 products',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelMedium,)
                              
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );

                  }),

                ],

              ),
            ),

          )
        ];
      }, body: Container()),
    );
  }
}

