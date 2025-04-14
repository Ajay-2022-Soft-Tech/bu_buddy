// lib/features/car/models/booking_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String rideId;
  final String passengerId;
  final String driverId;
  final String status;
  final double fare;
  final int seats;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime createdAt;
  final String? paymentId;
  final String paymentStatus;

  BookingModel({
    required this.id,
    required this.rideId,
    required this.passengerId,
    required this.driverId,
    required this.status,
    required this.fare,
    required this.seats,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.createdAt,
    this.paymentId,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'driverId': driverId,
      'status': status,
      'fare': fare,
      'seats': seats,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'createdAt': createdAt,
      'paymentId': paymentId,
      'paymentStatus': paymentStatus,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      rideId: map['rideId'] ?? '',
      passengerId: map['passengerId'] ?? '',
      driverId: map['driverId'] ?? '',
      status: map['status'] ?? 'pending',
      fare: (map['fare'] ?? 0.0).toDouble(),
      seats: map['seats'] ?? 1,
      pickupLocation: map['pickupLocation'] ?? '',
      dropoffLocation: map['dropoffLocation'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      paymentId: map['paymentId'],
      paymentStatus: map['paymentStatus'] ?? 'pending',
    );
  }
}

// lib/features/car/models/ride_model.dart
class RideModel {
  final String id;
  final String driverId;
  final String driverName;
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final DateTime departureTime;
  final int totalSeats;
  final int availableSeats;
  final double totalFare;
  final String status;
  final String? vehicleType;
  final String? vehicleModel;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? preferences;

  RideModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.totalSeats,
    required this.availableSeats,
    required this.totalFare,
    required this.status,
    this.vehicleType,
    this.vehicleModel,
    required this.createdAt,
    this.updatedAt,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'origin': origin,
      'destination': destination,
      'departureTime': Timestamp.fromDate(departureTime),
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'totalFare': totalFare,
      'status': status,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'preferences': preferences,
    };
  }

  factory RideModel.fromMap(Map<String, dynamic> map, String id) {
    return RideModel(
      id: id,
      driverId: map['driverId'] ?? '',
      driverName: map['driverName'] ?? '',
      origin: map['origin'] ?? {},
      destination: map['destination'] ?? {},
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      totalSeats: map['totalSeats'] ?? 0,
      availableSeats: map['availableSeats'] ?? 0,
      totalFare: (map['totalFare'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'active',
      vehicleType: map['vehicleType'],
      vehicleModel: map['vehicleModel'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
      preferences: map['preferences'],
    );
  }
}

// lib/features/car/models/review_model.dart
class ReviewModel {
  final String id;
  final String rideId;
  final String reviewerId;
  final String revieweeId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.rideId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      rideId: map['rideId'] ?? '',
      reviewerId: map['reviewerId'] ?? '',
      revieweeId: map['revieweeId'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// lib/features/car/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoURL;
  final String? college;
  final String? studentId;
  final bool isVerified;
  final double rating;
  final int totalRides;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoURL,
    this.college,
    this.studentId,
    required this.isVerified,
    required this.rating,
    required this.totalRides,
    required this.preferences,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoURL': photoURL,
      'college': college,
      'studentId': studentId,
      'isVerified': isVerified,
      'rating': rating,
      'totalRides': totalRides,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      phoneNumber: map['phoneNumber'],
      photoURL: map['photoURL'],
      college: map['college'],
      studentId: map['studentId'],
      isVerified: map['isVerified'] ?? false,
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      preferences: map['preferences'] ?? {},
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : null,
    );
  }
}

// lib/features/car/models/user_trip_model.dart
class UserTripModel {
  final String id;
  final String userId;
  final String rideId;
  final String? bookingId;
  final String role;
  final Map<String, dynamic> origin;
  final Map<String, dynamic> destination;
  final DateTime tripDate;
  final String status;
  final double fare;
  final DateTime createdAt;

  UserTripModel({
    required this.id,
    required this.userId,
    required this.rideId,
    this.bookingId,
    required this.role,
    required this.origin,
    required this.destination,
    required this.tripDate,
    required this.status,
    required this.fare,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rideId': rideId,
      'bookingId': bookingId,
      'role': role,
      'origin': origin,
      'destination': destination,
      'tripDate': Timestamp.fromDate(tripDate),
      'status': status,
      'fare': fare,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserTripModel.fromMap(Map<String, dynamic> map, String id) {
    return UserTripModel(
      id: id,
      userId: map['userId'] ?? '',
      rideId: map['rideId'] ?? '',
      bookingId: map['bookingId'],
      role: map['role'] ?? 'passenger',
      origin: map['origin'] ?? {},
      destination: map['destination'] ?? {},
      tripDate: (map['tripDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      fare: (map['fare'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}