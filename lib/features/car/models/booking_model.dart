import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String rideId;
  final String passengerId;
  final String passengerName;
  final Map<String, dynamic> pickupLocation;
  final Map<String, dynamic> dropoffLocation;
  final double fare;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    this.id,
    required this.rideId,
    required this.passengerId,
    required this.passengerName,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.fare,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return BookingModel(
      id: id ?? map['id'],
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      passengerName: map['passengerName'] ?? '',
      pickupLocation: map['pickupLocation'] ?? {},
      dropoffLocation: map['dropoffLocation'] ?? {},
      fare: (map['fare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'fare': fare,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
