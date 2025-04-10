import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class FindARideScreen extends StatefulWidget {
  const FindARideScreen({super.key});

  @override
  State<FindARideScreen> createState() => _FindARideScreenState();
}

class _FindARideScreenState extends State<FindARideScreen> with SingleTickerProviderStateMixin {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  int passengers = 1;
  String selectedDate = DateFormat('EEE, MMM d').format(DateTime.now());
  String selectedTime = DateFormat('h:mm a').format(DateTime.now());
  GoogleMapController? mapController;
  LatLng currentLocation = LatLng(28.4506, 77.5842);
  LatLng pickupLocation = LatLng(28.4506, 77.5842);
  LatLng destinationLocation = LatLng(28.4506, 77.5842);

  List<String> predefinedLocations = [
    'Bennett University',
    'Greater Noida',
    'Noida City Center',
    'Sector 62, Noida',
    'Delhi Airport'
  ];
  List<String> searchResults = [];
  bool isSearching = false;
  bool isPickupSearching = false;
  FocusNode pickupFocusNode = FocusNode();
  FocusNode destinationFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Function to get the current location

  void _getCurrentLocation() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update current location
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Animate camera to current location
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      print("Error getting current location: $e");
      // Show error message to user
    }
  }
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Setup focus node listeners to show/hide search results
    pickupFocusNode.addListener(() {
      setState(() {
        isPickupSearching = pickupFocusNode.hasFocus;
        if (pickupFocusNode.hasFocus) {
          _searchLocation(pickupController.text, true);
        }
      });
    });

    destinationFocusNode.addListener(() {
      setState(() {
        isPickupSearching = !destinationFocusNode.hasFocus;
        if (destinationFocusNode.hasFocus) {
          _searchLocation(destinationController.text, false);
        }
      });
    });

    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    pickupFocusNode.dispose();
    destinationFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Function to filter and show locations when the user searches
  void _searchLocation(String query, bool isPickup) {
    setState(() {
      isSearching = query.isNotEmpty;
      searchResults = predefinedLocations
          .where((location) => location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Function to update the selected location and close search results
  void _selectLocation(String location, bool isPickup) {
    setState(() {
      if (isPickup) {
        pickupController.text = location;
        pickupFocusNode.unfocus();
      } else {
        destinationController.text = location;
        destinationFocusNode.unfocus();
      }
      isSearching = false;
    });
  }

  // Build the location input field with customized appearance
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (text) => _searchLocation(text, isPickup),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade600),
            onPressed: () {
              controller.clear();
              setState(() {
                isSearching = false;
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }

  // Build the search results with nice animation
  Widget _buildSearchResults() {
    if (!isSearching || searchResults.isEmpty) return SizedBox.shrink();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: searchResults.length > 5 ? 5 : searchResults.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  isPickupSearching ? Icons.location_on : Icons.flag,
                  color: isPickupSearching ? TColors.primary : Colors.amber.shade700,
                ),
                title: Text(
                  searchResults[index],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  "Tap to select",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  _selectLocation(searchResults[index], isPickupSearching);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              );
            },
          ),
        ),
      ),
    );
  }

  // Date selection container with beautiful design
  Widget _buildDateSelection() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: TColors.primary,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: TColors.primary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = DateFormat('EEE, MMM d').format(pickedDate);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              color: TColors.primary,
              size: 22,
            ),
            SizedBox(width: 14),
            Text(
              selectedDate,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  // Time selection container with beautiful design
  Widget _buildTimeSelection() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: TColors.primary,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: TColors.primary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedTime != null) {
          setState(() {
            selectedTime = pickedTime.format(context);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: Colors.amber.shade700,
              size: 22,
            ),
            SizedBox(width: 14),
            Text(
              selectedTime,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  // Custom passenger selection with beautiful design
  Widget _buildPassengerSelection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Passengers",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: Colors.blue.shade700,
                size: 22,
              ),
              SizedBox(width: 14),
              Text(
                "$passengers ${passengers == 1 ? 'passenger' : 'passengers'}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (passengers > 1) {
                        setState(() {
                          passengers--;
                        });
                      }
                    },
                    icon: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: passengers > 1 ? TColors.primary.withOpacity(0.1) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove,
                        color: passengers > 1 ? TColors.primary : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ),
                  Text(
                    "$passengers",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (passengers < 5) {
                        setState(() {
                          passengers++;
                        });
                      }
                    },
                    icon: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: passengers < 5 ? TColors.primary.withOpacity(0.1) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: passengers < 5 ? TColors.primary : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Google Map with rounded corners and markers
  Widget _buildMap() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // Apply custom map style if needed
                // controller.setMapStyle(mapStyle);
              },
              markers: {
                Marker(
                  markerId: MarkerId("pickup"),
                  position: pickupLocation,
                  infoWindow: InfoWindow(title: "Pickup"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  draggable: true, // Make marker draggable
                  onDragEnd: (newPosition) {
                    // Update pickup location when marker is dragged
                    setState(() {
                      pickupLocation = newPosition;
                    });
                  },
                ),
                if (destinationController.text.isNotEmpty)
                  Marker(
                    markerId: MarkerId("destination"),
                    position: destinationLocation,
                    infoWindow: InfoWindow(title: "Destination"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    draggable: true, // Make marker draggable
                    onDragEnd: (newPosition) {
                      // Update destination location when marker is dragged
                      setState(() {
                        destinationLocation = newPosition;
                      });
                    },
                  ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true, // Show zoom controls
              mapToolbarEnabled: true, // Enable map toolbar
              rotateGesturesEnabled: true, // Enable rotation gestures
              scrollGesturesEnabled: true, // Enable scrolling/panning
              zoomGesturesEnabled: true, // Enable pinch to zoom
              tiltGesturesEnabled: true, // Enable tilt gestures
              compassEnabled: true, // Show compass when map is rotated
              onCameraMove: (CameraPosition position) {
                // Optional: track camera position changes
                // You can use this to update state variables if needed
              },
              onTap: (LatLng position) {
                // Optional: handle map taps
                // For example, you could add a new marker or set a destination
              },
            ),
            // Floating locate me button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.my_location,
                  color: TColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Make sure to implement this method to center the map on current location


// Add this method to allow moving to different locations
  void moveToLocation(LatLng location, {double zoom = 14.0}) {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: zoom,
        ),
      ),
    );
  }
  // Enhanced find a ride button
  Widget _buildFindRideButton() {
    return GestureDetector(
      onTap: () {
        if (pickupController.text.isEmpty || destinationController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Please select pickup and destination locations"),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          // Implement find ride functionality
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildSearchingSheet(),
          );
        }
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              TColors.primary.withOpacity(0.9),
              TColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: TColors.primary.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: Colors.white,
              size: 22,
            ),
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

  // Searching sheet animation - Fixed without AnimatedTextKit
  Widget _buildSearchingSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(bottom: 24),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: TColors.primary.withOpacity(0.1),
            child: Icon(
              Icons.search,
              color: TColors.primary,
              size: 40,
            ),
          ),
          SizedBox(height: 24),
          // Simple animated dots approach without external package
          _buildAnimatedSearchingText(),
          SizedBox(height: 16),
          Text(
            'Please wait while we find the best rides for you',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 32),
          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
          ),
          Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom animated searching text without external package
  Widget _buildAnimatedSearchingText() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(seconds: 2),
      builder: (context, value, child) {
        return Text(
          'Searching for rides${_getDots(value)}',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        );
      },
      onEnd: () {
        setState(() {
          // Trigger rebuild to restart the animation
        });
      },
    );
  }

  // Helper method to generate animated dots
  String _getDots(double value) {
    if (value < 0.25) return '.';
    if (value < 0.5) return '..';
    if (value < 0.75) return '...';
    return '';
  }

  // Main build method with improved UI components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Find a Ride",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: TColors.primary,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Custom background with subtle pattern
          Positioned.fill(
            child: Container(
              color: Colors.grey.shade50,
            ),
          ),

          // Main content with fade-in animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero section
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 24),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TColors.primary.withOpacity(0.8),
                          TColors.primary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
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
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pickup location field
                  _buildLocationField(
                    controller: pickupController,
                    hint: "Enter pickup location",
                    icon: Icons.location_on,
                    iconColor: TColors.primary,
                    focusNode: pickupFocusNode,
                    isPickup: true,
                  ),
                  SizedBox(height: 16),

                  // Destination location field
                  _buildLocationField(
                    controller: destinationController,
                    hint: "Enter destination",
                    icon: Icons.flag,
                    iconColor: Colors.amber.shade700,
                    focusNode: destinationFocusNode,
                    isPickup: false,
                  ),
                  SizedBox(height: 8),

                  // Search results (conditionally shown)
                  if (isSearching) _buildSearchResults(),
                  SizedBox(height: 16),

                  // Section title
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Ride Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  // Date and time row
                  Row(
                    children: [
                      Expanded(child: _buildDateSelection()),
                      SizedBox(width: 12),
                      Expanded(child: _buildTimeSelection()),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Passengers selection
                  _buildPassengerSelection(),
                  SizedBox(height: 24),

                  // Map section title
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      "Your Route",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  // Enhanced map
                  _buildMap(),
                  SizedBox(height: 24),

                  // Find ride button
                  _buildFindRideButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}