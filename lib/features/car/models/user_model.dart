import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? profilePicture;
  final String? studentId;
  final double rating;
  final int totalRides;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.profilePicture,
    this.studentId,
    this.rating = 0.0,
    this.totalRides = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, [String? id]) {
    return UserModel(
      id: id ?? map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profilePicture: map['profilePicture'],
      studentId: map['studentId'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalRides: map['totalRides'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'studentId': studentId,
      'rating': rating,
      'totalRides': totalRides,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
