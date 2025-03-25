import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the theme is dark mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TAppBar(
        title: Text('Add new Address'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                    ),
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.mobile),
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                    ),
                  ),
                ),
                SizedBox(height: TSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.building_31),
                          labelText: 'Street',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.code),
                          labelText: 'Postal Code',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: TSizes.spaceBtwInputFields),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.building),
                          labelText: 'City',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: TSizes.spaceBtwInputFields),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Iconsax.activity),
                          labelText: 'State',
                          labelStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                    focusColor: Colors.white,

                    labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black, // Dynamic label color
                    ),
                  ),
                ),
                SizedBox(height: TSizes.defaultSpace),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
