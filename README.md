BuBuddy - Student Ride Sharing Platform 🚗
BuBuddy is a student-focused ride-sharing mobile application built with Flutter and Firebase, designed to connect college students for convenient and affordable campus commutes. The app features an animated, intuitive UI and seamless real-time functionality.

![BuBuddy Banner](https://your

Real-time ride matching - Find rides based on location and time

Animated user interface - Beautiful transitions and micro-interactions

Trip management - View and manage upcoming and past trips

In-app messaging - Communicate with ride providers

User verification - Student-verified profiles

Dark & light themes - Elegant UI in both modes

📱 Screenshots
<p align="center"> <img src="https://your-image-url.com/screenshot1.png" width="200" /> <img src="https://your-image-url.com/screenshot2.png" width="200" /> <img src="https://your-image-url.com/screenshot3.png" width="200" /> </p>
🛠️ Technologies Used
Flutter - UI framework

Firebase - Backend services

Firestore - NoSQL database

Authentication - User authentication

Cloud Functions - Serverless functions

GetX - State management and navigation

flutter_animate - Animation library

Lottie - Complex animations

🚀 Getting Started
Prerequisites
Flutter (2.10.0 or higher)

Firebase Account

Git

Android Studio or VS Code

Installation
Clone the repository

bash
git clone https://github.com/yourusername/bubuddy.git
cd bubuddy
Install dependencies

bash
flutter pub get
Set up Firebase

Create a new Firebase project at Firebase Console

Enable Authentication (Email/Password)

Set up Firestore Database with appropriate security rules

Download google-services.json (for Android) and/or GoogleService-Info.plist (for iOS)

Place these files in the appropriate directories:

Android: android/app/

iOS: ios/Runner/

Create required Firestore indexes

Create composite index for the rides collection:

Fields: isActive (Ascending), rideDate (Ascending), availableSeats (Ascending), __name__ (Ascending)

Run the application

bash
flutter run
📁 Project Structure
text
lib/
├── controllers/
│   └── trip_controller.dart
├── models/
│   └── ride_details.dart
├── screens/
│   ├── chat_screen/
│   │   └── chat_screen.dart
│   ├── find_a_ride/
│   │   └── find_a_ride_screen.dart
│   └── my_trips/
│       └── my_trips_screen.dart
└── utils/
    └── constants/
        ├── colors.dart
        └── sizes.dart
💃 Animations Used
BuBuddy leverages multiple animation techniques for a delightful user experience:

Entrance animations - Elements slide and fade in with staggered timing

Interactive button animations - Scale and shimmer effects on tap

Route transition animations - Custom page transitions

Animated backgrounds - Subtle flowing gradients and shapes

Loading animations - Lottie animations for loading states

Micro-interactions - Small animations that respond to user actions
