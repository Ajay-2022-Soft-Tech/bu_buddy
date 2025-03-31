import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/notification_model.dart';

class RideNotificationTile extends StatelessWidget {
  final RideNotification notification;

  const RideNotificationTile({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: TSizes.sm),
      child: Card(
        color: TColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.all(TSizes.sm),
          title: Text(
            notification.rideDetails,
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By ${notification.senderName}',
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  color: TColors.textSecondary,
                ),
              ),
              Text(
                notification.status,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.bold,
                  color: notification.status == 'Completed'
                      ? TColors.success
                      : notification.status == 'Pending'
                      ? TColors.warning
                      : TColors.error,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              // Handle notification action (e.g., view details)
            },
          ),
        ),
      ),
    );
  }
}
