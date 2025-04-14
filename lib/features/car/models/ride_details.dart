import 'package:cloud_firestore/cloud_firestore.dart';

class RideDetails {
  final String id;
  final String driverId;
  final String driverName;
  final String pickupLocation;
  final String destinationLocation;
  final String rideDate;
  final String rideTime;
  final int availableSeats;
  final double fare;
  final String? vehicleType;
  final String? vehicleModel;
  final String? vehicleColor;
  final String? vehiclePlate;
  final String status;
  final GeoPoint? pickupCoordinates;
  final GeoPoint? destinationCoordinates;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideDetails({
    this.id = '',
    required this.driverId,
    required this.driverName,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.rideDate,
    required this.rideTime,
    required this.availableSeats,
    required this.fare,
    this.vehicleType,
    this.vehicleModel,
    this.vehicleColor,
    this.vehiclePlate,
    this.status = 'active',
    this.pickupCoordinates,
    this.destinationCoordinates,
    this.createdAt,
    this.updatedAt,
  });

  // Create RideDetails from Firestore document
  factory RideDetails.fromMap(Map<String, dynamic> map, [String? docId]) {
    return RideDetails(
      id: docId ?? map['id'] ?? '',
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      destinationLocation: map['destinationLocation'] ?? '',
      rideDate: map['rideDate'] ?? '',
      rideTime: map['rideTime'] ?? '',
      availableSeats: map['availableSeats'] ?? 0,
      fare: (map['fare'] ?? 0.0).toDouble(),
      vehicleType: map['vehicleType'],
      vehicleModel: map['vehicleModel'],
      vehicleColor: map['vehicleColor'],
      vehiclePlate: map['vehiclePlate'],
      status: map['status'] ?? 'active',
      pickupCoordinates: map['pickupCoordinates'],
      destinationCoordinates: map['destinationCoordinates'],
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  // Convert RideDetails to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'rideDate': rideDate,
      'rideTime': rideTime,
      'availableSeats': availableSeats,
      'fare': fare,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'vehiclePlate': vehiclePlate,
      'status': status,
      'pickupCoordinates': pickupCoordinates,
      'destinationCoordinates': destinationCoordinates,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
    };
  }

  // Create a copy of RideDetails with some fields updated
  RideDetails copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? pickupLocation,
    String? destinationLocation,
    String? rideDate,
    String? rideTime,
    int? availableSeats,
    double? fare,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleColor,
    String? vehiclePlate,
    String? status,
    GeoPoint? pickupCoordinates,
    GeoPoint? destinationCoordinates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideDetails(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      rideDate: rideDate ?? this.rideDate,
      rideTime: rideTime ?? this.rideTime,
      availableSeats: availableSeats ?? this.availableSeats,
      fare: fare ?? this.fare,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      status: status ?? this.status,
      pickupCoordinates: pickupCoordinates ?? this.pickupCoordinates,
      destinationCoordinates: destinationCoordinates ?? this.destinationCoordinates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
