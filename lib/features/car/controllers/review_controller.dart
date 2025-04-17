// // lib/features/car/controllers/review_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_state_manager/src/simple/get_controllers.dart';
//
// import '../models/booking_model.dart';
// import '../repository/base_repository.dart';
// import '../repository/notification_repository.dart';
// import '../repository/payment_repository.dart';
//
// class ReviewController extends GetxController {
//   final ReviewRepository _reviewRepo = ReviewRepository();
//   final NotificationRepository _notificationRepo = NotificationRepository();
//
//   // Observable variables
//   final reviews = <ReviewModel>[].obs;
//   final isLoading = false.obs;
//   final userRating = 0.0.obs;
//   final totalReviews = 0.obs;
//
//   // Submit a review
//   Future<void> submitReview(
//       String rideId,
//       String revieweeId,
//       double rating,
//       String comment,
//       ) async {
//     try {
//       isLoading.value = true;
//
//       await _reviewRepo.addReview(
//         rideId,
//         revieweeId,
//         rating,
//         comment,
//       );
//
//       // Notify reviewee
//       await _notificationRepo.sendNotification(
//         revieweeId,
//         'New Review',
//         'Someone left you a review',
//         type: 'new_review',
//         data: {'rideId': rideId},
//       );
//
//       isLoading.value = false;
//       Get.back(); // Close review dialog
//       showSuccessMessage('Review submitted successfully');
//     } catch (e) {
//       isLoading.value = false;
//       showErrorMessage('Failed to submit review: $e');
//     }
//   }
//
//   // Load user reviews
//   void loadUserReviews(String userId) {
//     try {
//       _reviewRepo.getUserReviews(userId).listen(
//             (snapshot) {
//           reviews.assignAll(
//             snapshot.docs.map((doc) => ReviewModel.fromSnapshot(doc)).toList(),
//           );
//
//           // Calculate average rating
//           if (reviews.isNotEmpty) {
//             double total = reviews.fold(0.0, (sum, review) => sum + review.rating);
//             userRating.value = total / reviews.length;
//             totalReviews.value = reviews.length;
//           }
//         },
//         onError: (error) {
//           print('Error loading reviews: $error');
//         },
//       );
//     } catch (e) {
//       print('Error setting up reviews listener: $e');
//     }
//   }
//
//   void showSuccessMessage(String message) {
//     Get.snackbar(
//       'Success',
//       message,
//       backgroundColor: Colors.green.withOpacity(0.1),
//       colorText: Colors.green,
//     );
//   }
//
//   void showErrorMessage(String message) {
//     Get.snackbar(
//       'Error',
//       message,
//       backgroundColor: Colors.red.withOpacity(0.1),
//       colorText: Colors.red,
//     );
//   }
// }
//
// // lib/features/car/controllers/user_preferences_controller.dart
// class UserPreferencesController extends GetxController {
//   final _prefs = GetStorage();
//
//   // Observable variables
//   final isDarkMode = false.obs;
//   final defaultPickupLocation = ''.obs;
//   final preferredPaymentMethod = ''.obs;
//   final notificationsEnabled = true.obs;
//   final language = 'en'.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadPreferences();
//   }
//
//   // Load saved preferences
//   Future<void> loadPreferences() async {
//     isDarkMode.value = _prefs.read('isDarkMode') ?? false;
//     defaultPickupLocation.value = _prefs.read('defaultPickupLocation') ?? '';
//     preferredPaymentMethod.value = _prefs.read('preferredPaymentMethod') ?? '';
//     notificationsEnabled.value = _prefs.read('notificationsEnabled') ?? true;
//     language.value = _prefs.read('language') ?? 'en';
//
//     // Apply theme
//     Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
//   }
//
//   // Save preferences
//   Future<void> savePreferences() async {
//     await _prefs.write('isDarkMode', isDarkMode.value);
//     await _prefs.write('defaultPickupLocation', defaultPickupLocation.value);
//     await _prefs.write('preferredPaymentMethod', preferredPaymentMethod.value);
//     await _prefs.write('notificationsEnabled', notificationsEnabled.value);
//     await _prefs.write('language', language.value);
//   }
//
//   // Toggle dark mode
//   void toggleDarkMode() {
//     isDarkMode.value = !isDarkMode.value;
//     Get.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
//     savePreferences();
//   }
//
//   // Update default pickup location
//   void updateDefaultPickupLocation(String location) {
//     defaultPickupLocation.value = location;
//     savePreferences();
//   }
//
//   // Update preferred payment method
//   void updatePreferredPaymentMethod(String method) {
//     preferredPaymentMethod.value = method;
//     savePreferences();
//   }
//
//   // Toggle chat_bot
//   void toggleNotifications() {
//     notificationsEnabled.value = !notificationsEnabled.value;
//     savePreferences();
//   }
//
//   // Update language
//   void updateLanguage(String languageCode) {
//     language.value = languageCode;
//     Get.updateLocale(Locale(languageCode));
//     savePreferences();
//   }
// }
//
// // lib/features/car/controllers/notification_controller.dart
// class NotificationController extends GetxController {
//   final NotificationRepository _notificationRepo = NotificationRepository();
//
//   // Observable variables
//   final chat_bot = <NotificationModel>[].obs;
//   final unreadCount = 0.obs;
//
//   StreamSubscription? _notificationSubscription;
//
//   @override
//   void onInit() {
//     super.onInit();
//     _setupNotificationListener();
//   }
//
//   // Setup notification listener
//   void _setupNotificationListener() {
//     _notificationSubscription = _notificationRepo.getNotifications().listen(
//           (snapshot) {
//         chat_bot.assignAll(
//           snapshot.docs.map((doc) => NotificationModel.fromSnapshot(doc)).toList(),
//         );
//
//         // Update unread count
//         unreadCount.value = chat_bot
//             .where((notification) => !notification.isRead)
//             .length;
//       },
//       onError: (error) {
//         print('Error loading chat_bot: $error');
//       },
//     );
//   }
//
//   // Mark notification as read
//   Future<void> markAsRead(String notificationId) async {
//     try {
//       await _notificationRepo.markAsRead(notificationId);
//     } catch (e) {
//       print('Error marking notification as read: $e');
//     }
//   }
//
//   // Mark all chat_bot as read
//   Future<void> markAllAsRead() async {
//     try {
//       for (var notification in chat_bot) {
//         if (!notification.isRead) {
//           await _notificationRepo.markAsRead(notification.id);
//         }
//       }
//     } catch (e) {
//       print('Error marking all chat_bot as read: $e');
//     }
//   }
//
//   // Handle notification tap
//   void handleNotificationTap(NotificationModel notification) {
//     // Mark as read
//     markAsRead(notification.id);
//
//     // Navigate based on notification type
//     switch (notification.type) {
//       case 'booking_request':
//         Get.toNamed('/bookings/${notification.data['bookingId']}');
//         break;
//       case 'chat_message':
//         Get.toNamed('/chat/${notification.data['chatRoomId']}');
//         break;
//       case 'ride_update':
//         Get.toNamed('/rides/${notification.data['rideId']}');
//         break;
//       default:
//         print('Unknown notification type: ${notification.type}');
//     }
//   }
//
//   @override
//   void onClose() {
//     _notificationSubscription?.cancel();
//     super.onClose();
//   }
// }