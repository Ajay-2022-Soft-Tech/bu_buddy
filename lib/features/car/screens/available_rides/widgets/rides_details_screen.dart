//
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:url_launcher/url_launcher.dart'; // For phone/WhatsApp functionality
// import '../../../models/ride_details.dart';
//
// class RideDetailsScreen extends StatelessWidget {
//   final RideDetails rideDetails;
//
//   RideDetailsScreen({required this.rideDetails});
//
//   // Function to launch phone call
//   void _launchPhone() async {
//     final Uri phoneUri = Uri.parse('tel:${rideDetails.driverPhone}');
//     if (await canLaunch(phoneUri.toString())) {
//       await launch(phoneUri.toString());
//     } else {
//       throw 'Could not launch phone call';
//     }
//   }
//
//   // Function to launch WhatsApp message
//   void _launchWhatsApp() async {
//     final Uri whatsAppUri = Uri.parse('https://wa.me/${rideDetails.driverWhatsApp}');
//     if (await canLaunch(whatsAppUri.toString())) {
//       await launch(whatsAppUri.toString());
//     } else {
//       throw 'Could not launch WhatsApp';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Ride Details"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildRow(Iconsax.location, "Pickup: ${rideDetails.pickupLocation}"),
//             SizedBox(height: 10),
//             _buildRow(Iconsax.location_tick, "Destination: ${rideDetails.destinationLocation}"),
//             SizedBox(height: 10),
//             _buildRow(Icons.calendar_today, "Date: ${rideDetails.rideDate}"),
//             SizedBox(height: 10),
//             _buildRow(Icons.access_time, "Time: ${rideDetails.rideTime}"),
//             SizedBox(height: 10),
//             _buildRow(Icons.person, "Available Seats: ${rideDetails.availableSeats}"),
//             SizedBox(height: 30),
//
//             Text(
//               'Driver: ${rideDetails.driverName}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Phone: ${rideDetails.driverPhone}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'WhatsApp: ${rideDetails.driverWhatsApp}',
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 30),
//
//             // Call button
//             ElevatedButton(
//               onPressed: _launchPhone,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 minimumSize: Size(double.infinity, 60),
//               ),
//               child: Text(
//                 "Call Driver",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 10),
//
//             // WhatsApp button
//             ElevatedButton(
//               onPressed: _launchWhatsApp,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: EdgeInsets.symmetric(vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 minimumSize: Size(double.infinity, 60),
//               ),
//               child: Text(
//                 "Message on WhatsApp",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Custom method to build rows with icon and text
//   Widget _buildRow(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blueAccent),
//         SizedBox(width: 10),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ],
//     );
//   }
// }
