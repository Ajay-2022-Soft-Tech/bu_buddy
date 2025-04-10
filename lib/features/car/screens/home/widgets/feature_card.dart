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
  final PageController _pageController = PageController(viewportFraction: 0.97); // Wider cards
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
    // Using a fixed height container to prevent layout issues
    return SizedBox(
      height: 400, // Fixed height to prevent layout recursion
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
                        child: _buildFeatureCard(_rideOffers[index], index),
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
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _rideOffers.length,
                    (index) => _buildPageIndicator(index == _currentPage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? TColors.primary : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive ? [
          BoxShadow(
            color: TColors.primary.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          )
        ] : null,
      ),
    );
  }

  Widget _buildFeatureCard(RideOffer offer, int index) {
    return Container(
      margin: EdgeInsets.only(
        right: index == _rideOffers.length - 1 ? 0 : 6, // Reduced from 12
        left: index == 0 ? 0 : 6, // Reduced from 12
        top: TSizes.spaceBtwItems,
        bottom: TSizes.spaceBtwItems / 2,
      ),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
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
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: _buildCardHeader(offer),
                  ),

                  // Body - most content goes here
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                      physics: const BouncingScrollPhysics(),
                      child: _buildCardBody(offer),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(TSizes.md),
                    child: _buildCardFooter(offer),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(RideOffer offer) {
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
                  color: TColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  offer.icon,
                  color: TColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Title with gradient text
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [TColors.primary, TColors.primary.withBlue(180)],
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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

  Widget _buildCardBody(RideOffer offer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route section
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Route information with from/to
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 10,
                      child: _buildRouteInfo(
                        'From',
                        offer.from,
                        Icons.location_on_outlined,
                        Colors.blue.shade700,
                      ),
                    ),
                    // Vertical path with decorations
                    SizedBox(
                      width: 30,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VerticalDivider(
                              color: Colors.grey.withOpacity(0.3),
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
                            // Small dots along the path
                            ...List.generate(
                              3,
                                  (i) => Positioned(
                                top: 25 + (i * 5),
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: _buildRouteInfo(
                        'To',
                        offer.to,
                        Icons.flag_outlined,
                        Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.grey.withOpacity(0.3),
                height: 30,
                thickness: 1,
              ),

              // Trip details with Wrap for flexibility
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  _buildInfoChip(
                    icon: Icons.access_time_rounded,
                    label: offer.time,
                    color: Colors.purple.shade700,
                  ),
                  _buildInfoChip(
                    icon: Icons.person_outline_rounded,
                    label: '${offer.availableSeats} seats',
                    color: Colors.orange.shade700,
                  ),
                  _buildInfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: '${offer.price.toInt()} only',
                    color: Colors.green.shade700,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Conditional description
        if (offer.description != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About this ride',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description!,
                  style: TextStyle(
                    fontSize: TSizes.fontSizeSm * 0.9,
                    color: TColors.textPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Conditional amenities
        if (offer.amenities != null && offer.amenities!.isNotEmpty) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amenities',
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: offer.amenities!.map((amenity) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: TColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(
                          fontSize: TSizes.xs,
                          color: TColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                ).toList(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRouteInfo(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TSizes.fontSizeSm * 0.9,
            color: Colors.grey.shade600,
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
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: TSizes.fontSizeSm,
                  fontWeight: FontWeight.bold,
                  color: TColors.textPrimary,
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildCardFooter(RideOffer offer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Driver info with increased space
          Expanded(
            flex: 3, // Increased from default
            child: Row(
              children: [
                // Driver avatar with online indicator
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade200,
                        child: CircleAvatar(
                          radius: 17,
                          backgroundColor: TColors.primary.withOpacity(0.15),
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: TColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Driver info with tooltip for long names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Tooltip(
                        message: offer.driverName,
                        child: Text(
                          offer.driverName,
                          style: const TextStyle(
                            fontSize: TSizes.fontSizeSm,
                            fontWeight: FontWeight.bold,
                            color: TColors.textPrimary,
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
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            offer.rating.toString(),
                            style: const TextStyle(
                              fontSize: TSizes.xs,
                              fontWeight: FontWeight.w600,
                              color: TColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            height: 4,
                            width: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "Superdriver",
                              style: TextStyle(
                                fontSize: TSizes.xs * 0.9,
                                color: TColors.primary.withOpacity(0.7),
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
          const SizedBox(width: 8), // Reduced from 10
          // Smaller Book button
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Book ride action
          },
          borderRadius: BorderRadius.circular(12), // Slightly increased radius
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.2),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  TColors.primary,
                  Color(0xFF6870CB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12), // Slightly increased radius
              boxShadow: [
                BoxShadow(
                  color: TColors.primary.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // Increased padding
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    color: Colors.white,
                    size: 16, // Increased from 14
                  ),
                  SizedBox(width: 6), // Increased from 4
                  Text(
                    'Book', // Kept as 'Book' as requested
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.fontSizeSm, // Increased from TSizes.xs
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
