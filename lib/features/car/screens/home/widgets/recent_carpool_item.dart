// File: recent_carpool_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class RecentCarpoolItem extends StatelessWidget {
  final String from;
  final String to;
  final String time;
  final String date;
  final int seats;
  final String driver;
  final String price;
  final String avatar;
  final int index;
  final VoidCallback? onBookPressed;

  const RecentCarpoolItem({
    Key? key,
    required this.from,
    required this.to,
    required this.time,
    required this.date,
    required this.seats,
    required this.driver,
    required this.price,
    required this.avatar,
    required this.index,
    this.onBookPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: TSizes.md),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        ),
        child: Padding(
          padding: EdgeInsets.all(TSizes.md),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: TColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_car_rounded,
                      color: TColors.primary,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                from,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: TSizes.fontSizeMd,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: TColors.textSecondary,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                to,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: TSizes.fontSizeMd,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: TColors.textSecondary,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '$time • $date',
                                      style: TextStyle(
                                        fontSize: TSizes.fontSizeSm * 0.85,
                                        color: TColors.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                price,
                                style: TextStyle(
                                  fontSize: TSizes.fontSizeSm,
                                  fontWeight: FontWeight.bold,
                                  color: TColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: TColors.textSecondary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$seats seats available',
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm * 0.9,
                          color: TColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onBookPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: TColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: TSizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 600.ms, delay: 1200.ms + (index * 200).ms)
        .moveX(begin: 30, end: 0, curve: Curves.easeOutQuint);
  }
}