
# BU Buddy 🚗💨

BU Buddy is a carpooling app designed specifically for university students to help them share rides, save costs, and reduce their carbon footprint. Whether you're looking for a ride to campus or offering a ride to fellow students, BU Buddy makes it easy and safe to connect.

## Features 🎯

- **Ride Booking**: Students can find available rides or book a seat for upcoming trips. 🚘
- **Trip Management**: Manage your trips, see your upcoming rides, and review past trips. 📅
- **Notifications**: Stay updated on booking confirmations, cancellations, and ride updates. 🔔
- **User Authentication**: Secure login and registration for users. 🔒
- **Real-Time Tracking**: Monitor the location of your ride and ensure timely arrival. 🗺️
- **Personalized Ride Suggestions**: Get tailored ride options based on your preferences. 🛣️

## Tech Stack 💻

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase
- **State Management**: Riverpod
- **Authentication**: Firebase Authentication
- **Maps & Geolocation**: Google Maps API
- **Real-Time Database**: Firebase Firestore
- **Push Notifications**: Firebase Cloud Messaging

## Folder Structure 🗂️

```bash
lib/
├── bindings
├── common
├── data
│   └── features
│       └── car
│           ├── controllers
│           ├── models
│           └── repository
│               ├── base_repository.dart
│               ├── booking_repository.dart
│               ├── chat_repository.dart
│               ├── notification_repository.dart
│               ├── payment_repository.dart
│               ├── review_repository.dart
│               ├── tracking_repository.dart
│               ├── trip_repository.dart
│               └── user_repository.dart
│       └── screens
│           ├── available_rides
│           ├── chat_screen
│           ├── home
│           ├── my_trips
│           ├── publish_ride_screen
│           └── verify_ride_screen
│       └── personalization
│       └── localization
├── utils
│   ├── app.dart
│   ├── firebase_options.dart
│   ├── main.dart
│   └── navigation_menu.dart


git clone https://github.com/yourusername/BUBuddy.git
cd BUBuddy

flutter pub get
flutter run
```
![image](https://github.com/user-attachments/assets/c9bf6690-a22b-4df8-b2e6-9c136c41b612)   ![image](https://github.com/user-attachments/assets/513c2357-7052-404c-abcb-71fcf6484b7e)

![image](https://github.com/user-attachments/assets/de65b07f-f70c-4ed4-a7d9-da4ece8e15d7)    ![image](https://github.com/user-attachments/assets/d3a94a72-e461-4c2b-8863-8575f1ad4291)
