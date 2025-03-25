import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_places_autocomplete_flutter/google_places_autocomplete_flutter.dart';
import 'package:google_places_autocomplete_flutter/model/prediction.dart';
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
  late GoogleMapController mapController;
  LatLng currentLocation = LatLng(28.4506, 77.5842); // Default to some location

  // Function to get the current location
  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    mapController.animateCamera(CameraUpdate.newLatLng(currentLocation));
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Fetch the current location when the screen loads
  }

  // Function to open the location search dialog using GooglePlacesAutocomplete
  Future<void> _openLocationSearch(TextEditingController controller) async {
    final result = await GooglePlaceAutoCompleteFlutterTextField(
      textEditingController: controller,
      googleAPIKey: "YOUR_GOOGLE_API_KEY",  // Replace with your actual API key
      inputDecoration: InputDecoration(),
      debounceTime: 800, // default 600 ms
      countries: ["in", "fr"],  // Optional, default null
      isLatLngRequired: true,  // If you need coordinates from place detail
      getPlaceDetailWithLatLng: (Prediction prediction) {
        // Handle details of place when latLng is required
        print("placeDetails: ${prediction.lng}, ${prediction.lat}");
      },
      itmClick: (Prediction prediction) {
        controller.text = prediction.description!;
        controller.selection = TextSelection.fromPosition(TextPosition(offset: prediction.description!.length));
      },
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
                onTap: () => _openLocationSearch(pickupController),
                child: Container(
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
                    controller: pickupController,
                    decoration: InputDecoration(
                      labelText: "Search Pickup",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Destination Location
              GestureDetector(
                onTap: () => _openLocationSearch(destinationController),
                child: Container(
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
                    controller: destinationController,
                    decoration: InputDecoration(
                      labelText: "Search Destination",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
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
                child: Container(
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
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Date: $selectedDate",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.calendar_today),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
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
                child: Container(
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
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "Time: $selectedTime",
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.access_time),
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Passenger Selection
              Container(
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
              ),
              SizedBox(height: TSizes.spaceBtwSections),

              // Google Map to show the location
              Container(
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
                        position: currentLocation,
                        infoWindow: InfoWindow(title: "Your Location"),
                      ),
                    },
                  ),
                ),
              ),
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
