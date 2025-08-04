// import 'package:flutter/material.dart';
// import 'welcome_screen.dart';

// /// A simple splash/loading screen that matches the provided mock-up.
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Navigate to welcome screen after 3 seconds
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const WelcomeScreen()),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // We don't want an app bar or any padding for a splash screen.
//       body: Stack(
//         children: [
//           // 1. Background solid/gradient colour.
//           Container(
//             decoration: const BoxDecoration(
//               color: Color(0xFF63F8AB), // Base mint/green background.
//             ),
//           ),

//           // 2. Bottom-right blurred gradient circle.
//           //    Using Positioned to overflow slightly so it looks like the mock-up.
//           // Bottom-centered gradient circle with 2/3 showing
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: -130, // Negative value to show only top 2/3 of the circle
//             child: Center(
//               child: Container(
//                 width: 400,
//                 height: 400,
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   center: Alignment.center,
//                   radius: 0.5,
//                   colors: [
//                     Color(0xCCFFFFFF), // Soft highlight.
//                     Color(0xFF59C8FF), // Blue/teal outer.
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           ),

//           // 3. App title centred.
//           Center(
//             child: Text(
//               'Silso',
//               style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ) ??
//                   const TextStyle(
//                     fontSize: 46,
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
