import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../models/ride_details.dart';
import '../verify_ride_screen/verify_ride_screen.dart';
import '../../../../../utils/constants/colors.dart';

class PublishRideScreen extends StatefulWidget {
  const PublishRideScreen({Key? key}) : super(key: key);

  @override
  State<PublishRideScreen> createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _backgroundController;

  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  // State variables
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _availableSeats = 2;
  double _price = 50.0;
  bool _isLoading = false;

  // Popular locations suggestion
  final List<String> _popularLocations = [
    'Campus Main Gate',
    'City Center Mall',
    'Railway Station',
    'Tech Park',
    'Airport',
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: TColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: Colors.grey.shade900,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: TColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: Colors.grey.shade900,
            ),
            dialogBackgroundColor: Colors.grey.shade900,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _publishRide() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You need to be logged in to publish a ride',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Get user data from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      String userName = currentUser.displayName ?? 'User';
      String userAvatar = currentUser.photoURL ?? '';

      if (userDoc.exists) {
        final userData = userDoc.data();
        userName = userData?['name'] ?? userData?['firstName'] ?? userName;
        userAvatar = userData?['avatar'] ?? userData?['photoURL'] ?? userAvatar;
      }

      final rideDetails = RideDetails(
        id: '', // Will be set after Firebase insertion
        userId: currentUser.uid,
        userName: userName,
        userAvatar: userAvatar,
        pickupLocation: _pickupController.text,
        destinationLocation: _destinationController.text,
        rideDate: DateFormat('MMM d, yyyy').format(_selectedDate),
        rideTime: _selectedTime.format(context),
        availableSeats: _availableSeats,
        price: _price,
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Navigate to verification screen
      Get.to(() => RideVerificationScreen(rideDetails: rideDetails));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to prepare ride: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.arrow_left,
              color: Colors.white,
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Publish a Ride',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header section
                      _buildHeader().animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -20, end: 0),

                      const SizedBox(height: 30),

                      // Route information
                      _buildRouteSection().animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 30, end: 0),

                      const SizedBox(height: 30),

                      // Schedule section
                      _buildScheduleSection().animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 30, end: 0),

                      const SizedBox(height: 30),

                      // Ride details section
                      _buildRideDetailsSection().animate()
                          .fadeIn(duration: 600.ms, delay: 600.ms)
                          .slideY(begin: 30, end: 0),

                      const SizedBox(height: 40),

                      // Publish button
                      _buildPublishButton().animate()
                          .fadeIn(duration: 600.ms, delay: 800.ms)
                          .slideY(begin: 30, end: 0),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isLoading)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            animation: _backgroundController.value,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.primary.withOpacity(0.2),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.car,
              color: TColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Publish Your Ride',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Share your journey and help others commute',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Information',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),

        // Popular locations chips
        _buildPopularLocations(),

        const SizedBox(height: 20),

        // From field
        _buildAnimatedTextField(
          controller: _pickupController,
          label: 'Pickup Location',
          hint: 'e.g. Campus Main Gate',
          icon: Iconsax.location,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter pickup location';
            }
            return null;
          },
        ),

        const SizedBox(height: 15),

        // Animated route line
        Center(
          child: Container(
            height: 30,
            width: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        const SizedBox(height: 15),

        // To field
        _buildAnimatedTextField(
          controller: _destinationController,
          label: 'Destination',
          hint: 'e.g. City Center Mall',
          icon: Iconsax.location_tick,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter destination';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPopularLocations() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _popularLocations.map((location) {
          return GestureDetector(
            onTap: () {
              if (_pickupController.text.isEmpty) {
                setState(() => _pickupController.text = location);
              } else if (_destinationController.text.isEmpty) {
                setState(() => _destinationController.text = location);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade700,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getLocationIcon(location),
                    color: Colors.grey.shade300,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    location,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getLocationIcon(String location) {
    if (location.contains('Campus')) return Iconsax.building;
    if (location.contains('Mall')) return Iconsax.shop;
    if (location.contains('Station')) return Iconsax.star;
    if (location.contains('Park')) return Iconsax.building_4;
    if (location.contains('Airport')) return Iconsax.airplane;
    return Iconsax.location;
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),

        // Date and time selectors
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildTimeSelector(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRideDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ride Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),

        // Seats selector
        _buildSeatsSelector(),

        const SizedBox(height: 20),

        // Price selector
        _buildPriceSelector(),
      ],
    );
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(icon, color: TColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade700,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade700,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade800.withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final formattedDate = DateFormat('MMM d, yyyy').format(_selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade700,
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, color: TColors.primary, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    final formattedTime = _selectedTime.format(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade700,
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.clock, color: TColors.primary, size: 20),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: TColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: TColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatsSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.people,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Available Seats',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_availableSeats ${_availableSeats == 1 ? 'seat' : 'seats'} available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  _buildSeatButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (_availableSeats > 1) {
                        setState(() {
                          _availableSeats--;
                        });
                      }
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _availableSeats.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildSeatButton(
                    icon: Icons.add,
                    onTap: () {
                      if (_availableSeats < 6) {
                        setState(() {
                          _availableSeats++;
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildPriceSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.money,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'Price per Seat',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.money,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${_price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'per seat',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.green.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.green.withOpacity(0.1),
              valueIndicatorColor: Colors.green,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: _price,
              min: 10,
              max: 500,
              divisions: 49,
              label: '₹${_price.toStringAsFixed(0)}',
              onChanged: (value) {
                setState(() {
                  _price = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹10',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              Text(
                '₹500',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColors.primary,
            TColors.primary.withBlue(255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: TColors.primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _publishRide,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.car),
            const SizedBox(width: 10),
            Text(
              'Publish Ride',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              'https://assets2.lottiefiles.com/packages/lf20_UCwEVX.json',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Text(
              'Preparing your ride...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Background painter class for animated background
class BackgroundPainter extends CustomPainter {
  final double animation;

  BackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Base gradient background
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF101010),
        const Color(0xFF1A1A1A),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw animated particles
    _drawParticles(canvas, size, paint);

    // Draw animated waves at bottom
    _drawWaves(canvas, size, paint);
  }

  void _drawParticles(Canvas canvas, Size size, Paint paint) {
    final random = math.Random(42);

    // Different color particles
    final colors = [
      Colors.blue.withOpacity(0.15),
      Colors.purple.withOpacity(0.1),
      Colors.cyan.withOpacity(0.1),
    ];

    for (int i = 0; i < 40; i++) {
      final xPos = size.width * random.nextDouble();
      final yPos = size.height * random.nextDouble();
      final radius = 1.0 + 3.0 * math.sin(animation * 2 * math.pi + i);

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius,
        paint,
      );
    }

    // Draw larger glowing particles
    for (int i = 0; i < 10; i++) {
      final xPos = size.width * random.nextDouble();
      final yPos = size.height * random.nextDouble();
      final baseRadius = 3.0 + random.nextDouble() * 8;
      final radius = baseRadius + 3.0 * math.sin(animation * 2 * math.pi + i);

      // Glow effect
      final color = colors[i % colors.length];
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(
        Offset(xPos, yPos),
        radius * 2,
        glowPaint,
      );

      // Core
      paint.color = color.withOpacity(0.7);
      canvas.drawCircle(
        Offset(xPos, yPos),
        radius,
        paint,
      );
    }
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    final animValue = animation * 2 * math.pi;

    // First wave
    paint.color = Colors.blue.withOpacity(0.05);
    var path = Path();
    path.moveTo(0, size.height * 0.85);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.85 + 0.04 * math.sin(x / 50 + animValue));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    paint.color = Colors.purple.withOpacity(0.05);
    path = Path();
    path.moveTo(0, size.height * 0.9);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height * (0.9 + 0.03 * math.sin(x / 40 - animValue * 0.8));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
