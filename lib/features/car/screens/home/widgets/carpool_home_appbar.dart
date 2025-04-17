// // lib/features/car/screens/home/widgets/home_appbar.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import '../../../../../utils/constants/colors.dart';
// import '../../../../personalization/screens/chat_bot/chat_bot.dart';
//
// class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool showShadow;
//   final bool isDarkMode;
//
//   const HomeAppBar({
//     Key? key,
//     this.showShadow = false,
//     this.isDarkMode = false,
//   }) : super(key: key);
//
//   @override
//   Size get preferredSize => const Size.fromHeight(60);
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       decoration: BoxDecoration(
//         color: Colors.transparent,
//         boxShadow: showShadow
//             ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]
//             : null,
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//           child: Row(
//             children: [
//               // Logo
//               _buildLogo(),
//
//               // Title
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                   child: ShaderMask(
//                     shaderCallback: (bounds) => LinearGradient(
//                       colors: isDarkMode
//                           ? [Colors.white, Colors.blueAccent]
//                           : [Colors.white, Colors.white.withOpacity(0.8)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ).createShader(bounds),
//                     child: const Text(
//                         'BuBuddy',
//                         style: TextStyle(
//                             fontSize: 26,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 0.5
//                         )
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Action buttons
//               // _buildSearchButton(),
//               _buildNotificationButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLogo() {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: isDarkMode
//             ? Colors.blueAccent.withOpacity(0.1)
//             : Colors.white.withOpacity(0.3),
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//               color: isDarkMode
//                   ? Colors.blueAccent.withOpacity(0.2)
//                   : TColors.primary.withOpacity(0.3),
//               blurRadius: 8
//           )
//         ],
//         border: Border.all(
//             color: isDarkMode
//                 ? Colors.blueAccent.withOpacity(0.2)
//                 : Colors.white.withOpacity(0.4),
//             width: 1.5
//         ),
//       ),
//       child: Image.asset(
//         'assets/images/logo.png',
//         width: 28,
//         height: 28,
//         color: isDarkMode ? Colors.blueAccent : Colors.white,
//         errorBuilder: (_, __, ___) => Icon(
//             Icons.directions_car,
//             color: isDarkMode ? Colors.blueAccent : Colors.white,
//             size: 28
//         ),
//       ),
//     ).animate()
//         .fadeIn(duration: 600.ms)
//         .scale(begin: Offset(0.8, 0.8), end: Offset(1.0 , 1.0), curve: Curves.elasticOut, duration: 800.ms);
//   }
//
//   // Widget _buildSearchButton() {
//   //   return IconButton(
//   //     icon: Icon(
//   //         Icons.search,
//   //         color: isDarkMode ? Colors.blueAccent : Colors.white
//   //     ),
//   //     onPressed: () => Get.to(() => const SearchScreen()),
//   //   ).animate()
//   //       .fadeIn(duration: 600.ms, delay: 200.ms)
//   //       .moveX(begin: 20, end: 0);
//   // }
//
//   Widget _buildNotificationButton() {
//     return Stack(
//       children: [
//         IconButton(
//           icon: Icon(
//               Icons.notifications_outlined,
//               color: isDarkMode ? Colors.blueAccent : Colors.white
//           ),
//           onPressed: () => Get.to(() => const NotificationsScreen()),
//         ).animate()
//             .fadeIn(duration: 600.ms, delay: 300.ms)
//             .moveX(begin: 20, end: 0),
//
//         Positioned(
//           right: 12,
//           top: 10,
//           child: Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.red,
//               shape: BoxShape.circle,
//               border: Border.all(
//                   color: isDarkMode ? const Color(0xFF1F2937) : TColors.primary,
//                   width: 1.5
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }