import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/ride_details.dart';
import '../../controllers/trip_controller.dart';
import '../chat_screen/chat_screen.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({Key? key}) : super(key: key);

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TripController _tripController = Get.put(TripController());
  final ScrollController _scrollController = ScrollController();

  // Animation controllers
  late AnimationController _filterController;

  // Filter variables
  bool _showFilters = false;
  final RxString _priceFilter = 'All'.obs;
  final RxString _dateFilter = 'All'.obs;
  final RxString _seatFilter = 'All'.obs;

  // Filter options
  final List<String> _priceOptions = [
    'All',
    'Under ₹200',
    '₹200-₹500',
    'Over ₹500'
  ];
  final List<String> _dateOptions = ['All', 'Today', 'This Week', 'This Month'];
  final List<String> _seatOptions = ['All', '1', '2', '3+'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize animation controllers
    _filterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tripController.fetchTrips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterController.forward();
      } else {
        _filterController.reverse();
      }
    });
  }

  List<RideDetails> _filterTrips(List<RideDetails> trips) {
    if (_priceFilter.value == 'All' && _dateFilter.value == 'All' &&
        _seatFilter.value == 'All') {
      return trips;
    }

    return trips.where((trip) {
      // Price filter
      bool matchesPrice = _priceFilter.value == 'All' ||
          (_priceFilter.value == 'Under ₹200' && trip.price < 200) ||
          (_priceFilter.value == '₹200-₹500' && trip.price >= 200 &&
              trip.price <= 500) ||
          (_priceFilter.value == 'Over ₹500' && trip.price > 500);

      // Date filter (simplified)
      bool matchesDate = _dateFilter.value == 'All';
      if (_dateFilter.value != 'All') {
        try {
          final rideDate = DateFormat('dd/MM/yyyy').parse(trip.rideDate);
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          matchesDate =
              (_dateFilter.value == 'Today' && rideDate.day == today.day &&
                  rideDate.month == today.month &&
                  rideDate.year == today.year) ||
                  (_dateFilter.value == 'This Week' && rideDate.isAfter(
                      today.subtract(Duration(days: today.weekday))) &&
                      rideDate.isBefore(
                          today.add(Duration(days: 7 - today.weekday)))) ||
                  (_dateFilter.value == 'This Month' &&
                      rideDate.month == today.month &&
                      rideDate.year == today.year);
        } catch (_) {
          matchesDate = true;
        }
      }

      // Seat filter
      bool matchesSeats = _seatFilter.value == 'All' ||
          (_seatFilter.value == '1' && trip.availableSeats == 1) ||
          (_seatFilter.value == '2' && trip.availableSeats == 2) ||
          (_seatFilter.value == '3+' && trip.availableSeats >= 3);

      return matchesPrice && matchesDate && matchesSeats;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Color(0xFF121212), Color(0xFF1E1E24)]
                : [Color(0xFFF5F7FB), Color(0xFFE4E9F2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark),

              // Filter panel
              AnimatedBuilder(
                animation: _filterController,
                builder: (context, child) {
                  return ClipRect(
                    child: SizeTransition(
                      sizeFactor: _filterController,
                      axis: Axis.vertical,
                      child: _buildFilterPanel(isDark),
                    ),
                  );
                },
              ),

              // Tab bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors
                      .white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: isDark ? Colors.white : TColors.primary,
                  unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors
                      .grey.shade700,
                  indicator: BoxDecoration(
                    color: isDark ? TColors.primary.withOpacity(0.2) : TColors
                        .primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: TColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 3))
                    ],
                    border: Border.all(
                        color: TColors.primary.withOpacity(0.5), width: 1.5),
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.calendar_1),
                          SizedBox(width: 8),
                          Text('Upcoming'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.clock),
                          SizedBox(width: 8),
                          Text('Past'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTripsList(true, isDark),
                    _buildTripsList(false, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800.withOpacity(0.8) : Colors
                    .white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Icon(Icons.arrow_back,
                  color: isDark ? Colors.white : TColors.primary),
            ),
            onPressed: () => Get.back(),
          ),

          SizedBox(width: 16),

          Text(
            'My Trips',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TColors.textPrimary,
            ),
          ),

          Spacer(),

          GestureDetector(
            onTap: _toggleFilters,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _showFilters
                    ? TColors.primary.withOpacity(isDark ? 0.3 : 0.2)
                    : isDark
                    ? Colors.grey.shade800.withOpacity(0.8)
                    : Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                ],
              ),
              child: Icon(
                Iconsax.filter,
                color: _showFilters ? TColors.primary : isDark
                    ? Colors.white
                    : TColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800.withOpacity(0.8) : Colors.white
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5))
        ],
        border: Border.all(color: TColors.primary.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Trips',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : TColors.textPrimary,
            ),
          ),
          SizedBox(height: 15),

          // Price Range Filter
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price', style: TextStyle(fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey
                            .shade700)),
                    SizedBox(height: 8),
                    _buildFilterChips(_priceOptions, _priceFilter, isDark),
                  ],
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date', style: TextStyle(fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey
                            .shade700)),
                    SizedBox(height: 8),
                    _buildFilterChips(_dateOptions, _dateFilter, isDark),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // Seats filter and apply button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Seats', style: TextStyle(fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey
                            .shade700)),
                    SizedBox(height: 8),
                    _buildFilterChips(_seatOptions, _seatFilter, isDark),
                  ],
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _toggleFilters();
                  _tripController.fetchTrips();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                ),
                child: Text('Apply', style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<String> options, RxString selectedValue,
      bool isDark) {
    return Obx(() =>
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue.value == option;
            return GestureDetector(
              onTap: () => selectedValue.value = option,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TColors.primary.withOpacity(isDark ? 0.3 : 0.2)
                      : isDark
                      ? Colors.grey.shade700.withOpacity(0.5)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? TColors.primary.withOpacity(0.8)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? TColors.primary : isDark ? Colors.grey
                        .shade300 : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight
                        .normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ));
  }

  Widget _buildTripsList(bool isUpcoming, bool isDark) {
    return Obx(() {
      if (_tripController.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: TColors.primary),
              SizedBox(height: 16),
              Text(
                'Finding your journeys...',
                style: TextStyle(fontSize: 16,
                    color: isDark ? Colors.grey.shade400 : Colors.grey
                        .shade700),
              ),
            ],
          ),
        );
      }

      final trips = _filterTrips(
          isUpcoming ? _tripController.upcomingTrips : _tripController
              .pastTrips);

      if (trips.isEmpty) {
        return _buildEmptyState(isUpcoming, isDark);
      }

      // Use ListView.builder with keepAlive and cacheExtent for better performance
      return ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
        itemCount: trips.length,
        // Add cacheExtent to preload items
        cacheExtent: 500,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildTripCard(trip, isDark);
        },
      );
    });
  }

  Widget _buildEmptyState(bool isUpcoming, bool isDark) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade800.withOpacity(0.7) : Colors.white
              .withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              isUpcoming
                  ? 'https://assets3.lottiefiles.com/packages/lf20_ucbyrun5.json'
                  : 'https://assets8.lottiefiles.com/temp/lf20_nXwOJj.json',
              width: 180,
              height: 180,
            ),
            SizedBox(height: TSizes.spaceBtwItems),
            Text(
              isUpcoming ? 'No Upcoming Trips' : 'No Past Trips',
              style: TextStyle(fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : TColors.textPrimary),
            ),
            SizedBox(height: 10),
            Text(
              isUpcoming
                  ? 'You don\'t have any upcoming trips. Book or publish a ride to get started.'
                  : 'Your past trips will appear here once you complete some rides.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
              isUpcoming
                  ? Get.offAllNamed('/home')
                  : _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 5,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(isUpcoming ? Iconsax.add_circle : Iconsax.arrow_up_1),
                  SizedBox(width: 8),
                  Text(isUpcoming ? 'Find a Ride' : 'View Upcoming',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(RideDetails trip, bool isDark) {
    final bool isMyRide = trip.userId == FirebaseAuth.instance.currentUser?.uid;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade800.withOpacity(0.75) : Colors.white
          .withOpacity(0.95),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(isDark ? 0.3 : 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isMyRide ? Iconsax.car : Iconsax.user,
                      color: TColors.primary, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMyRide ? 'Your Published Ride' : 'Ride with ${trip
                            .userName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : TColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                              Iconsax.calendar, size: 12, color: isDark ? Colors
                              .grey.shade400 : Colors.grey.shade700),
                          SizedBox(width: 4),
                          Text(
                              trip.rideDate,
                              style: TextStyle(fontSize: 13,
                                  color: isDark ? Colors.grey.shade400 : Colors
                                      .grey.shade700)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: Colors.green.withOpacity(isDark ? 0.4 : 0.3),
                        width: 1.5),
                  ),
                  child: Text(
                    '₹${trip.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green.shade400 : Colors.green
                          .shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trip details
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                // Route
                Row(
                  children: [
                    Column(
                      children: [
                        _buildLocationDot(Colors.blue),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        _buildLocationDot(Colors.red),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('FROM', style: TextStyle(fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors
                                      .grey.shade600)),
                              SizedBox(height: 2),
                              Text(
                                trip.pickupLocation,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : TColors
                                      .textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TO', style: TextStyle(fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors
                                      .grey.shade600)),
                              SizedBox(height: 2),
                              Text(
                                trip.destinationLocation,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : TColors
                                      .textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Info chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildInfoChip(icon: Iconsax.clock,
                          label: trip.rideTime,
                          color: Colors.purple,
                          isDark: isDark),
                      SizedBox(width: 10),
                      _buildInfoChip(icon: Iconsax.people,
                          label: '${trip.availableSeats} seats',
                          color: Colors.orange,
                          isDark: isDark),
                      SizedBox(width: 10),
                      _buildStatusChip(trip.isActive, isDark: isDark),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(isMyRide ? Iconsax.trash : Iconsax.support,
                            size: 18),
                        label: Text(
                            isMyRide ? 'Cancel Ride' : 'Support',
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 14)
                        ),
                        onPressed: isMyRide ? () =>
                            _tripController.cancelRide(trip) : () =>
                            _showSupportDialog(context, isDark),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isMyRide ? Colors.red : Colors.grey
                              .shade700,
                          side: BorderSide(
                            color: isMyRide
                                ? Colors.red.withOpacity(0.5)
                                : Colors.grey.withOpacity(0.5),
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(
                            isMyRide ? Iconsax.eye : Iconsax.message, size: 18),
                        label: Text(
                            isMyRide ? 'View Details' : 'Message',
                            style: TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 14)
                        ),
                        onPressed: () {
                          final rideDetailsMap = {
                            'from': trip.pickupLocation,
                            'to': trip.destinationLocation,
                            'time': trip.rideTime,
                            'date': trip.rideDate,
                            'price': '₹${trip.price.toStringAsFixed(0)}',
                            'seats': trip.availableSeats.toString(),
                            'student': trip.userName,
                            'studentId': trip.userId,
                          };
                          Get.to(() =>
                              ChatScreen(
                                  receiverId: trip.userId,
                                  receiverName: trip.userName,
                                  rideDetails: rideDetailsMap
                              ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
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
    );
  }

  Widget _buildLocationDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withOpacity(isDark ? 0.4 : 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? color.withOpacity(0.9) : color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? color.withOpacity(0.9) : color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isActive, {required bool isDark}) {
    final Color color = isActive ? Colors.green : Colors.grey;
    final String label = isActive ? 'Active' : 'Completed';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withOpacity(isDark ? 0.4 : 0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isActive ? Iconsax.tick_circle : Iconsax.tick_square, size: 16,
              color: isDark ? color.withOpacity(0.9) : color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? color.withOpacity(0.9) : color,
            ),
          ),
        ],
      ),
    );
  }
  void _showSupportDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Iconsax.support, color: TColors.primary),
            ),
            SizedBox(width: 12),
            Text('Contact Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What issue are you facing with this ride?',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: TColors.primary, width: 1.5),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.snackbar(
                'Support Request Sent',
                'Our team will contact you shortly',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: EdgeInsets.all(10),
                borderRadius: 10,
                duration: Duration(seconds: 3),
                icon: Icon(Iconsax.tick_circle, color: Colors.white),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 2,
            ),
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}