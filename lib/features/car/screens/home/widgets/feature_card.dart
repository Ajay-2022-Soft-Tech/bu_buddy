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
  });
}

class SlidableFeatureCards extends StatefulWidget {
  const SlidableFeatureCards({Key? key}) : super(key: key);

  @override
  State<SlidableFeatureCards> createState() => _SlidableFeatureCardsState();
}

class _SlidableFeatureCardsState extends State<SlidableFeatureCards> {
  final PageController _pageController = PageController(viewportFraction: 0.95); // Increased for wider cards
  int _currentPage = 0;

  // Mock data for different ride offers
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
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    int page = _pageController.page!.round();
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Page view for slidable cards
        SizedBox(
          height: 360, // Further increased height for flexibility
          child: PageView.builder(
            controller: _pageController,
            itemCount: _rideOffers.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(_rideOffers[index], index);
            },
          ),
        ),

        // Page indicator
        const SizedBox(height: TSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _rideOffers.length,
                (index) => _buildPageIndicator(index == _currentPage),
          ),
        ),
      ],
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
      ),
    );
  }

  Widget _buildFeatureCard(RideOffer offer, int index) {
    return Container(
      margin: EdgeInsets.only(
        right: index == _rideOffers.length - 1 ? 0 : 8,
        left: index == 0 ? 0 : 8,
        top: TSizes.spaceBtwItems,
        bottom: TSizes.spaceBtwItems / 2,
      ),
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
            padding: const EdgeInsets.all(TSizes.md),
            child: Column(
              children: [
                _buildCardHeader(offer),
                const SizedBox(height: TSizes.sm),
                _buildCardBody(offer),
                const SizedBox(height: TSizes.sm),
                _buildCardFooter(offer),
              ],
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
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
                ),
                child: Icon(
                  offer.icon,
                  color: TColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Today's Special",
                  style: TextStyle(
                    fontSize: TSizes.fontSizeMd,
                    fontWeight: FontWeight.bold,
                    color: TColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            offer.discount,
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

  Widget _buildCardBody(RideOffer offer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Route information section (From/To)
            Row(
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
                SizedBox(
                  height: 50,
                  child: VerticalDivider(
                    color: Colors.grey.withOpacity(0.3),
                    thickness: 1,
                    width: 20, // Reduced width
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

            Divider(color: Colors.grey.withOpacity(0.3), height: 24),

            // Details section (Time, Seats, Price) - Made flexible
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInfoChip(
                    icon: Icons.access_time_rounded,
                    label: offer.time,
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.person_outline_rounded,
                    label: '${offer.availableSeats} seats',
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: Icons.currency_rupee_rounded,
                    label: '${offer.price.toInt()} only',
                    color: Colors.green.shade700,
                  ),
                ],
              ),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Icon(
              icon,
              size: 16, // Slightly reduced size
              color: color,
            ),
            const SizedBox(width: 4), // Reduced spacing
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
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

  Widget _buildCardFooter(RideOffer offer) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: TColors.primary.withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 18,
                  color: TColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.driverName,
                      style: const TextStyle(
                        fontSize: TSizes.fontSizeSm,
                        fontWeight: FontWeight.bold,
                        color: TColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          offer.rating.toString(),
                          style: const TextStyle(
                            fontSize: TSizes.xs,
                            color: TColors.textSecondary,
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
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Book ride action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
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

