// lib/features/car/screens/find_a_ride/find_a_ride.dart

import 'package:bu_buddy/features/car/screens/my_trips/my_trips.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/colors.dart';
import '../../controllers/car_home_controller.dart';
import '../available_rides/available_rides.dart';

class FindARideScreen extends StatefulWidget {
  const FindARideScreen({Key? key}) : super(key: key);

  @override
  State<FindARideScreen> createState() => _FindARideScreenState();
}

class _FindARideScreenState extends State<FindARideScreen> with SingleTickerProviderStateMixin {
  // Controllers
  final RideController _rideController = Get.find<RideController>();
  final FocusNode pickupFocusNode = FocusNode();
  final FocusNode destinationFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Map variables
  GoogleMapController? mapController;
  LatLng currentLocation = const LatLng(28.4506, 77.5842);

  // State variables
  int passengers = 1;
  bool isSearching = false;
  bool isPickupSearching = false;
  bool isDarkMode = false;

  // Search results
  final List<String> predefinedLocations = [
    'Bennett University', 'Greater Noida', 'Noida City Center',
    'Sector 62, Noida', 'Delhi Airport'
  ];
  List<String> searchResults = [];

  // Map styling for dark mode
  final String _darkMapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#212121"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#212121"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [{"color": "#2c2c2c"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#000000"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    // Initialize date/time
    if (_rideController.findDateController.text.isEmpty) {
      _rideController.findDateController.text = DateFormat('EEE, MMM d').format(DateTime.now());
    }

    // Initialize passenger count
    _rideController.findPassengersController.text = passengers.toString();

    // Setup animations
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800)
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    _animationController.forward();

    // Setup focus listeners
    pickupFocusNode.addListener(_handlePickupFocus);
    destinationFocusNode.addListener(_handleDestinationFocus);

    // Get user location
    _getCurrentLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _setMapStyle();
  }

  @override
  void dispose() {
    pickupFocusNode.removeListener(_handlePickupFocus);
    destinationFocusNode.removeListener(_handleDestinationFocus);
    pickupFocusNode.dispose();
    destinationFocusNode.dispose();
    _animationController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  // Handle focus changes
  void _handlePickupFocus() {
    setState(() {
      isPickupSearching = pickupFocusNode.hasFocus;
      if (isPickupSearching) _searchLocation(_rideController.findPickupController.text, true);
    });
  }

  void _handleDestinationFocus() {
    setState(() {
      isPickupSearching = !destinationFocusNode.hasFocus;
      if (destinationFocusNode.hasFocus) _searchLocation(_rideController.findDestinationController.text, false);
    });
  }

  // Map styling
  void _setMapStyle() {
    if (mapController != null) {
      mapController!.setMapStyle(isDarkMode ? _darkMapStyle : null);
    }
  }

  // Location services
  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => currentLocation = LatLng(position.latitude, position.longitude));
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLocation, zoom: 15.0),
        ),
      );
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  // Search functions
  void _searchLocation(String query, bool isPickup) {
    setState(() {
      isSearching = query.isNotEmpty;
      searchResults = predefinedLocations
          .where((location) => location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectLocation(String location, bool isPickup) {
    setState(() {
      if (isPickup) {
        _rideController.findPickupController.text = location;
        pickupFocusNode.unfocus();
      } else {
        _rideController.findDestinationController.text = location;
        destinationFocusNode.unfocus();
      }
      isSearching = false;
    });
  }

  // Search for rides and navigate to results
  void _findRides() async {
    if (_rideController.findPickupController.text.isEmpty ||
        _rideController.findDestinationController.text.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please provide pickup and destination locations',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Update passengers count
    _rideController.findPassengersController.text = passengers.toString();

    // Show loading
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    // Search for rides
    await _rideController.searchRides();

    // Close loading dialog
    Get.back();

    // Navigate to results
    Get.to(() => MyTripsScreen());
  }

  // UI helper properties
  Color get _backgroundColor => isDarkMode ? const Color(0xFF121212) : Colors.grey.shade50;
  Color get _cardColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _textColor => isDarkMode ? Colors.white : Colors.black87;
  Color get _secondaryTextColor => isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
  Color get _dividerColor => isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
  Color get _shadowColor => isDarkMode ? Colors.black54 : Colors.black.withOpacity(0.07);
  List<BoxShadow> get _cardShadow => [
    BoxShadow(color: _shadowColor, spreadRadius: 0, blurRadius: 12, offset: const Offset(0, 4))
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Find a Ride",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 24),

              // Location Fields
              _buildLocationField(
                controller: _rideController.findPickupController,
                hint: "Enter pickup location",
                icon: Icons.location_on,
                iconColor: TColors.primary,
                focusNode: pickupFocusNode,
              ),
              const SizedBox(height: 16),

              _buildLocationField(
                controller: _rideController.findDestinationController,
                hint: "Enter destination",
                icon: Icons.flag,
                iconColor: Colors.amber.shade700,
                focusNode: destinationFocusNode,
                isPickup: false,
              ),
              const SizedBox(height: 8),

              // Search Results
              if (isSearching) _buildSearchResults(),
              const SizedBox(height: 16),

              // Ride Details Section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "Ride Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ),

              // Date and Passenger Selection
              _buildDateTimeSelectors(),
              const SizedBox(height: 16),
              _buildPassengerSelection(),
              const SizedBox(height: 24),

              // Map Section
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "Your Route",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ),
              _buildMap(),
              const SizedBox(height: 24),

              // Find Ride Button
              _buildFindRideButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF2C3E50), const Color(0xFF1E3C72)]
              : [TColors.primary.withOpacity(0.8), TColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : TColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Where would you like to go?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Find the perfect ride for your journey",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required FocusNode focusNode,
    bool isPickup = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (text) => _searchLocation(text, isPickup),
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: _textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _secondaryTextColor, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, color: iconColor, size: 22),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: _secondaryTextColor),
            onPressed: () {
              controller.clear();
              setState(() => isSearching = false);
            },
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: _cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!isSearching || searchResults.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: searchResults.length > 5 ? 5 : searchResults.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, thickness: 1, indent: 20, endIndent: 20, color: _dividerColor,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  isPickupSearching ? Icons.location_on : Icons.flag,
                  color: isPickupSearching ? TColors.primary : Colors.amber.shade700,
                ),
                title: Text(
                  searchResults[index],
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: _textColor),
                ),
                subtitle: Text(
                  "Tap to select",
                  style: TextStyle(fontSize: 12, color: _secondaryTextColor),
                ),
                onTap: () => _selectLocation(searchResults[index], isPickupSearching),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelectors() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: TColors.primary,
                      brightness: isDarkMode ? Brightness.dark : Brightness.light,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (pickedDate != null) {
                setState(() {
                  _rideController.findDateController.text = DateFormat('EEE, MMM d').format(pickedDate);
                });
              }
            },
            child: _buildSelectionContainer(
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: TColors.primary, size: 14),
                  const SizedBox(width: 14),
                  Text(
                    _rideController.findDateController.text,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: _textColor),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_drop_down, color: _secondaryTextColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionContainer({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildPassengerSelection() {
    return _buildSelectionContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Passengers", style: TextStyle(color: _secondaryTextColor, fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.people_alt_rounded, color: Colors.blue.shade700, size: 22),
              const SizedBox(width: 14),
              Text(
                "$passengers ${passengers == 1 ? 'passenger' : 'passengers'}",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: _textColor),
              ),
              const Spacer(),
              Row(
                children: [
                  _passengerButton(Icons.remove, passengers > 1, () {
                    if (passengers > 1) setState(() => passengers--);
                  }),
                  Text(
                    "$passengers",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: _textColor),
                  ),
                  _passengerButton(Icons.add, passengers < 5, () {
                    if (passengers < 5) setState(() => passengers++);
                  }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _passengerButton(IconData icon, bool isEnabled, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isEnabled ? TColors.primary.withOpacity(0.1) :
          (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? TColors.primary :
          (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400),
          size: 16,
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _shadowColor, blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: currentLocation, zoom: 14.0),
              onMapCreated: (controller) {
                mapController = controller;
                _setMapStyle();
              },
              markers: {
                Marker(
                  markerId: const MarkerId("pickup"),
                  position: currentLocation,
                  infoWindow: const InfoWindow(title: "Pickup"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _getCurrentLocation,
                backgroundColor: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
                child: Icon(Icons.my_location, color: TColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindRideButton() {
    return GestureDetector(
      onTap: _findRides,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [TColors.primary.withOpacity(0.9), TColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Text(
              'Find a Ride',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}