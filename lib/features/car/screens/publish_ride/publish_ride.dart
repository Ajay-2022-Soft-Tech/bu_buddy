import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utils/validators/validation.dart';
import '../../models/ride_details.dart';

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
      driverId: '', // This should be populated with the current user's ID from authentication
      driverName: '', // This should be populated with the current user's name
      pickupLocation: pickupController.text,
      destinationLocation: destinationController.text,
      rideDate: dateController.text,
      rideTime: timeController.text,
      availableSeats: availableSeats,
      fare: 0.0, // You should add a fare controller to collect this information
      status: 'active', // Default status for a new ride
    );


    // Navigate to the VerifyRideScreen and pass the rideDetails
    // Get.to(() => RidePublishedConfirmationScreen(rideDetails: rideDetails));
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Publish Ride",
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
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildSectionTitle("Ride Details"),
              SizedBox(height: 16),

              // Pickup Location Field with improved UI
              _buildInputField(
                controller: pickupController,
                label: 'Pickup Location',
                icon: Iconsax.location,
                hint: 'Enter your starting point',
              ),
              SizedBox(height: 20),

              // Destination Location Field with improved UI
              _buildInputField(
                controller: destinationController,
                label: 'Destination',
                icon: Iconsax.location_tick,
                hint: 'Enter your destination',
              ),
              SizedBox(height: 30),

              // _buildSectionTitle("Schedule"),
              SizedBox(height: 16),

              // Date and Time in a row
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  SizedBox(width: 16),
                  Expanded(child: _buildTimeField()),
                ],
              ),
              SizedBox(height: 30),

              // _buildSectionTitle("Ride Options"),
              SizedBox(height: 16),

              // Seats selector with visual indicator
              _buildSeatsSelector(),
              SizedBox(height: 20),

              // Fare input field
              _buildFareField(),
              SizedBox(height: 40),

              // Publish Ride Button with animation
              _buildAnimatedPublishButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Custom method to build the input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(icon, color: Color(0xFF2C63FF)),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
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
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 90)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Color(0xFF2C63FF),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Iconsax.calendar, color: Color(0xFF2C63FF)),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                dateController.text.isEmpty ? "Select Date" : dateController.text,
                style: TextStyle(
                  color: dateController.text.isEmpty ? Colors.grey : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatsSelector() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Seats",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final seatNumber = index + 1;
              final isSelected = availableSeats == seatNumber;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    availableSeats = seatNumber;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFF2C63FF) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Color(0xFF2C63FF) : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "$seatNumber",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Add this controller to your state variables
  TextEditingController fareController = TextEditingController(text: "0.0");

  Widget _buildFareField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: fareController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: "Fare per Seat",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Container(
            padding: EdgeInsets.all(12),
            child: Icon(Iconsax.money, color: Color(0xFF2C63FF)),
          ),
          suffixText: "₹",
          suffixStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C63FF),
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


  Widget _buildAnimatedPublishButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Color(0xFF2C63FF), Color(0xFF3F8CFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2C63FF).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: _publishRide,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.send_1,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Publish Ride',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom method to build the dropdown button for selecting passengers
  // Widget _buildDropdownButton() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 8,
  //           offset: Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: DropdownButton<int>(
  //       value: availableSeats,
  //       items: List.generate(5, (index) {
  //         return DropdownMenuItem(
  //           value: index + 1,
  //           child: Text("${index + 1} Passengers"),
  //         );
  //       }),
  //       onChanged: (value) {
  //         setState(() {
  //           availableSeats = value!;
  //         });
  //       },
  //       isExpanded: true,
  //     ),
  //   );
  // }
  //
  // // Custom method to build the Publish Ride button
  // Widget _buildPublishButton() {
  //   return ElevatedButton(
  //     onPressed: _publishRide,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.blueAccent,
  //       padding: EdgeInsets.symmetric(vertical: 16),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       minimumSize: Size(double.infinity, 60),
  //     ),
  //     child: Text(
  //       'Publish Ride',
  //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     ),
  //   );
  // }
}
