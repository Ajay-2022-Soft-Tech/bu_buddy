import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String? id;
  final String driverId;
  final String driverName;
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final double totalFare;
  final double farePerSeat;
  final Map<String, dynamic>? vehicle;
  final String status;
  final String? routePolyline;
  final String? driverGender;
  final DateTime createdAt;
  final DateTime updatedAt;

  RideModel({
    this.id,
    required this.driverId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.totalSeats,
    required this.driverGender,
    required this.availableSeats,
    required this.totalFare,
    required this.farePerSeat,
    this.vehicle,
    this.status = 'active',
    this.routePolyline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RideModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return RideModel(
      id: id ?? map['id'],
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      origin: map['origin'] ?? {},
      destination: map['destination'] ?? {},
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      totalSeats: map['totalSeats'] ?? 0,
      availableSeats: map['availableSeats'] ?? 0,
      totalFare: (map['totalFare'] ?? 0.0).toDouble(),
      farePerSeat: (map['farePerSeat'] ?? 0.0).toDouble(),
      vehicle: map['vehicle'],
      driverGender: (map['gender']),
      status: map['status'] ?? 'active',
      routePolyline: map['routePolyline'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'totalFare': totalFare,
      'farePerSeat': farePerSeat,
      'vehicle': vehicle,
      'status': status,
      'routePolyline': routePolyline,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
