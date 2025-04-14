class RideDetails {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String pickupLocation;
  final String destinationLocation;
  final String rideDate;
  final String rideTime;
  final int availableSeats;
  final double price;
  final DateTime createdAt;
  final bool isActive;

  RideDetails({
    this.id = '',
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    required this.pickupLocation,
    required this.destinationLocation,
    required this.rideDate,
    required this.rideTime,
    required this.availableSeats,
    required this.price,
    DateTime? createdAt,
    this.isActive = true,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // Factory constructor to create a RideDetails object from a map (Firestore document)
  factory RideDetails.fromMap(Map<String, dynamic> map, String documentId) {
    return RideDetails(
      id: documentId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userAvatar: map['userAvatar'] ?? '',
      pickupLocation: map['pickupLocation'] ?? '',
      destinationLocation: map['destinationLocation'] ?? '',
      rideDate: map['rideDate'] ?? '',
      rideTime: map['rideTime'] ?? '',
      availableSeats: map['availableSeats'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Convert a RideDetails object to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'rideDate': rideDate,
      'rideTime': rideTime,
      'availableSeats': availableSeats,
      'price': price,
      'createdAt': createdAt,
      'isActive': isActive,
    };
  }

  // Create a copy of the current RideDetails with any updated fields
  RideDetails copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? pickupLocation,
    String? destinationLocation,
    String? rideDate,
    String? rideTime,
    int? availableSeats,
    double? price,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return RideDetails(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      rideDate: rideDate ?? this.rideDate,
      rideTime: rideTime ?? this.rideTime,
      availableSeats: availableSeats ?? this.availableSeats,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
