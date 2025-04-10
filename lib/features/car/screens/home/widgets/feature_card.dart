import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class ImprovedFeatureCard extends StatelessWidget {
  const ImprovedFeatureCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: TSizes.spaceBtwItems),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(TSizes.md),
            child: Column(
              children: [
                _buildCardHeader(),
                SizedBox(height: TSizes.sm),
                _buildCardBody(),
                SizedBox(height: TSizes.sm),
                _buildCardFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              ),
              child: Icon(
                Icons.directions_car_filled_rounded,
                color: TColors.primary,
                size: 22,
              ),
            ),
            SizedBox(width: TSizes.sm),
            Text(
              "Today's Special",
              style: TextStyle(
                fontSize: TSizes.fontSizeMd,
                fontWeight: FontWeight.bold,
                color: TColors.primary,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '40% OFF',
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildRouteInfo(
                    'From',
                    'Campus Main Gate',
                    Icons.location_on_outlined,
                    Colors.blue.shade700,
                  ),
                ),
                Container(
                  height: 50,
                  child: VerticalDivider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 1,
                    width: 40,
                  ),
                ),
                Expanded(
                  child: _buildRouteInfo(
                    'To',
                    'City Center Mall',
                    Icons.flag_outlined,
                    Colors.red.shade700,
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.withOpacity(0.3), height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoChip(
                  icon: Icons.access_time_rounded,
                  label: '10:30 AM',
                  color: Colors.purple.shade700,
                ),
                _buildInfoChip(
                  icon: Icons.person_outline_rounded,
                  label: '3 seats',
                  color: Colors.orange.shade700,
                ),
                _buildInfoChip(
                  icon: Icons.currency_rupee_rounded,
                  label: '₹40 only',
                  color: Colors.green.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteInfo(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TSizes.fontSizeSm * 0.9,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm * 0.9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: TColors.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 18,
                color: TColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rahul Sharma',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    fontWeight: FontWeight.bold,
                    color: TColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 2),
                    Text(
                      '4.8',
                      style: TextStyle(
                        fontSize: TSizes.xs,
                        color: TColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            // Book ride action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Book Now',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeSm,
            ),
          ),
        ),
      ],
    );
  }
}