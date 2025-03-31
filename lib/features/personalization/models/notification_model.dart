class RideNotification {
  final String rideId;
  final String senderName;
  final String rideDetails;
  final String status; // e.g., 'Completed', 'Pending', 'Cancelled'
  final DateTime timestamp;

  RideNotification({
    required this.rideId,
    required this.senderName,
    required this.rideDetails,
    required this.status,
    required this.timestamp,
  });

  // Static method to generate a list of notifications for demo purposes
  static List<RideNotification> getDemoNotifications() {
    return [
      RideNotification(
        rideId: '1',
        senderName: 'John Doe',
        rideDetails: 'Ride from University to Downtown',
        status: 'Completed',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
      ),
      RideNotification(
        rideId: '2',
        senderName: 'Jane Smith',
        rideDetails: 'Ride from Airport to Hotel',
        status: 'Pending',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      RideNotification(
        rideId: '3',
        senderName: 'Emily Johnson',
        rideDetails: 'Ride from Downtown to University',
        status: 'Cancelled',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }
}
