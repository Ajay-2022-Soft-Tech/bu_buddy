// ride_details.dart
class RideDetails {
  final String pickupLocation;
  final String destinationLocation;
  final String rideDate;
  final String rideTime;
  final int availableSeats;

  RideDetails({
    required this.pickupLocation,
    required this.destinationLocation,
    required this.rideDate,
    required this.rideTime,
    required this.availableSeats,
  });
}
