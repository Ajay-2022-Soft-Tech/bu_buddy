import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math' as math;

import '../../models/ride_details.dart';
import '../chat_screen/chat_screen.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class FindARideScreen extends StatefulWidget {
  const FindARideScreen({Key? key}) : super(key: key);

  @override
  State<FindARideScreen> createState() => _FindARideScreenState();
}

class _FindARideScreenState extends State<FindARideScreen> with SingleTickerProviderStateMixin {
  // Form and search controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Animation controllers
  late AnimationController _backgroundController;

  // State variables
  DateTime _selectedDate = DateTime.now();
  bool _isSearching = false;
  bool _hasSearched = false;
  List<RideDetails> _searchResults = [];
  List<String> _recentSearches = [];

  // Popular destinations (could be fetched from Firebase)
  final List<Map<String, String>> _popularDestinations = [
    {'name': 'Campus Main Gate', 'icon': '🏫'},
    {'name': 'City Center Mall', 'icon': '🛍️'},
    {'name': 'Railway Station', 'icon': '🚆'},
    {'name': 'Tech Park', 'icon': '🏢'},
    {'name': 'Airport', 'icon': '✈️'},
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Load recent searches from shared preferences or Firebase
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('searches')
            .doc('recent')
            .get();

        if (doc.exists && doc.data() != null) {
          final searches = List<String>.from(doc.data()!['searches'] ?? []);
          setState(() {
            _recentSearches = searches;
          });
        }
      }
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  Future<void> _saveRecentSearch(String from, String to) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Add to local state
        setState(() {
          // Remove if exists to avoid duplicates
          _recentSearches.removeWhere(
                  (search) => search.contains(from) && search.contains(to)
          );

          // Add at beginning of list
          _recentSearches.insert(0, '$from to $to');

          // Keep only last 5 searches
          if (_recentSearches.length > 5) {
            _recentSearches = _recentSearches.sublist(0, 5);
          }
        });

        // Save to Firebase
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('searches')
            .doc('recent')
            .set({
          'searches': _recentSearches,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
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

  Future<void> _searchRides() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final formattedDate = DateFormat('MMM d, yyyy').format(_selectedDate);

      // Save this search to recent searches
      await _saveRecentSearch(_fromController.text, _toController.text);

      // Create a real-time listener for rides
      final querySnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('isActive', isEqualTo: true)
          .get();

      // First filter for exact matches on date and locations
      List<RideDetails> exactMatches = querySnapshot.docs
          .map((doc) => RideDetails.fromMap(doc.data(), doc.id))
          .where((ride) =>
      ride.rideDate == formattedDate &&
          ride.pickupLocation.toLowerCase() == _fromController.text.toLowerCase() &&
          ride.destinationLocation.toLowerCase() == _toController.text.toLowerCase())
          .toList();

      // If no exact matches, search for partial matches
      if (exactMatches.isEmpty) {
        List<RideDetails> partialMatches = querySnapshot.docs
            .map((doc) => RideDetails.fromMap(doc.data(), doc.id))
            .where((ride) =>
        ride.rideDate == formattedDate &&
            (ride.pickupLocation.toLowerCase().contains(_fromController.text.toLowerCase()) ||
                _fromController.text.toLowerCase().contains(ride.pickupLocation.toLowerCase())) &&
            (ride.destinationLocation.toLowerCase().contains(_toController.text.toLowerCase()) ||
                _toController.text.toLowerCase().contains(ride.destinationLocation.toLowerCase())))
            .toList();

        setState(() {
          _searchResults = partialMatches;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = exactMatches;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });

      Get.snackbar(
        'Error',
        'Failed to search rides: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        borderRadius: 10,
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 500),
        icon: const Icon(Iconsax.warning_2, color: Colors.white),
      );
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
          'Find a Ride',
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
                      // Search heading and intro
                      _buildSearchHeading().animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: -20, end: 0),

                      const SizedBox(height: 20),

                      // Search form
                      _buildSearchForm().animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: 30, end: 0),

                      const SizedBox(height: 30),

                      // Popular destinations
                      if (!_hasSearched)
                        _buildPopularDestinations().animate()
                            .fadeIn(duration: 600.ms, delay: 300.ms),

                      // Recent searches
                      if (!_hasSearched && _recentSearches.isNotEmpty)
                        _buildRecentSearches().animate()
                            .fadeIn(duration: 600.ms, delay: 400.ms),

                      // Search results
                      if (_hasSearched)
                        _buildSearchResults(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (_isSearching)
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

  Widget _buildSearchHeading() {
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
              Iconsax.search_normal,
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
                  'Where are you going?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find and join rides offered by other students',
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

  Widget _buildSearchForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From field
          _buildAnimatedTextField(
            controller: _fromController,
            label: 'From',
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
            controller: _toController,
            label: 'To',
            hint: 'e.g. City Center Mall',
            icon: Iconsax.location_tick,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter destination';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Date selector
          _buildDateSelector(),

          const SizedBox(height: 25),

          // Search button
          _buildSearchButton(),
        ],
      ),
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
          'When do you want to travel?',
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
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
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

  Widget _buildSearchButton() {
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
        onPressed: _isSearching ? null : _searchRides,
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
            const Icon(Iconsax.search_normal),
            const SizedBox(width: 10),
            Text(
              'Search for Rides',
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

  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Destinations',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _popularDestinations.map((destination) {
              return GestureDetector(
                onTap: () {
                  // Set the destination as either from or to
                  if (_fromController.text.isEmpty) {
                    _fromController.text = destination['name']!;
                  } else if (_toController.text.isEmpty) {
                    _toController.text = destination['name']!;
                  } else {
                    // If both are filled, replace 'to'
                    _toController.text = destination['name']!;
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                      Text(
                        destination['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        destination['name']!,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_recentSearches.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches = [];
                  });
                  // Also clear in Firebase
                  final currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('searches')
                        .doc('recent')
                        .set({'searches': []});
                  }
                },
                child: Text(
                  'Clear',
                  style: GoogleFonts.poppins(
                    color: Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: _recentSearches.map((search) {
            final parts = search.split(' to ');
            final from = parts[0];
            final to = parts.length > 1 ? parts[1] : '';

            return ListTile(
              onTap: () {
                setState(() {
                  _fromController.text = from;
                  _toController.text = to;
                });
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.clock,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                from,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'to $to',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade400,
                ),
              ),
              trailing: Icon(
                Iconsax.arrow_right_3,
                color: Colors.grey.shade400,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return _buildEmptyResults();
    }

    return AnimationLimiter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Rides',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_searchResults.length} found',
                  style: GoogleFonts.poppins(
                    color: TColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 500),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildRideCard(_searchResults[index], index),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideDetails ride, int index) {
    // Calculate discount (for demo purposes)
    final random = math.Random(ride.id.hashCode);
    final discount = 30 + random.nextInt(21);
    final originalPrice = (ride.price * 100 / (100 - discount)).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade900.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Driver avatar
                CircleAvatar(
                  backgroundColor: TColors.primary.withOpacity(0.2),
                  child: Text(
                    ride.userName.isNotEmpty ? ride.userName[0].toUpperCase() : 'U',
                    style: GoogleFonts.poppins(
                      color: TColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.userName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Iconsax.calendar,
                            color: Colors.grey,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride.rideDate} at ${ride.rideTime}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Discount badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$discount% OFF',
                    style: GoogleFonts.poppins(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ride details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Route info with animation
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 40,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FROM',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ride.pickupLocation,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'TO',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            ride.destinationLocation,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Info chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(
                      icon: Iconsax.clock,
                      label: ride.rideTime,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      icon: Iconsax.people,
                      label: '${ride.availableSeats} seats',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 10),
                    _buildInfoChip(
                      icon: Iconsax.money,
                      label: '₹${ride.price.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Price and action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price with discount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price per seat',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '₹${ride.price.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '₹$originalPrice',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Join button
                    ElevatedButton(
                      onPressed: () => _joinRide(ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: TColors.primary.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.car, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Join Ride',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Lottie.network(
            'https://assets1.lottiefiles.com/packages/lf20_wnqlfojb.json',
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'No Rides Found',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no rides available for your search criteria. Try different locations or dates.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              _fromController.clear();
              _toController.clear();
              setState(() {
                _selectedDate = DateTime.now();
                _hasSearched = false;
              });
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('Try Different Search'),
            style: OutlinedButton.styleFrom(
              foregroundColor: TColors.primary,
              side: const BorderSide(color: TColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
              'https://assets9.lottiefiles.com/private_files/lf30_lndg7fhf.json',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            ShimmerText(
              baseColor: Colors.grey.shade700,
              highlightColor: Colors.grey.shade100,
              text: 'Searching for rides...',
              textStyle: GoogleFonts.poppins(
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

  void _joinRide(RideDetails ride) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You need to be logged in to join a ride',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Iconsax.warning_2, color: Colors.white),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey.shade900,
                Colors.grey.shade900.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
            border: Border.all(
              color: TColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: TColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.car5,
                  color: TColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Join Ride',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Do you want to join this ride with ${ride.userName}?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 20),

              // Ride details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade800,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildConfirmationDetail(
                      icon: Iconsax.location,
                      text: 'From: ${ride.pickupLocation}',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationDetail(
                      icon: Iconsax.location_tick,
                      text: 'To: ${ride.destinationLocation}',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationDetail(
                      icon: Iconsax.calendar,
                      text: 'Date: ${ride.rideDate}',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationDetail(
                      icon: Iconsax.clock,
                      text: 'Time: ${ride.rideTime}',
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationDetail(
                      icon: Iconsax.money,
                      text: 'Price: ₹${ride.price.toStringAsFixed(0)}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey.shade600,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Get.to(() => ChatScreen(
                          receiverId: ride.userId,
                          receiverName: ride.userName,
                          rideDetails: {
                            'from': ride.pickupLocation,
                            'to': ride.destinationLocation,
                            'time': ride.rideTime,
                            'date': ride.rideDate,
                            'price': '₹${ride.price.toStringAsFixed(0)}',
                            'seats': ride.availableSeats.toString(),
                            'student': ride.userName,
                            'studentId': ride.userId,
                          },
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 2,
                      ),
                      child: Text(
                        'Join Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDetail({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

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

class ShimmerText extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final String text;
  final TextStyle textStyle;

  const ShimmerText({
    Key? key,
    required this.baseColor,
    required this.highlightColor,
    required this.text,
    required this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
