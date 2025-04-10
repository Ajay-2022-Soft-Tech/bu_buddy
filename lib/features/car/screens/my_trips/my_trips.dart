import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class Trip {
  final String userName;
  final String userProfileImage;
  final String pickupLocation;
  final String destination;
  final String date;
  final String time;
  final int passengers;
  final String status; // 'success' or 'failure'
  final double price; // Added price for trips

  Trip({
    required this.userName,
    required this.userProfileImage,
    required this.pickupLocation,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengers,
    required this.status,
    required this.price,
  });
}

class MyTripsScreen extends StatefulWidget {
  MyTripsScreen({Key? key}) : super(key: key);

  @override
  _MyTripsScreenState createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final RxInt _selectedTabIndex = 0.obs;
  bool _isLoading = true;

  // Animation controller for loading effect
  late AnimationController _loadingController;

  final List<Trip> allTrips = [
    Trip(
      userName: 'Rohit',
      userProfileImage: 'assets/logos/google-icon.png',
      pickupLocation: 'University Campus',
      destination: 'Library',
      date: '10 Apr 2025',
      time: '10:00 AM',
      passengers: 2,
      status: 'success',
      price: 45.0,
    ),
    Trip(
      userName: 'Ajay',
      userProfileImage: 'assets/logos/facebook-icon.png',
      pickupLocation: 'Hostel A',
      destination: 'Cafeteria',
      date: '08 Apr 2025',
      time: '2:00 PM',
      passengers: 3,
      status: 'failure',
      price: 30.0,
    ),
    Trip(
      userName: 'Priya',
      userProfileImage: 'assets/logos/google-icon.png',
      pickupLocation: 'Main Gate',
      destination: 'Sports Complex',
      date: '05 Apr 2025',
      time: '4:30 PM',
      passengers: 1,
      status: 'success',
      price: 25.0,
    ),
    Trip(
      userName: 'Sneha',
      userProfileImage: 'assets/logos/facebook-icon.png',
      pickupLocation: 'Department Building',
      destination: 'Shopping Mall',
      date: '03 Apr 2025',
      time: '11:15 AM',
      passengers: 4,
      status: 'success',
      price: 60.0,
    ),
    Trip(
      userName: 'Rahul',
      userProfileImage: 'assets/logos/google-icon.png',
      pickupLocation: 'Bus Stand',
      destination: 'University Campus',
      date: '29 Mar 2025',
      time: '9:00 AM',
      passengers: 2,
      status: 'failure',
      price: 35.0,
    ),
  ];

  // Filtered lists
  late RxList<Trip> upcomingTrips;
  late RxList<Trip> completedTrips;
  late RxList<Trip> cancelledTrips;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _selectedTabIndex.value = _tabController.index;
    });

    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    // Simulate loading data
    Future.delayed(Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
        _loadingController.stop();
      });
    });

    // Initialize filtered lists
    upcomingTrips = allTrips.where((trip) =>
    trip.date.compareTo('05 Apr 2025') >= 0).toList().obs;

    completedTrips = allTrips.where((trip) =>
    trip.status == 'success' && trip.date.compareTo('05 Apr 2025') < 0).toList().obs;

    cancelledTrips = allTrips.where((trip) =>
    trip.status == 'failure').toList().obs;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            TColors.primary.withOpacity(0.9),
            TColors.primary.withOpacity(0.6),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 0.5],
        ),
      ),
      child: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              _buildStatisticsBar(),
              _buildSliverPersistentHeader(innerBoxIsScrolled),
            ];
          },
          body: _isLoading ? _buildLoadingView() : _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loadingController,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.directions_car_filled,
                    color: TColors.primary,
                    size: 50,
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).scale(
                    duration: GetNumUtils(1).seconds,
                    curve: Curves.easeInOut,
                    begin: Offset(1, 1),
                    end: Offset(1.2, 1.2),
                  ).then()
                      .scale(
                    duration: GetNumUtils(1).seconds,
                    curve: Curves.easeInOut,
                    begin: Offset(1.2, 1.2),
                    end: Offset(1, 1),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            'Loading your trips...',
            style: TextStyle(
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.w600,
              color: TColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'My Trips',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.3),
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                TColors.primary.withOpacity(0.7),
                TColors.primary,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: 10,
                child: Opacity(
                  opacity: 0.4,
                  child: Icon(
                    Icons.directions_car_filled,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.filter_list_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            // Filter functionality
          },
        ),
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            // Search functionality
          },
        ),
      ],
    );
  }

  Animate _buildStatisticsBar() {
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 15),
          children: [
            _buildStatCard(
              'Total Trips',
              allTrips.length.toString(),
              Icons.timeline_rounded,
              Colors.blue.shade700,
            ),
            _buildStatCard(
              'Completed',
              completedTrips.length.toString(),
              Icons.check_circle_rounded,
              Colors.green.shade700,
            ),
            _buildStatCard(
              'Upcoming',
              upcomingTrips.length.toString(),
              Icons.event_available_rounded,
              Colors.orange.shade700,
            ),
            _buildStatCard(
              'Cancelled',
              cancelledTrips.length.toString(),
              Icons.cancel_rounded,
              Colors.red.shade700,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(begin: 20, end: 0);
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 130,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: TColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: TColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  SliverPersistentHeader _buildSliverPersistentHeader(bool innerBoxIsScrolled) {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: TColors.primary,
          unselectedLabelColor: TColors.textSecondary,
          indicatorColor: TColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          labelStyle: TextStyle(
            fontSize: TSizes.fontSizeMd,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: TSizes.fontSizeMd,
            fontWeight: FontWeight.w500,
          ),
          tabs: [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildTripList(upcomingTrips),
        _buildTripList(completedTrips),
        _buildTripList(cancelledTrips),
      ],
    );
  }

  Widget _buildTripList(RxList<Trip> trips) {
    return Obx(() => trips.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        return _buildTripCard(trips[index], index);
      },
    ));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_filled_outlined,
              size: 60,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No trips found',
            style: TextStyle(
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Your trips will appear here',
            style: TextStyle(
              fontSize: TSizes.fontSizeMd,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(Trip trip, int index) {
    bool isSuccess = trip.status == 'success';
    Color statusColor = isSuccess ? Colors.green.shade600 : Colors.red.shade600;
    String statusText = isSuccess ? 'Completed' : 'Cancelled';

    return Container(
      margin: EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: statusColor,
                  width: 5,
                ),
              ),
            ),
            child: Column(
              children: [
                // Header with user info
                ListTile(
                  leading: Hero(
                    tag: 'profile_${trip.userName}_$index',
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TColors.primary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          trip.userProfileImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    trip.userName,
                    style: TextStyle(
                      fontSize: TSizes.fontSizeLg,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${trip.date} • ${trip.time}',
                    style: TextStyle(
                      color: TColors.textSecondary,
                    ),
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.fontSizeSm,
                      ),
                    ),
                  ),
                ),

                Divider(),

                // Trip details
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 14),
                          Container(
                            height: 30,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          Icon(Icons.location_on, color: Colors.red, size: 14),
                        ],
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trip.pickupLocation,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 20),
                            Text(
                              trip.destination,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional info
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.people_alt_outlined,
                        '${trip.passengers} Passenger${trip.passengers > 1 ? 's' : ''}',
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildInfoItem(
                        Icons.payments_outlined,
                        '₹${trip.price.toStringAsFixed(0)}',
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          // View details action
                        },
                        icon: Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: TColors.primary,
                        ),
                        label: Text(
                          'Details',
                          style: TextStyle(
                            color: TColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(10, 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 400.ms, delay: (index * 100).ms)
        .moveY(begin: 20, end: 0);
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: TColors.textSecondary,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: TColors.textSecondary,
            fontSize: TSizes.fontSizeSm,
          ),
        ),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height + 8;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 8;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}