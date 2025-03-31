import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';  // Import Lottie for animation
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class Trip {
  final String userName;
  final String userProfileImage;
  final String pickupLocation;
  final String destination;
  final String date;
  final String time;
  final int passengers;
  final String status;  // 'success' or 'failure'

  Trip({
    required this.userName,
    required this.userProfileImage,
    required this.pickupLocation,
    required this.destination,
    required this.date,
    required this.time,
    required this.passengers,
    required this.status,
  });
}

class MyTripsScreen extends StatefulWidget {
  MyTripsScreen({Key? key}) : super(key: key);

  @override
  _MyTripsScreenState createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final List<Trip> trips = [
    Trip(
      userName: 'Rohit',
      userProfileImage: 'assets/logos/google-icon.png',
      pickupLocation: 'University Campus',
      destination: 'Library',
      date: '2025-04-01',
      time: '10:00 AM',
      passengers: 2,
      status: 'success',  // Successful trip
    ),
    Trip(
      userName: 'Ajay',
      userProfileImage: 'assets/logos/facebook-icon.png',
      pickupLocation: 'Hostel A',
      destination: 'Cafeteria',
      date: '2025-03-28',
      time: '2:00 PM',
      passengers: 3,
      status: 'failure',  // Unsuccessful trip
    ),
    // Add more trips here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Trips"),
        backgroundColor: TColors.primary,

        elevation: 4,
      ),
      body: AnimatedList(
        initialItemCount: trips.length,
        itemBuilder: (context, index, animation) {
          final trip = trips[index];

          return FadeTransition(
            opacity: animation,
            child: Card(
              color: TColors.softGrey,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TSizes.cardRadiusSm),
              ),
              elevation: TSizes.cardElevation,
              child: Padding(
                padding: const EdgeInsets.all(TSizes.sm),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(trip.userProfileImage),
                    radius: TSizes.iconLg,
                  ),
                  title: Text(
                    trip.userName,
                    style: TextStyle(fontSize: TSizes.fontSizeLg, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pickup: ${trip.pickupLocation}', style: TextStyle(fontSize: TSizes.fontSizeMd)),
                      Text('Destination: ${trip.destination}', style: TextStyle(fontSize: TSizes.fontSizeMd)),
                      Text('Date: ${trip.date}', style: TextStyle(fontSize: TSizes.fontSizeMd)),
                      Text('Time: ${trip.time}', style: TextStyle(fontSize: TSizes.fontSizeMd)),
                      Text('${trip.passengers} Passengers', style: TextStyle(fontSize: TSizes.fontSizeMd)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: trip.status == 'success'
                        ? Image.asset('assets/icons/payment_methods/successful_payment_icon.png', height: 40)  // Lottie animation for success
                        : Image.asset('assets/icons/payment_methods/successful_payment_icon.png', height: 40), // Lottie animation for failure
                    onPressed: () {
                      // Implement additional action for trip details if needed
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
