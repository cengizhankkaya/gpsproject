// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();

//   MapController? getMapController(BuildContext context) {
//     final state = context.findAncestorStateOfType<_MapScreenState>();
//     return state?._mapController;
//   }
// }

// class _MapScreenState extends State<MapScreen> {
//   final MapController _mapController = MapController();
//   List<Marker> _markers = [];

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   void _checkUserLocation() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .get();
//         if (doc.exists) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           if (!data.containsKey('location')) {
//             _showNoLocationAlert();
//           }
//         }
//       } catch (e) {
//         _showSnackbar('Kullanıcı konumu kontrol edilemedi: $e');
//       }
//     }
//   }

//   void _showNoLocationAlert() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Konum Bilgisi Eksik'),
//           content: Text('Lütfen konum bilgilerinizi güncelleyiniz.'),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Tamam'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _getCurrentLocation();
//       _loadMarkersFromFirestore();
//       _checkUserLocation(); // Kullanıcının konum bilgisi kontrol ediliyor
//     });
//   }

//   void _getCurrentLocation() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showSnackbar('Konum servisleri etkin değil. Lütfen etkinleştirin.');
//       return;
//     }

//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         _showSnackbar('Konum izni verilmedi.');
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       _showSnackbar('Konum izni kalıcı olarak reddedildi.');
//       return;
//     }

//     try {
//       Position position = await Geolocator.getCurrentPosition();
//       if (mounted) {
//         _mapController.move(
//             LatLng(position.latitude, position.longitude), 13.0);
//       }
//     } catch (e) {
//       _showSnackbar('Konum alınamadı: $e');
//     }
//   }

//   void _loadMarkersFromFirestore() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .get();
//         if (doc.exists) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           if (data.containsKey('location')) {
//             // Konum verisini al
//             var locationData = data['location'];
//             double latitude = locationData['latitude'];
//             double longitude = locationData['longitude'];

//             // Marker oluştur
//             Marker userMarker = Marker(
//               point: LatLng(latitude, longitude),
//               width: 40,
//               height: 40,
//               child: Container(
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       color: Colors.blue,
//                       size: 40,
//                     ),
//                     Container(
//                       padding: EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         'Konumunuz',
//                         style: TextStyle(fontSize: 10),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );

//             setState(() {
//               _markers = [userMarker];
//               // Haritayı konuma odakla
//               _mapController.move(LatLng(latitude, longitude), 15.0);
//             });
//           } else {
//             _showSnackbar('Konum verisi bulunamadı.');
//           }
//         }
//       } else {
//         _showSnackbar('Kullanıcı oturum açmamış.');
//       }
//     } catch (e) {
//       _showSnackbar('Firestore verileri yüklenemedi: $e');
//     }
//   }

//   void _addMarker(LatLng position) {
//     setState(() {
//       if (!_markers.any((marker) => marker.point == position)) {
//         _markers.add(
//           Marker(
//             point: position,
//             width: 40,
//             height: 40,
//             child: Icon(
//               Icons.location_on,
//               color: Colors.red,
//               size: 40,
//             ),
//           ),
//         );
//       }
//     });

//     // Kartı göster
//     _showLocationCard(position);
//   }

//   void _showLocationCard(LatLng position) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Konum Bilgisi'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Koordinatlar: ${position.latitude}, ${position.longitude}'),
//               Text('Saat: ${DateTime.now()}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => _saveLocation(position),
//               child: Text('Kaydet'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('Kapat'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _saveLocation(LatLng position) async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .update({
//           'location': {
//             'latitude': position.latitude,
//             'longitude': position.longitude,
//           },
//           'timestamp': DateTime.now(),
//         });
//         Navigator.pop(context); // Kartı kapat
//         _showSnackbar('Konum başarıyla kaydedildi.');
//       } else {
//         _showSnackbar('Kullanıcı oturum açmamış.');
//       }
//     } catch (e) {
//       _showSnackbar('Konum kaydedilemedi: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             flex: 5,
//             child: FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 center: LatLng(41.015137, 28.979530),
//                 zoom: 13.0,
//                 minZoom: 5.0,
//                 maxZoom: 18.0,
//                 onTap: (tapPosition, point) {
//                   _addMarker(point);
//                 },
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                 ),
//                 MarkerLayer(
//                   markers: _markers,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
