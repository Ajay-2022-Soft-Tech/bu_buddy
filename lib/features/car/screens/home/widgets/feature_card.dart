import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../features/car/screens/chat_screen/chat_screen.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class RideOfferSlider extends StatefulWidget {
  const RideOfferSlider({Key? key}) : super(key: key);

  @override
  State<RideOfferSlider> createState() => _RideOfferSliderState();
}

class _RideOfferSliderState extends State<RideOfferSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _offerData = [
    {
      'discount': '40% OFF',
      'from': 'Campus Main Gate',
      'to': 'City Center Mall',
      'time': '10:30 AM',
      'seats': '3 seats',
      'price': '40 only',
      'student': 'Rahul Sharma',
      'studentId': 'student_1',
      'rating': 4.8,
    },
    {
      'discount': '25% OFF',
      'from': 'College Hostel',
      'to': 'Railway Station',
      'time': '12:15 PM',
      'seats': '2 seats',
      'price': '60 only',
      'student': 'Priya Patel',
      'studentId': 'student_2',
      'rating': 4.7,
    },
    {
      'discount': '30% OFF',
      'from': 'Metro Station',
      'to': 'Campus Library',
      'time': '2:00 PM',
      'seats': '4 seats',
      'price': '35 only',
      'student': 'Amit Kumar',
      'studentId': 'student_3',
      'rating': 4.9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Text(
            "Available Rides",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
        SizedBox(height: TSizes.spaceBtwItems / 2),
        SizedBox(
          height: 290,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _offerData.length,
            itemBuilder: (context, index) {
              return FeatureCard(offerData: _offerData[index]);
            },
          ),
        ),
        SizedBox(height: TSizes.spaceBtwItems / 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _offerData.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final Map<String, dynamic> offerData;

  const FeatureCard({
    Key? key,
    required this.offerData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: TSizes.spaceBtwItems / 2,
        vertical: TSizes.spaceBtwItems / 2,
      ),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black38,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.grey.shade900, Colors.grey.shade800]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(TSizes.md - 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCardHeader(context, isDark),
                SizedBox(height: TSizes.sm / 2),
                Expanded(child: _buildCardBody(context, isDark)),
                SizedBox(height: TSizes.sm / 2),
                _buildCardFooter(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: TColors.primary,
                  size: 18,
                ),
              ),
              SizedBox(width: TSizes.sm / 2),
              Flexible(
                child: Text(
                  "Student Carpooling",
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : TColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withOpacity(isDark ? 0.4 : 0.3),
              width: 1,
            ),
          ),
          child: Text(
            offerData['discount'],
            style: TextStyle(
              color: isDark ? Colors.green.shade400 : Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeSm - 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey.shade800.withOpacity(0.6)
            : Colors.grey.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: isDark
            ? Border.all(
          color: Colors.grey.shade700,
          width: 1,
        )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildRouteInfo(
                      'From',
                      offerData['from'],
                      Icons.location_on_outlined,
                      Colors.blue.shade700,
                      isDark,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      color: isDark
                          ? Colors.grey.withOpacity(0.4)
                          : Colors.grey.withOpacity(0.3),
                      thickness: 1,
                      width: 16,
                    ),
                  ),
                  Expanded(
                    child: _buildRouteInfo(
                      'To',
                      offerData['to'],
                      Icons.flag_outlined,
                      Colors.red.shade700,
                      isDark,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                color: isDark
                    ? Colors.grey.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                height: 12,
                thickness: 0.5),
            _buildInfoChipsRow(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChipsRow(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildInfoChip(
            icon: Icons.access_time_rounded,
            label: offerData['time'],
            color: isDark ? Colors.purple.shade400 : Colors.purple.shade700,
            isDark: isDark,
          ),
          SizedBox(width: 6),
          _buildInfoChip(
            icon: Icons.person_outline_rounded,
            label: offerData['seats'],
            color: isDark ? Colors.orange.shade400 : Colors.orange.shade700,
            isDark: isDark,
          ),
          SizedBox(width: 6),
          _buildInfoChip(
            icon: Icons.currency_rupee_rounded,
            label: '${offerData['price']}',
            color: isDark ? Colors.green.shade400 : Colors.green.shade700,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(
      String title, String value, IconData icon, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TSizes.fontSizeSm * 0.85,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? color.withOpacity(0.8) : color,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm * 0.95,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TColors.textPrimary,
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
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: TSizes.fontSizeSm * 0.85,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, bool isDark) {
    final String studentId = offerData['studentId'] ?? 'student_${offerData['student'].hashCode}';
    final String studentName = offerData['student'];

    return SizedBox(
      height: 44, // Fixed height to ensure consistency
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: TColors.primary.withOpacity(isDark ? 0.3 : 0.2),
                  child: Icon(
                    Icons.person_outline,
                    size: 16,
                    color: TColors.primary,
                  ),
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offerData['student'],
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm * 0.95,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : TColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 2),
                          Text(
                            offerData['rating'].toString(),
                            style: TextStyle(
                              fontSize: TSizes.xs,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : TColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showJoinRideConfirmation(context, studentId, studentName, offerData),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              elevation: isDark ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size(80, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Join Ride',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: TSizes.fontSizeSm * 0.95,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinRideConfirmation(BuildContext context, String studentId, String studentName, Map<String, dynamic> rideDetails) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.directions_car_filled, color: TColors.primary),
            SizedBox(width: 10),
            Text(
              'Confirm Ride',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Would you like to join this ride with ${rideDetails['student']}?'),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationDetail(
                    Icons.location_on,
                    'From: ${rideDetails['from']}',
                    Colors.blue.shade700,
                    isDark,
                  ),
                  SizedBox(height: 8),
                  _buildConfirmationDetail(
                    Icons.location_on,
                    'To: ${rideDetails['to']}',
                    Colors.red.shade700,
                    isDark,
                  ),
                  SizedBox(height: 8),
                  _buildConfirmationDetail(
                    Icons.access_time,
                    'Time: ${rideDetails['time']}',
                    Colors.purple.shade700,
                    isDark,
                  ),
                  SizedBox(height: 8),
                  _buildConfirmationDetail(
                    Icons.payments_outlined,
                    'Cost: ${rideDetails['price']}',
                    Colors.green.shade700,
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
              Get.to(() => ChatScreen(
                receiverId: studentId,
                receiverName: studentName,
                rideDetails: rideDetails,
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Join'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationDetail(IconData icon, String text, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
