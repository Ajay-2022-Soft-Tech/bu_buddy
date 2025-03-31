import 'package:bu_buddy/features/personalization/screens/notifications/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/user_controller.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance; // Get the controller instance

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Disable default back button
        title: Text(
          'Ride Notifications',
          style: TextStyle(
            fontSize: TSizes.fontSizeLg,
            fontWeight: FontWeight.bold,
            color: TColors.white,
          ),
        ),
        backgroundColor: TColors.primary,  // Using primary color from TColors
        elevation: 5,  // Light shadow effect for the AppBar
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),  // Consistent padding around the content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Heading
              Padding(
                padding: EdgeInsets.symmetric(vertical: TSizes.md),
                child: Center(
                  child: Text(
                    'Your Ride Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: TSizes.fontSizeLg,
                      fontWeight: FontWeight.bold,
                      color: TColors.textPrimary,
                    ),
                  ),
                ),
              ),

              // Shimmer Effect for loading state
              Obx(() {
                return controller.profileLoading.value
                    ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3, // Show 3 loading shimmer notifications
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Container(
                          height: 20,
                          width: 200,
                          color: Colors.white,
                        ),
                        subtitle: Container(
                          height: 15,
                          width: 150,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: RideNotification.getDemoNotifications().length,
                  itemBuilder: (context, index) {
                    var notification = RideNotification.getDemoNotifications()[index];
                    return RideNotificationTile(notification: notification); // Custom widget for each notification
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
