import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class RideOffer {
  final String id;
  final String driverName;
  final double rating;
  final String from;
  final String to;
  final String time;
  final int availableSeats;
  final double price;
  final String discount;
  final IconData icon;
  final String? driverImageUrl;
  final String? description;
  final List<String>? amenities;

  RideOffer({
    required this.id,
    required this.driverName,
    required this.rating,
    required this.from,
    required this.to,
    required this.time,
    required this.availableSeats,
    required this.price,
    required this.discount,
    required this.icon,
    this.driverImageUrl,
    this.description,
    this.amenities,
  });
}

class SlidableFeatureCards extends StatefulWidget {
  const SlidableFeatureCards({Key? key}) : super(key: key);

  @override
  State<SlidableFeatureCards> createState() => _SlidableFeatureCardsState();
}

class _SlidableFeatureCardsState extends State<SlidableFeatureCards> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.97);
  late AnimationController _animationController;
  int _currentPage = 0;

  // Sample data - can be replaced with dynamic data
  final List<RideOffer> _rideOffers = [
    RideOffer(
      id: '1',
      driverName: 'Rahul Sharma',
      rating: 4.8,
      from: 'Campus Main Gate',
      to: 'City Center Mall',
      time: '10:30 AM',
      availableSeats: 3,
      price: 40,
      discount: '40% OFF',
      icon: Icons.directions_car_filled_rounded,
      description: 'Comfortable sedan with AC and music system',
      amenities: ['Wi-Fi', 'Water Bottle', 'Sanitized'],
    ),
    RideOffer(
      id: '2',
      driverName: 'Priya Verma',
      rating: 4.9,
      from: 'Railway Station',
      to: 'Tech Park',
      time: '09:15 AM',
      availableSeats: 2,
      price: 55,
      discount: '25% OFF',
      icon: Icons.electric_car,
    ),
    RideOffer(
      id: '3',
      driverName: 'Amit Kumar',
      rating: 4.7,
      from: 'Airport',
      to: 'Downtown',
      time: '02:00 PM',
      availableSeats: 4,
      price: 75,
      discount: '15% OFF',
      icon: Icons.airport_shuttle_rounded,
      amenities: ['Premium Seats', 'Luggage Space'],
    ),
    RideOffer(
      id: '4',
      driverName: 'Sneha Patel',
      rating: 4.6,
      from: 'Central Park',
      to: 'University Campus',
      time: '11:45 AM',
      availableSeats: 1,
      price: 35,
      discount: '35% OFF',
      icon: Icons.car_rental,
      description: 'Quick ride with experienced driver',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    final page = _pageController.page?.round() ?? 0;
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
        _animationController.reset();
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.blueAccent : TColors.primary;

    return SizedBox(
      height: 400,
      child: Column(
        children: [
          // Cards carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _rideOffers.length,
              itemBuilder: (context, index) {
                bool isCurrentPage = index == _currentPage;
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.85, end: isCurrentPage ? 1.0 : 0.9),
                  curve: Curves.easeOutQuint,
                  duration: const Duration(milliseconds: 350),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 350),
                        opacity: isCurrentPage ? 1.0 : 0.7,
                        child: _buildFeatureCard(_rideOffers[index], index, isDark, primaryColor),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Page indicator
          const SizedBox(height: TSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _rideOffers.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: index == _currentPage ? 24 : 8,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? primaryColor
                        : (isDark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: index == _currentPage ? [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(RideOffer offer, int index, bool isDark, Color primaryColor) {
    final textColor = isDark ? Colors.white : TColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.grey[300] : TColors.textSecondary;
    final cardBgColors = isDark
        ? [Colors.grey.shade900.withOpacity(0.8), Color(0xFF1E293B).withOpacity(0.7)]
        : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)];
    final borderColor = isDark
        ? Colors.blueAccent.withOpacity(0.3)
        : Colors.white.withOpacity(0.5);

    return Container(
      margin: EdgeInsets.only(
        right: index == _rideOffers.length - 1 ? 0 : 6,
        left: index == 0 ? 0 : 6,
        top: TSizes.spaceBtwItems,
        bottom: TSizes.spaceBtwItems / 2,
      ),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: cardBgColors,
                ),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: _buildCardHeader(offer, isDark, primaryColor),
                  ),

                  // Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                      physics: const BouncingScrollPhysics(),
                      child: _buildCardBody(offer, isDark, textColor, primaryColor),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: _buildCardFooter(offer, isDark, textColor, secondaryTextColor, primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(RideOffer offer, bool isDark, Color primaryColor) {
    final headerGradient = isDark
        ? [Colors.blueAccent, Colors.blueAccent.withBlue(220)]
        : [primaryColor, primaryColor.withBlue(180)];

    final discountColors = isDark
        ? [Colors.green.shade400, Colors.green.shade600]
        : [Colors.green.shade600, Colors.green.shade700];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side - icon and title
        Flexible(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                  boxShadow: [BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )],
                ),
                child: Icon(offer.icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Title with gradient text
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: headerGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Today's Special",
                    style: TextStyle(
                      fontSize: TSizes.fontSizeMd,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Discount badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: discountColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(
              color: Colors.green.withOpacity(isDark ? 0.2 : 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )],
          ),
          child: Text(
            offer.discount,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: TSizes.fontSizeSm,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardBody(RideOffer offer, bool isDark, Color textColor, Color primaryColor) {
    final routeBgColor = isDark
        ? Color(0xFF1F2937).withOpacity(0.9)
        : Colors.white.withOpacity(0.7);

    final dividerColor = isDark
        ? Colors.grey.withOpacity(0.4)
        : Colors.grey.withOpacity(0.3);

    final labelColor = isDark ? Colors.grey[300] : Colors.grey[700];

    final descriptionColor = isDark
        ? Colors.grey[400]
        : textColor.withOpacity(0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route section
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: routeBgColor,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route information with from/to
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // From location
                    Expanded(
                      flex: 10,
                      child: _buildRouteInfo('From', offer.from,
                          Icons.location_on_outlined, Colors.blue.shade700, isDark, textColor),
                    ),
                    // Path visualization
                    SizedBox(
                      width: 30,
                      child: _buildRoutePath(isDark),
                    ),
                    // To location
                    Expanded(
                      flex: 10,
                      child: _buildRouteInfo('To', offer.to,
                          Icons.flag_outlined, Colors.red.shade700, isDark, textColor),
                    ),
                  ],
                ),
              ),

              Divider(color: dividerColor, height: 30, thickness: 1),

              // Trip details
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  _buildInfoChip(
                    icon: Icons.access_time_rounded,
                    label: offer.time,
                    color: isDark ? Colors.purple.shade400 : Colors.purple.shade700,
                    isDark: isDark,
                  ),
                  _buildInfoChip(
                    icon: Icons.person_outline_rounded,
                    label: '${offer.availableSeats} seats',
                    color: isDark ? Colors.orange.shade400 : Colors.orange.shade700,
                    isDark: isDark,
                  ),
                  _buildInfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: '${offer.price.toInt()} only',
                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Description if available
        if (offer.description != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About this ride',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description!,
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm * 0.9,
                    color: descriptionColor,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Amenities if available
        if (offer.amenities != null && offer.amenities!.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amenities',
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: offer.amenities!.map((amenity) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    amenity,
                    style: TextStyle(
                      fontSize: TSizes.xs,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRoutePath(bool isDark) {
    final dotColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          VerticalDivider(
            color: isDark ? Colors.grey.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
            thickness: 1,
            width: 10,
          ),
          Positioned(
            top: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          ...List.generate(
            3,
                (i) => Positioned(
              top: 25 + (i * 5),
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(
      String title, String value, IconData icon, Color color, bool isDark, Color textColor) {

    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TSizes.fontSizeSm * 0.9,
            color: labelColor,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 0.2,
                ),
                maxLines: 2,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDark ? 0.2 : 0.15),
            color.withOpacity(isDark ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.4 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
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

  Widget _buildCardFooter(
      RideOffer offer, bool isDark, Color textColor, Color? secondaryTextColor, Color primaryColor) {

    final footerBgColor = isDark
        ? Color(0xFF1F2937).withOpacity(0.6)
        : Colors.white.withOpacity(0.5);

    final avatarBgColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    final driverIconBgColor = isDark
        ? Colors.blueAccent.withOpacity(0.15)
        : primaryColor.withOpacity(0.15);

    final onlineIndicatorBorderColor = isDark
        ? Colors.grey.shade800
        : Colors.white;

    final bookButtonColors = isDark
        ? [Colors.blueAccent, Color(0xFF6878EB)]
        : [primaryColor, Color(0xFF6870CB)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: footerBgColor,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Driver info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Driver avatar with online indicator
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: avatarBgColor,
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: driverIconBgColor,
                        child: Icon(Icons.person, size: 20, color: primaryColor),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.greenAccent : Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: onlineIndicatorBorderColor, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Driver details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: offer.driverName,
                        child: Text(
                          offer.driverName,
                          style: TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.amber.withOpacity(0.2) : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.star, size: 12, color: Colors.amber),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            offer.rating.toString(),
                            style: TextStyle(
                              fontSize: TSizes.xs,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Superdriver",
                              style: TextStyle(
                                fontSize: TSizes.xs * 0.9,
                                color: primaryColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 8),
          // Book button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.2),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bookButtonColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_outlined, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Book',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.fontSizeSm,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}