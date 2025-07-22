// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// // import 'package:gpsproject/features/feature_gps/screens/map_screen.dart';
// //import 'package:gpsproject/features/feature_gps/screens/map_screen.dart';
// import 'package:gpsproject/pages/HomePage.dart';

// import 'package:gpsproject/pages/map_page.dart';

// class NavigatorCenter extends StatefulWidget {
//   @override
//   _NavigatorCenterState createState() => _NavigatorCenterState();
// }

// class _NavigatorCenterState extends State<NavigatorCenter> {
//   int _selectedIndex = 0;

//   static List<Widget> _widgetOptions = <Widget>[
//     CardDetailsPage(),
//     Maps(),
//     // MapScreen(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Card(
//             elevation: 8.0,
//             child: _widgetOptions.elementAt(_selectedIndex),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CurvedNavigationBar(
//         items: const <Widget>[
//           Icon(Icons.home_outlined, size: 28),
//           Icon(Icons.chat_bubble_outline, size: 28),
//           Icon(Icons.person_outline, size: 28),
//         ],
//         index: _selectedIndex,
//         color: Colors.white,
//         buttonBackgroundColor: Colors.blueAccent,
//         backgroundColor: Colors.grey.shade200,
//         animationCurve: Curves.easeInOut,
//         animationDuration: Duration(milliseconds: 600),
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
