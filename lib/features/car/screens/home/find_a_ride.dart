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

class _FindARideScreenState extends State<FindARideScreen> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  int passengers = 1;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String selectedTime = 'Select time';
  GoogleMapController? mapController;  // Make mapController nullable
  LatLng currentLocation = LatLng(28.4506, 77.5842); // Default to some location
  LatLng pickupLocation = LatLng(28.4506, 77.5842); // Pickup location (initially set to current location)
  LatLng destinationLocation = LatLng(28.4506, 77.5842); // Destination location
  List<String> predefinedLocations = [
    'Bennett University',
    'Greater Noida',
    'Noida City Center',
    'Sector 62, Noida',
    'Delhi Airport'
  ]; // Predefined list of locations
  List<String> searchResults = []; // To store search results

  // Function to get the current location
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      pickupLocation = currentLocation;
      destinationLocation = currentLocation; // Initially set both markers to the current location
    });

    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(currentLocation));
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch the current location when the screen loads
  }

  // Function to filter and show locations when the user searches
  void _searchLocation(String query, bool isPickup) {
    setState(() {
      searchResults = predefinedLocations
          .where((location) => location.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Function to update the selected location and show selected menu
  void _selectLocation(String location, bool isPickup) {
    setState(() {
      if (isPickup) {
        pickupController.text = location;
      } else {
        destinationController.text = location;
      }
      searchResults.clear(); // Clear search results after selecting a location
    });
  }

  // Custom method to build the input fields
  Widget _buildInputField(TextEditingController? controller, String label, IconData icon, {bool enabled = true}) {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onChanged: (text) => _searchLocation(text, controller == pickupController), // Trigger search on text change
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: Icon(icon),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // Custom method to build the search results list
  Widget _buildSearchResults(bool isPickup) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index]),
          onTap: () {
            _selectLocation(searchResults[index], isPickup);
          },
        );
      },
    );
  }

  // Custom method to build the dropdown button for selecting passengers
  Widget _buildDropdownButton() {
    return Container(
      decoration: BoxDecoration(
        color: TColors.light,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButton<int>(
        value: passengers,
        items: List.generate(5, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text("${index + 1} passengers"),
          );
        }),
        onChanged: (value) {
          setState(() {
            passengers = value!;
          });
        },
        isExpanded: true,
      ),
    );
  }

  // Custom method to build the Google Map widget
  Widget _buildMap() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 20,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
          markers: {
            Marker(
              markerId: MarkerId("pickup"),
              position: pickupLocation,
              infoWindow: InfoWindow(title: "Pickup Location"),
            ),
            Marker(
              markerId: MarkerId("destination"),
              position: destinationLocation,
              infoWindow: InfoWindow(title: "Destination Location"),
            ),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find a Ride"),
        backgroundColor: TColors.primary,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Location
              GestureDetector(
                onTap: () {},
                child: _buildInputField(pickupController, "Search Pickup", Icons.search),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Show search results for Pickup location if the field is not empty
              if (pickupController.text.isNotEmpty)
                Container(
                  height: 200,
                  child: _buildSearchResults(true),  // true = pickup
                ),

              SizedBox(height: TSizes.spaceBtwSections),

              // Destination Location
              GestureDetector(
                onTap: () {},
                child: _buildInputField(destinationController, "Search Destination", Icons.search),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Show search results for Destination location if the field is not empty
              if (destinationController.text.isNotEmpty)
                Container(
                  height: 200,
                  child: _buildSearchResults(false),  // false = destination
                ),

              SizedBox(height: TSizes.spaceBtwSections),

              // Date Selection using showDatePicker
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                child: _buildInputField(null, "Date: $selectedDate", Icons.calendar_today, enabled: false),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Time Selection using showTimePicker
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime.format(context);
                    });
                  }
                },
                child: _buildInputField(null, "Time: $selectedTime", Icons.access_time, enabled: false),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Passenger Selection
              _buildDropdownButton(),
              SizedBox(height: TSizes.spaceBtwSections),

              // Google Map to show the location
              _buildMap(),
              SizedBox(height: TSizes.spaceBtwSections),

              // Button to "Find a Ride"
              ElevatedButton(
                onPressed: () {
                  // Implement your functionality to find a ride
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColors.primary, // Button color
                  padding: EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(double.infinity, 60), // Make button larger
                ),
                child: Text(
                  'Find a ride',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
