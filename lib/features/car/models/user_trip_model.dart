// lib/features/car/models/trip_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String rideId;
  final String role; // 'driver' or 'passenger'
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final DateTime departureTime;
  final double fare;
  final String status;
  final DateTime timestamp;

  TripModel({
    required this.id,
    required this.rideId,
    required this.role,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.fare,
    required this.status,
    required this.timestamp,
  });

  factory TripModel.fromMap(Map<String, dynamic> map, String docId) {
    return TripModel(
      id: docId,
      rideId: map['rideId'] ?? '',
      role: map['role'] ?? 'passenger',
      origin: map['origin'] ?? {'name': 'Unknown'},
      destination: map['destination'] ?? {'name': 'Unknown'},
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      fare: (map['fare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'role': role,
      'origin': origin,
      'destination': destination,
      'departureTime': departureTime,
      'fare': fare,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
