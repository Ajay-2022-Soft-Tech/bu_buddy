import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
// Import Lottie with alias to avoid naming conflicts
import 'package:lottie/lottie.dart' hide Marker;
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // Animation controllers
  late AnimationController _typingController;
  late AnimationController _mapAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _pulseAnimationController;

  // State management
  bool _isTyping = false;
  bool _isSearching = false;
  bool _showSuggestions = true;
  bool _isMapExpanded = false;
  bool _isLocating = false;
  bool _showNearbyPlaces = false;
  Position? _currentPosition;
  List<NearbyPlace> _nearbyPlaces = [];
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  final Set<Marker> _markers = {};

  // UI state animations
  late Animation<double> _mapHeightAnimation;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _mapExpandAnimation;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I'm your BU Buddy Ride Assistant. Where would you like to go today?",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    )
  ];

  // Sample nearby locations with ride estimates
  final List<NearbyPlace> _sampleNearbyPlaces = [
    NearbyPlace(
      name: "City Center Mall",
      distance: "2.3 km",
      address: "1st Main Road, Downtown",
      rating: 4.5,
      estimatedTime: "15 min",
      estimatedFare: "₹40-60",
      placeType: PlaceType.mall,
      latitude: 28.6139,  // Sample coordinates - will be replaced with real data
      longitude: 77.2090,
    ),
    NearbyPlace(
      name: "Tech Park",
      distance: "4.1 km",
      address: "Cyber Avenue, Electronics City",
      rating: 4.2,
      estimatedTime: "20 min",
      estimatedFare: "₹70-90",
      placeType: PlaceType.office,
      latitude: 28.6219,
      longitude: 77.2290,
    ),
    NearbyPlace(
      name: "Central Railway Station",
      distance: "3.5 km",
      address: "Railway Colony, Central Area",
      rating: 4.3,
      estimatedTime: "18 min",
      estimatedFare: "₹50-75",
      placeType: PlaceType.transport,
      latitude: 28.6309,
      longitude: 77.2190,
    ),
    NearbyPlace(
      name: "University Campus",
      distance: "1.8 km",
      address: "University Road, Education Hub",
      rating: 4.7,
      estimatedTime: "12 min",
      estimatedFare: "₹30-45",
      placeType: PlaceType.education,
      latitude: 28.6129,
      longitude: 77.2390,
    ),
    NearbyPlace(
      name: "Green Valley Park",
      distance: "2.5 km",
      address: "Nature Drive, Greenwood",
      rating: 4.6,
      estimatedTime: "16 min",
      estimatedFare: "₹45-65",
      placeType: PlaceType.park,
      latitude: 28.6089,
      longitude: 77.2490,
    ),
  ];

  // Recent searches
  final List<String> _recentSearches = [
    "Campus Main Gate to City Center",
    "Railway Station to Tech Park",
    "Airport to Downtown",
    "Central Park to University Campus",
  ];

  // Suggestion categories with options
  final Map<String, List<String>> _suggestionCategories = {
    "Popular Destinations": [
      "City Center Mall",
      "Tech Park",
      "Railway Station",
      "Airport",
    ],
    "Quick Actions": [
      "Find a ride now",
      "Book a carpool",
      "Schedule for tomorrow",
      "My trips",
    ],
    "May I help you with": [
      "Ride estimate",
      "Available drivers nearby",
      "Ride history",
      "Payment options",
    ],
  };

  @override
  void initState() {
    super.initState();

    // Initialize tab controller
    _tabController = TabController(
        length: _suggestionCategories.keys.length,
        vsync: this
    );

    // Animation controllers setup
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _mapAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Animations
    _mapHeightAnimation = Tween<double>(begin: 0, end: 250).animate(
      CurvedAnimation(
        parent: _mapAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _mapExpandAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mapAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _searchBarAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Request location permission on start
    _determinePosition();

    // Automatically scroll to bottom when new messages are added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _typingController.dispose();
    _mapAnimationController.dispose();
    _searchAnimationController.dispose();
    _pulseAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Get current location with permission handling
  Future<void> _determinePosition() async {
    setState(() => _isLocating = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLocating = false);
        _showLocationErrorMessage("Location services are disabled. Please enable in settings.");
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLocating = false);
          _showLocationErrorMessage("Location permissions are denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLocating = false);
        _showLocationErrorMessage(
          "Location permissions are permanently denied. Please enable in app settings.",
        );
        return;
      }

      // Get the current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException("Location fetch timed out. Please try again.");
        },
      );

      setState(() {
        _currentPosition = position;
        _isLocating = false;
      });

      // Load nearby places after getting position
      _loadNearbyPlaces();

      // Update UI with success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location updated successfully"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
        _showLocationErrorMessage("Error getting location: ${e.toString()}");
      }
    }
  }

  // Load nearby places and update map markers
  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLocating = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // For demonstration, use sample data with randomized order
    final shuffledPlaces = List<NearbyPlace>.from(_sampleNearbyPlaces)..shuffle();

    setState(() {
      _nearbyPlaces = shuffledPlaces;
      _isLocating = false;
      _showNearbyPlaces = true;
    });

    // Update markers after places are loaded
    _updateMapMarkers();
  }

  // Update map markers based on nearby places
  void _updateMapMarkers() async {
    if (_currentPosition == null || !_mapControllerCompleter.isCompleted) return;

    // Clear existing markers
    _markers.clear();

    // Add current location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        infoWindow: const InfoWindow(
          title: 'Your Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Add markers for nearby places
    for (var place in _nearbyPlaces) {
      // Use current position with random offset for demo
      final offset = Random().nextDouble() * 0.01;
      final lat = _currentPosition!.latitude + (offset * (Random().nextBool() ? 1 : -1));
      final lng = _currentPosition!.longitude + (offset * (Random().nextBool() ? 1 : -1));

      _markers.add(
        Marker(
          markerId: MarkerId('place_${place.name}'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: '${place.distance} • ${place.estimatedTime}',
          ),
          icon: await _getMarkerIconForPlace(place.placeType),
        ),
      );
    }

    // Update the map
    if (mounted) {
      setState(() {});
    }
  }

  // Get custom marker icons based on place type
  Future<BitmapDescriptor> _getMarkerIconForPlace(PlaceType placeType) async {
    switch (placeType) {
      case PlaceType.mall:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      case PlaceType.office:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case PlaceType.transport:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      case PlaceType.education:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case PlaceType.park:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  void _showLocationErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    setState(() {
      _showSuggestions = false;
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
      _showNearbyPlaces = false;

      if (_isMapExpanded) {
        _isMapExpanded = false;
        _mapAnimationController.reverse();
      }
    });

    _scrollToBottom();

    // Simulate bot typing with random delay based on message length
    final responseDelay = Duration(milliseconds: 500 + (text.length * 50).clamp(500, 2000));

    Future.delayed(responseDelay, () {
      if (!mounted) return;

      setState(() {
        _isTyping = false;

        if (text.toLowerCase().contains("nearby") ||
            text.toLowerCase().contains("close") ||
            text.toLowerCase().contains("around")) {

          _messages.add(ChatMessage(
            text: "I'll help you find places nearby. Let me search for locations around your current position...",
            isUser: false,
            timestamp: DateTime.now(),
          ));

          _toggleMapView(true);
          _loadNearbyPlaces();

        } else if (text.toLowerCase().contains("ride") ||
            text.toLowerCase().contains("book") ||
            text.toLowerCase().contains("taxi")) {

          _messages.add(ChatMessage(
            text: "I found several rides available for you. Here are some options:",
            isUser: false,
            timestamp: DateTime.now(),
            showRideOptions: true,
          ));

        } else if (text.toLowerCase().contains("hello") ||
            text.toLowerCase().contains("hi")) {

          _messages.add(ChatMessage(
            text: "Hello! How can I help you today? Would you like to find nearby places or book a ride?",
            isUser: false,
            timestamp: DateTime.now(),
            showQuickReplies: true,
          ));

        } else if (text.toLowerCase().contains("map") ||
            text.toLowerCase().contains("show") ||
            text.toLowerCase().contains("locate")) {

          _messages.add(ChatMessage(
            text: "Here's the map view showing your current location:",
            isUser: false,
            timestamp: DateTime.now(),
          ));

          _toggleMapView(true);

        } else {
          _messages.add(ChatMessage(
            text: "I can help you find and book rides, or discover places nearby. Would you like to explore options around you?",
            isUser: false,
            timestamp: DateTime.now(),
            showQuickReplies: true,
          ));
        }
      });

      _scrollToBottom();
    });

    // Add to recent searches if it looks like a location query
    if (text.contains(" to ") && !_recentSearches.contains(text)) {
      setState(() {
        _recentSearches.insert(0, text);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }

    // Clear search field
    _searchController.clear();
  }

  void _toggleMapView(bool show) {
    setState(() {
      _isMapExpanded = show;
    });

    if (show) {
      _mapAnimationController.forward();
    } else {
      _mapAnimationController.reverse();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _animateToCurrentLocation() async {
    if (_currentPosition != null && _mapControllerCompleter.isCompleted) {
      final GoogleMapController controller = await _mapControllerCompleter.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }

  // Show booking confirmation dialog with animation
  void showAnimatedDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Booking Confirmation",
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedAnimation = CurvedAnimation(
          parent: a1,
          curve: Curves.easeInOutBack,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Text("Ride Booked!"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Use Lottie with proper import
                  Lottie.asset(
                    'assets/animations/ride_confirmed.json',
                    height: 150,
                    repeat: true,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Your ride has been successfully booked. Driver will arrive shortly.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: null,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(TColors.primary),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Connecting you to driver...",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = TColors.primary;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        title: Row(
          children: [
            // Animated app logo with pulsing effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: _pulseAnimation.value * 10,
                          spreadRadius: _pulseAnimation.value * 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.directions_car_outlined,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            // Flexible to prevent text overflow
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated title with typewriter effect
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'BU Buddy Ride Assistant',
                        textStyle: const TextStyle(
                          fontSize: TSizes.fontSizeMd,
                          fontWeight: FontWeight.bold,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                  Row(
                    children: [
                      // Animated online indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.5),
                                    blurRadius: 6 * value,
                                    spreadRadius: 2 * value,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: TSizes.xs,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Dynamic location button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLocating
                ? Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(10),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryColor,
              ),
            )
                : IconButton(
              icon: Icon(
                Icons.my_location,
                color: _currentPosition != null
                    ? primaryColor
                    : Colors.grey,
              ),
              onPressed: _determinePosition,
              tooltip: 'Get current location',
            ),
          ),
          // Theme toggle button with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * pi,
                child: IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDarkMode ? Colors.amber : Colors.blueGrey,
                  ),
                  onPressed: () {
                    // Toggle theme functionality would go here
                  },
                  tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        // Use SafeArea to respect system UI elements
        bottom: false, // Allow content to extend behind bottom navigation
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                Colors.grey.shade900,
                Colors.black,
              ]
                  : [
                Colors.blue.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              // Current location display at the top
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _currentPosition != null
                                ? Colors.green.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _currentPosition != null
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.grey.withOpacity(0.3),
                                blurRadius: _pulseAnimation.value * 8,
                                spreadRadius: _pulseAnimation.value * 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: _currentPosition != null ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _currentPosition != null
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Your Current Location",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: TSizes.fontSizeSm,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}, Long: ${_currentPosition!.longitude.toStringAsFixed(6)}",
                            style: TextStyle(
                              fontSize: TSizes.md,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        _isLocating
                            ? "Fetching your location..."
                            : "Location not available. Tap to get current location",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isLocating ? Icons.timelapse : Icons.refresh),
                      onPressed: _isLocating ? null : _determinePosition,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),

              // Animated search bar
              AnimatedBuilder(
                animation: _searchBarAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _searchBarAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 8,
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildSearchBar(isDarkMode),
                    ),
                  );
                },
              ),

              // Dynamic map view with animation - FIX: Clamp opacity value
              AnimatedBuilder(
                animation: _mapHeightAnimation,
                builder: (context, child) {
                  // FIX: Ensure opacity is between 0.0 and 1.0
                  final opacity = (_mapHeightAnimation.value / 250).clamp(0.0, 1.0);

                  return SizedBox(
                    height: _mapHeightAnimation.value,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: _mapExpandAnimation.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Map
                        _currentPosition != null
                            ? GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 14,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          compassEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          markers: _markers,
                          onMapCreated: (GoogleMapController controller) {
                            _mapControllerCompleter.complete(controller);
                            // Update markers after map is created
                            _updateMapMarkers();
                          },
                        )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                              const SizedBox(height: 16),
                              const Text('Initializing map...'),
                            ],
                          ),
                        ),

                        // Map controls
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Column(
                            children: [
                              // Zoom to current location button
                              FloatingActionButton.small(
                                heroTag: 'centerMapButton',
                                onPressed: _animateToCurrentLocation,
                                backgroundColor: primaryColor,
                                child: const Icon(
                                  Icons.center_focus_strong_rounded,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Close map button
                              FloatingActionButton.small(
                                heroTag: 'closeMapButton',
                                onPressed: () => _toggleMapView(false),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
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

              // Show nearby places when available
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                child: _showNearbyPlaces && _nearbyPlaces.isNotEmpty
                    ? SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _nearbyPlaces.length,
                    itemBuilder: (context, index) {
                      final place = _nearbyPlaces[index];
                      return _buildNearbyPlaceCard(place, index);
                    },
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              // Chat messages area with animations
              Expanded(
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.black12
                              : Colors.grey.shade50.withOpacity(0.5),
                          image: DecorationImage(
                            image: AssetImage(
                              isDarkMode
                                  ? 'assets/images/pattern_dark.png'
                                  : 'assets/images/pattern_light.png',
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.05,
                          ),
                        ),
                      ),
                    ),

                    // Messages list with scrolling to prevent RenderFlex errors
                    GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.defaultSpace,
                          vertical: TSizes.sm,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessage(message, index);
                        },
                      ),
                    ),

                    // Bot typing indicator
                    if (_isTyping)
                      Positioned(
                        bottom: 0,
                        left: 16,
                        child: _buildTypingIndicator(),
                      ),
                  ],
                ),
              ),

              // Suggestion categories bar with animations
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: _buildSuggestionsBar(isDarkMode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated search bar with suggestions
  Widget _buildSearchBar(bool isDarkMode) {
    return FocusScope(
      child: Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _searchAnimationController.forward();
          } else {
            _searchAnimationController.reverse();
          }
        },
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Where would you like to go?',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: TSizes.fontSizeSm,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: _isSearching
                  ? TColors.primary
                  : Colors.grey.shade500,
              size: 20,
            ),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSearching
                  ? Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TColors.primary,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: _searchController.text.isNotEmpty
                          ? Colors.grey.shade500
                          : Colors.transparent,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  // Animated microphone button
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: TColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.mic_none_rounded,
                              color: TColors.primary,
                            ),
                            onPressed: () {
                              // Voice search functionality
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              _handleSubmitted(text);
            }
          },
          onChanged: (text) {
            setState(() {
              _showSuggestions = text.isNotEmpty;
            });
          },
        ),
      ),
    );
  }

  // Animated message bubbles - Fixed for RenderFlex issues
  Widget _buildMessage(ChatMessage message, int index) {
    final isUser = message.isUser;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: isUser
                ? const Offset(1.0, 0.0)
                : const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
            reverseCurve: Curves.easeOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
      child: Column(
        key: ValueKey(index),
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _buildBotAvatar(),
              const SizedBox(width: 8),

              // Use Flexible to prevent overflow
              Flexible(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildMessageBubble(message, index),
                ),
              ),

              const SizedBox(width: 8),

              if (isUser) _buildUserAvatar(),
            ],
          ),

          // Ride options with animated entry
          if (message.showRideOptions)
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: SizedBox(
                      height: 320,
                      child: SlidableFeatureCards(),
                    ),
                  ),
                );
              },
            ),

          // Quick replies with staggered animation
          if (message.showQuickReplies)
            _buildQuickReplies(),
        ],
      ),
    );
  }

  // Animated bot avatar
  Widget _buildBotAvatar() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: CircleAvatar(
            backgroundColor: TColors.primary.withOpacity(0.2),
            radius: 16,
            child: Icon(
              Icons.directions_car_outlined,
              color: TColors.primary,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  // Animated user avatar
  Widget _buildUserAvatar() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: const CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 16,
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  // Enhanced message bubble with animations
  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isUser = message.isUser;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'message_$index',
      child: Material(
        elevation: 0,
        color: isUser
            ? TColors.primary
            : (isDarkMode ? Colors.grey.shade800 : Colors.white),
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isUser ? const Radius.circular(4) : null,
          bottomLeft: !isUser ? const Radius.circular(4) : null,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: !isUser ? const Radius.circular(4) : null,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : theme.textTheme.bodyLarge?.color,
                  fontSize: TSizes.fontSizeSm,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isUser
                      ? Colors.white.withOpacity(0.7)
                      : theme.textTheme.bodySmall?.color,
                  fontSize: TSizes.md,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated typing indicator - Fixed animation values
  Widget _buildTypingIndicator() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Row(
              children: [
                _buildBotAvatar(),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(
                      3,
                          (index) => TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8 * value,
                            decoration: BoxDecoration(
                              color: TColors.primary.withOpacity(value),
                              shape: BoxShape.circle,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Quick replies with staggered animation
  Widget _buildQuickReplies() {
    final quickReplies = [
      "Find nearby places",
      "Book a ride",
      "Show map",
      "My trip history",
    ];

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(top: 8, left: 40),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            quickReplies.length,
                (index) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + (index * 100)),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: _buildQuickReplyChip(quickReplies[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Individual quick reply chip with touch feedback
  Widget _buildQuickReplyChip(String text) {
    return InkWell(
      onTap: () => _handleSubmitted(text),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: TColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: TColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getSuggestionIcon(text),
              size: 14,
              color: TColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: TColors.primary,
                fontWeight: FontWeight.w500,
                fontSize: TSizes.fontSizeSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nearby place card with animations and ride info - Fixed for RenderFlex issues
  Widget _buildNearbyPlaceCard(NearbyPlace place, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: InkWell(
              onTap: () {
                _handleSubmitted("Book a ride to ${place.name}");
              },
              child: Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getPlaceTypeColor(place.placeType).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getPlaceTypeIcon(place.placeType),
                              color: _getPlaceTypeColor(place.placeType),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Use Expanded for text to prevent overflow
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: TSizes.fontSizeSm,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  place.address,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.shade100,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Use Flexible for text containers to prevent overflow
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    place.estimatedTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.currency_rupee,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    place.estimatedFare,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              place.distance,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
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
        );
      },
    );
  }

  // Animated suggestions bar with tab controller
  Widget _buildSuggestionsBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category tabs with animated indicator
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: TColors.primary,
              unselectedLabelColor: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
              indicatorColor: TColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: _suggestionCategories.keys.map((category) =>
                  Tab(text: category)
              ).toList(),
            ),
            // Fixed height to prevent layout issues
            SizedBox(
              height: 70,
              child: TabBarView(
                controller: _tabController,
                children: _suggestionCategories.values.map((suggestions) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSuggestionChip(suggestions[index]),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced suggestion chip with gradient background
  Widget _buildSuggestionChip(String suggestion) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: InkWell(
            onTap: () => _handleSubmitted(suggestion),
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.primary.withOpacity(isDarkMode ? 0.2 : 0.1),
                    TColors.primary.withOpacity(isDarkMode ? 0.3 : 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: TColors.primary.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: TColors.primary.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getSuggestionIcon(suggestion),
                      size: 16,
                      color: TColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      suggestion,
                      style: TextStyle(
                        color: TColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: TSizes.fontSizeSm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Utility method for getting suggestion icons
  IconData _getSuggestionIcon(String suggestion) {
    if (suggestion.toLowerCase().contains("nearby") ||
        suggestion.toLowerCase().contains("around") ||
        suggestion.toLowerCase().contains("close")) {
      return Icons.explore_outlined;
    } else if (suggestion.toLowerCase().contains("ride")) {
      return Icons.directions_car_outlined;
    } else if (suggestion.toLowerCase().contains("carpool")) {
      return Icons.people_outline;
    } else if (suggestion.toLowerCase().contains("trip") ||
        suggestion.toLowerCase().contains("history")) {
      return Icons.history_outlined;
    } else if (suggestion.toLowerCase().contains("driver") ||
        suggestion.toLowerCase().contains("profile")) {
      return Icons.person_outline;
    } else if (suggestion.toLowerCase().contains("payment") ||
        suggestion.toLowerCase().contains("fare") ||
        suggestion.toLowerCase().contains("estimate")) {
      return Icons.payment_outlined;
    } else if (suggestion.toLowerCase().contains("schedule") ||
        suggestion.toLowerCase().contains("tomorrow")) {
      return Icons.schedule_outlined;
    } else if (suggestion.toLowerCase().contains("map") ||
        suggestion.toLowerCase().contains("show") ||
        suggestion.toLowerCase().contains("locate")) {
      return Icons.map_outlined;
    } else if (suggestion.toLowerCase().contains("city") ||
        suggestion.toLowerCase().contains("park") ||
        suggestion.toLowerCase().contains("mall") ||
        suggestion.toLowerCase().contains("airport") ||
        suggestion.toLowerCase().contains("station")) {
      return Icons.location_on_outlined;
    }
    return Icons.chat_bubble_outline;
  }

  // Get color for place type
  Color _getPlaceTypeColor(PlaceType type) {
    switch (type) {
      case PlaceType.mall:
        return Colors.purple;
      case PlaceType.office:
        return Colors.blue;
      case PlaceType.transport:
        return Colors.orange;
      case PlaceType.education:
        return Colors.green;
      case PlaceType.park:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Get icon for place type
  IconData _getPlaceTypeIcon(PlaceType type) {
    switch (type) {
      case PlaceType.mall:
        return Icons.shopping_bag_outlined;
      case PlaceType.office:
        return Icons.business_center_outlined;
      case PlaceType.transport:
        return Icons.train_outlined;
      case PlaceType.education:
        return Icons.school_outlined;
      case PlaceType.park:
        return Icons.park_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  // Format timestamp for chat messages
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour;
    final minute = timestamp.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formattedMinute = minute.toString().padLeft(2, '0');

    return '$formattedHour:$formattedMinute $period';
  }
}

// Model class for nearby places
class NearbyPlace {
  final String name;
  final String distance;
  final String address;
  final double rating;
  final String estimatedTime;
  final String estimatedFare;
  final PlaceType placeType;
  final double latitude;
  final double longitude;

  NearbyPlace({
    required this.name,
    required this.distance,
    required this.address,
    required this.rating,
    required this.estimatedTime,
    required this.estimatedFare,
    required this.placeType,
    required this.latitude,
    required this.longitude,
  });
}

// Enumeration for place types
enum PlaceType {
  mall,
  office,
  transport,
  education,
  park,
}

// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool showRideOptions;
  final bool showQuickReplies;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.showRideOptions = false,
    this.showQuickReplies = false,
  });
}

// Ride Feature Cards Widget - Fixed animation and RenderFlex issues
class SlidableFeatureCards extends StatefulWidget {
  const SlidableFeatureCards({Key? key}) : super(key: key);

  @override
  State<SlidableFeatureCards> createState() => _SlidableFeatureCardsState();
}

class _SlidableFeatureCardsState extends State<SlidableFeatureCards> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  late AnimationController _animationController;
  int _currentPage = 0;

  // Sample ride data
  final List<Map<String, dynamic>> _rides = [
    {
      'driverName': 'Rahul S.',
      'vehicle': 'Honda City',
      'from': 'Campus Main Gate',
      'to': 'City Center Mall',
      'time': '10:30 AM',
      'seats': 3,
      'price': '₹40',
      'color': Colors.blue,
      'rating': 4.8,
    },
    {
      'driverName': 'Priya V.',
      'vehicle': 'Tata Nexon EV',
      'from': 'Railway Station',
      'to': 'Tech Park',
      'time': '09:15 AM',
      'seats': 2,
      'price': '₹55',
      'color': Colors.green,
      'rating': 4.9,
    },
    {
      'driverName': 'Amit K.',
      'vehicle': 'Toyota Innova',
      'from': 'Airport',
      'to': 'Downtown',
      'time': '02:00 PM',
      'seats': 4,
      'price': '₹75',
      'color': Colors.purple,
      'rating': 4.7,
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pageController.addListener(() {
      if (_pageController.page != null) {
        final page = _pageController.page!.round();
        if (_currentPage != page) {
          setState(() => _currentPage = page);
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Animated ride cards
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _rides.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final ride = _rides[index];
              final isCurrentPage = index == _currentPage;

              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: isCurrentPage ? 1.0 : 0.9),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuint,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: isCurrentPage ? 1.0 : 0.7,
                      child: _buildRideCard(ride, isDarkMode),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Ride card indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _rides.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 8,
                width: index == _currentPage ? 24 : 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index == _currentPage
                      ? TColors.primary
                      : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                label: 'Book Now',
                icon: Icons.touch_app_outlined,
                color: Colors.green,
                isDarkMode: isDarkMode,
              ),
              _buildActionButton(
                label: 'Contact',
                icon: Icons.message_outlined,
                color: TColors.primary,
                isDarkMode: isDarkMode,
              ),
              _buildActionButton(
                label: 'Share',
                icon: Icons.share_outlined,
                color: Colors.orange,
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Animated ride card with gradient background - Fixed layout issues
  Widget _buildRideCard(Map<String, dynamic> ride, bool isDarkMode) {
    final color = ride['color'] as Color;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(isDarkMode ? 0.3 : 0.1),
            color.withOpacity(isDarkMode ? 0.1 : 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withOpacity(0.2),
                  child: Text(
                    ride['driverName'].substring(0, 1),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride['driverName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: TSizes.fontSizeMd,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${ride['rating']} · ${ride['vehicle']}',
                            style: TextStyle(
                              fontSize: TSizes.xs,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ride['price'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: TSizes.fontSizeSm,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Route info
            Row(
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.circle_outlined,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Use Expanded for text to prevent overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        ride['from'],
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ride['to'],
                        style: TextStyle(
                          fontSize: TSizes.fontSizeSm,
                          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRideDetail(
                  icon: Icons.access_time,
                  value: ride['time'],
                  isDarkMode: isDarkMode,
                ),
                _buildRideDetail(
                  icon: Icons.event_seat_outlined,
                  value: '${ride['seats']} seats',
                  isDarkMode: isDarkMode,
                ),
                _buildRideDetail(
                  icon: Icons.bolt_outlined,
                  value: 'Express',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for ride details
  Widget _buildRideDetail({
    required IconData icon,
    required String value,
    required bool isDarkMode
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: TSizes.xs,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // Action button with ripple effect
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () {
            if (label == 'Book Now') {
              // Navigate to chat screen with booking confirmation
              final chatbotScreenState = context.findAncestorStateOfType<_ChatbotScreenState>();
              if (chatbotScreenState != null) {
                // Close any existing map views
                if (chatbotScreenState._isMapExpanded) {
                  chatbotScreenState._toggleMapView(false);
                }

                // Add a confirmation message to the chat
                chatbotScreenState.setState(() {
                  chatbotScreenState._messages.add(ChatMessage(
                    text: "I'd like to book this ride now, please.",
                    isUser: true,
                    timestamp: DateTime.now(),
                  ));

                  // Add typing indicator
                  chatbotScreenState._isTyping = true;
                });

                chatbotScreenState._scrollToBottom();

                // Simulate bot response after a short delay
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (!chatbotScreenState.mounted) return;

                  chatbotScreenState.setState(() {
                    chatbotScreenState._isTyping = false;
                    chatbotScreenState._messages.add(ChatMessage(
                      text: "I've booked your ride! Your driver will arrive in approximately 5 minutes. You can track their arrival in real-time below.",
                      isUser: false,
                      timestamp: DateTime.now(),
                    ));
                  });

                  chatbotScreenState._scrollToBottom();

                  // Show a confirmation dialog
                  chatbotScreenState.showAnimatedDialog(context);
                });
              }
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: color,
            backgroundColor: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          icon: Icon(
            icon,
            size: 16,
          ),
          label: Text(
            label,
            style: const TextStyle(
              fontSize: TSizes.fontSizeSm,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
