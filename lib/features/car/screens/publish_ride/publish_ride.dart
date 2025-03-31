import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utils/validators/validation.dart';
import '../../models/ride_details.dart';
import '../verify_ride_screen/verify_ride_screen.dart'; // Import the VerifyRideScreen

class PublishRideScreen extends StatefulWidget {
  @override
  _PublishRideScreenState createState() => _PublishRideScreenState();
}

class _PublishRideScreenState extends State<PublishRideScreen> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  int availableSeats = 1;

  // This function is called when the user publishes the ride
  void _publishRide() {
    // Validate if all fields are filled
    if (TValidator.validateRideDetails("Pickup Location", pickupController.text) != null ||
        TValidator.validateRideDetails("Destination Location", destinationController.text) != null ||
        TValidator.validateRideDetails("Ride Date", dateController.text) != null ||
        TValidator.validateRideDetails("Ride Time", timeController.text) != null) {
      // Show error message if any field is empty
      Get.snackbar("Validation Error", "Please fill in all the fields before publishing the ride.");
      return;
    }

    // Create a RideDetails instance to pass to the VerifyRideScreen
    RideDetails rideDetails = RideDetails(
      pickupLocation: pickupController.text,
      destinationLocation: destinationController.text,
      rideDate: dateController.text,
      rideTime: timeController.text,
      availableSeats: availableSeats,
    );

    // Navigate to the VerifyRideScreen and pass the rideDetails
    Get.to(() => RideVerificationScreen(rideDetails: rideDetails));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Publish Ride"),
        backgroundColor: Colors.blueAccent,
        elevation: 8,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pickup Location Field
              _buildInputField(pickupController, 'Pickup Location', Iconsax.location),
              SizedBox(height: 20),

              // Destination Location Field
              _buildInputField(destinationController, 'Destination Location', Iconsax.location_tick),
              SizedBox(height: 20),

              // Date Field
              _buildDateField(),
              SizedBox(height: 20),

              // Time Field
              _buildTimeField(),
              SizedBox(height: 20),

              // Passenger Selection Dropdown
              _buildDropdownButton(),
              SizedBox(height: 20),

              // Publish Ride Button
              _buildPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method to build the input fields
  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
        ),
      ),
    );
  }

  // Custom method to build the date field
  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          controller: dateController,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Ride Date',
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
            prefixIcon: Icon(Iconsax.calendar, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  // Custom method to build the time field
  Widget _buildTimeField() {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (pickedTime != null) {
          setState(() {
            timeController.text = pickedTime.format(context);
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
          controller: timeController,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Ride Time',
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 2),
            ),
            prefixIcon: Icon(Iconsax.clock, color: Colors.blueAccent),
          ),
        ),
      ),
    );
  }

  // Custom method to build the dropdown button for selecting passengers
  Widget _buildDropdownButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
        value: availableSeats,
        items: List.generate(5, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text("${index + 1} Passengers"),
          );
        }),
        onChanged: (value) {
          setState(() {
            availableSeats = value!;
          });
        },
        isExpanded: true,
      ),
    );
  }

  // Custom method to build the Publish Ride button
  Widget _buildPublishButton() {
    return ElevatedButton(
      onPressed: _publishRide,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size(double.infinity, 60),
      ),
      child: Text(
        'Publish Ride',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
