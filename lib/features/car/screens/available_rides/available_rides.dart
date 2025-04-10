import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import '../../models/ride_details.dart';  // Model for ride details

class TripsScreen extends StatefulWidget {
  @override
  _TripsScreenState createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _loadingAnimation;
  int _selectedRideIndex = -1;
  bool _isLoading = true;
  bool _showLoadingScreen = true;

  @override
  void initState() {
    super.initState();

    // Animation controller for floating action button
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Animation controller for loading animation
    _loadingAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    // Create a curved animation for the loading progress
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the loading animation
    _loadingAnimationController.repeat();

    // Start loading data process
    _loadData();
  }

  // Method to simulate the loading process
  Future<void> _loadData() async {
    // Show loading animation for at least 2 seconds for better UX
    await Future.delayed(Duration(seconds: 2));

    // Fetch the actual data
    try {
      // This will be a background operation
      await _fetchRides();

      if (mounted) {
        // After loading is complete, fade out loading screen
        setState(() {
          _isLoading = false;
        });

        // Wait a moment before showing the content with animation
        await Future.delayed(Duration(milliseconds: 300));

        if (mounted) {
          setState(() {
            _showLoadingScreen = false;
          });

          // Animate in the floating action button
          _animationController.forward();
        }
      }
    } catch (error) {
      // Handle any errors during loading
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showLoadingScreen = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  // Fetch ride details from Firestore
  Future<List<RideDetails>> _fetchRides() async {
    final snapshot = await FirebaseFirestore.instance.collection('rides').get();
    return snapshot.docs.map((doc) {
      return RideDetails(
        pickupLocation: doc['pickupLocation'],
        destinationLocation: doc['destinationLocation'],
        rideDate: doc['rideDate'],
        rideTime: doc['rideTime'],
        availableSeats: doc['availableSeats'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Available Rides",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2C63FF), Color(0xFF3F8CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.filter, color: Colors.white),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          _showLoadingScreen
              ? Container() // Hidden initially
              : FutureBuilder<List<RideDetails>>(
            future: _fetchRides(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildSimpleLoadingView();
              }

              if (snapshot.hasError) {
                return _buildErrorView("Error fetching rides");
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyView();
              }

              final rides = snapshot.data!;
              return AnimationLimiter(
                child: Container(
                  padding: EdgeInsets.only(top: 16),
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 90),
                    physics: BouncingScrollPhysics(),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildRideCard(ride, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Animated loading screen overlay
          if (_showLoadingScreen)
            AnimatedOpacity(
              opacity: _isLoading ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: _buildAnimatedLoadingScreen(),
            ),
        ],
      ),
      floatingActionButton: _showLoadingScreen
          ? null
          : AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _animationController.value,
            child: FloatingActionButton.extended(
              onPressed: () {
                // Navigate to create new ride
                _showAddRideBottomSheet(context);
              },
              label: Text("Add Ride"),
              icon: Icon(Icons.add),
              backgroundColor: Color(0xFF2C63FF),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLoadingScreen() {
    return Container(
      color: Color(0xFFF5F7FB),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Car animation
          Lottie.network(
            'https://assets9.lottiefiles.com/packages/lf20_XyoSty.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 40),

          // Loading text with color animation
          TweenAnimationBuilder<Color?>(
            duration: Duration(seconds: 2),
            tween: ColorTween(begin: Color(0xFF2C63FF), end: Color(0xFF3F8CFF)),
            builder: (context, color, child) {
              return Text(
                "Finding Available rides...",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              );
            },
          ),

          SizedBox(height: 30),

          // Animated progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: AnimatedBuilder(
              animation: _loadingAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    // Custom animated progress bar
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              Container(
                                width: constraints.maxWidth * _loadingAnimation.value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF2C63FF), Color(0xFF3F8CFF)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 15),

                    // Loading status text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Connecting to Firebase",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${(_loadingAnimation.value * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C63FF),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 60),

          // Decorative elements
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPulsingDot(0),
              SizedBox(width: 12),
              _buildPulsingDot(300),
              SizedBox(width: 12),
              _buildPulsingDot(600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.5, end: 1.0),
      duration: Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8 * value,
          height: 8 * value,
          decoration: BoxDecoration(
            color: Color(0xFF2C63FF).withOpacity(1.5 - value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSimpleLoadingView() {
    return Center(
      child: CircularProgressIndicator(
        color: Color(0xFF2C63FF),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets10.lottiefiles.com/packages/lf20_kk62um5u.json',
            width: 200,
            height: 200,
          ),
          SizedBox(height: 20),
          Text(
            "Finding available rides...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _showLoadingScreen = true;
                _loadData();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2C63FF),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text("Retry", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.network(
            'https://assets5.lottiefiles.com/packages/lf20_hl5n0bwb.json',
            width: 250,
            height: 250,
          ),
          Text(
            "No rides available",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Be the first to offer a ride!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              _showAddRideBottomSheet(context);
            },
            icon: Icon(Icons.directions_car),
            label: Text("Create Ride"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2C63FF),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideDetails ride, int index) {
    final bool isExpanded = _selectedRideIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRideIndex = isExpanded ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: EdgeInsets.all(isExpanded ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              spreadRadius: isExpanded ? 3 : 1,
              blurRadius: isExpanded ? 10 : 5,
              offset: Offset(0, 3),
            ),
          ],
          border: isExpanded
              ? Border.all(color: Color(0xFF2C63FF), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Iconsax.car, color: Color(0xFF2C63FF), size: 28),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ride.rideDate} · ${ride.rideTime}',
                        style: TextStyle(
                          color: Color(0xFF2C63FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${ride.availableSeats} seats available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2C63FF),
                    size: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            _buildLocationRow(Iconsax.location, ride.pickupLocation, "PICKUP"),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: 30,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      height: 30,
                      width: 2,
                      child: CustomPaint(
                        painter: DashedLinePainter(
                          color: Color(0xFF2C63FF),
                          strokeWidth: 2,
                          dashWidth: 4,
                          dashSpace: 3,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            _buildLocationRow(Iconsax.location_tick, ride.destinationLocation, "DESTINATION"),
            AnimatedSize(
              duration: Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              child: Container(
                height: isExpanded ? null : 0,
                child: isExpanded
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    Divider(color: Colors.grey[200], thickness: 1),
                    SizedBox(height: 15),
                    _buildDriverInfo(),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Show ride details
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Color(0xFF2C63FF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "View Details",
                              style: TextStyle(
                                color: Color(0xFF2C63FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Book ride
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2C63FF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Book Ride",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String location, String label) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF2C63FF), size: 20),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                location,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF2C63FF), width: 2),
            image: DecorationImage(
              image: NetworkImage(
                'https://randomuser.me/api/portraits/men/32.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "John Smith",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "4.8",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    " (234 rides)",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // Show driver profile
          },
          icon: Icon(Iconsax.user, color: Color(0xFF2C63FF)),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Filter Rides",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 30),
              // Filter content here
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRideBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Add New Ride",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 30),
              // Form content here
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for dashed line
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}