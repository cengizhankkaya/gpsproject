// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:gpsproject/pages/consts.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_map/flutter_map.dart' as flutter_map;
// import 'package:latlong2/latlong.dart' as latlong;

// // Google Maps ve diğer gerekli paketleri içe aktarıyoruz

// // Maps sınıfı, StatefulWidget olarak tanımlanıyor
// class Maps extends StatefulWidget {
//   @override
//   _MapsState createState() => _MapsState();

//   flutter_map.MapController? getMapController(BuildContext context) {
//     final state = context.findAncestorStateOfType<_MapsState>();
//     return state?._mapController;
//   }
// }

// // Başlangıç ve varış noktalarının koordinatları
// double? _destLatitude;
// double? _destLongitude;

// // _MapsState sınıfı, Maps sınıfının durumunu yönetir
// class _MapsState extends State<Maps> {
//   final flutter_map.MapController _mapController = flutter_map.MapController();
//   List<flutter_map.Marker> _markers = [];

//   // Rota çizimi için gerekli değişkenler
//   PolylinePoints polylinePoints = PolylinePoints();
//   Map<google_maps.PolylineId, google_maps.Polyline> polylines = {};
//   google_maps.MapType _currentMapType = google_maps.MapType.normal;

//   // Anlık konum değişkenleri
//   double? _currentLatitude;
//   double? _currentLongitude;

//   // Konum takibi için StreamSubscription
//   StreamSubscription<Position>? _locationSubscription;

//   // Haritanın başlangıç kamera pozisyonu
//   late google_maps.CameraPosition _initialCameraPosition =
//       google_maps.CameraPosition(
//     target:
//         google_maps.LatLng(_currentLatitude ?? 0.0, _currentLongitude ?? 0.0),
//     zoom: 15,
//   );

//   // Harita kontrolcüsü
//   google_maps.GoogleMapController? _controller;

//   // Harita üzerindeki işaretçileri

//   latlong.LatLng? firebaseLocation; // firebaseLocation değişkenini tanımla

//   bool _isLoading = true; // Yükleme durumu için

//   bool _showRoute = true; // Rota başlangıçta gösterilecek

//   google_maps.BitmapDescriptor? _carIcon;

//   // initState metodu, widget ilk oluşturulduğunda çalışır
//   @override
//   void initState() {
//     super.initState();
//     _loadMarkerIcon();
//     _initializeLocation();
//     _startLocationUpdates();
//     _getPolyline();
//     _getCurrentLocation();
//     _setDestinationFromFirestore();
//     _getLocationFromFirestore().then((location) {
//       if (location != null) {
//         setState(() {
//           _currentLatitude = location.latitude;
//           _currentLongitude = location.longitude;
//         });
//         _initialCameraPosition = google_maps.CameraPosition(
//           target: google_maps.LatLng(location.latitude, location.longitude),
//           zoom: 15,
//         );
//       }
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadMarkersFromFirestore();
//       _checkUserLocation();
//       _getPolyline();
//     });
//   }

//   Future<void> _loadMarkerIcon() async {
//     _carIcon = await google_maps.BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)),
//       'assets/white_car.png',
//     );
//   }

//   Future<void> _processFirestoreDocument(DocumentSnapshot doc) async {
//     try {
//       if (!doc.exists) {
//         _showSnackbar('Belge bulunamadı');
//         return;
//       }

//       Map<String, dynamic>? data;
//       try {
//         data = doc.data() as Map<String, dynamic>;
//       } catch (e) {
//         print('Veri dönüşüm hatası: $e');
//         _showSnackbar('Veri formatı uygun değil');
//         return;
//       }

//       if (!data.containsKey('location')) {
//         _showSnackbar('Konum bilgisi bulunamadı');
//         return;
//       }

//       var locationData = data['location'];
//       if (locationData == null || locationData is! Map) {
//         _showSnackbar('Konum verisi geçerli bir format değil');
//         return;
//       }

//       var lat = locationData['latitude'];
//       var lng = locationData['longitude'];

//       if (lat == null || lng == null) {
//         _showSnackbar('Enlem veya boylam değeri eksik');
//         return;
//       }

//       // Sayısal değerlere dönüştürme
//       double latitude;
//       double longitude;
//       try {
//         latitude = (lat is int)
//             ? lat.toDouble()
//             : (lat is double)
//                 ? lat
//                 : double.parse(lat.toString());
//         longitude = (lng is int)
//             ? lng.toDouble()
//             : (lng is double)
//                 ? lng
//                 : double.parse(lng.toString());
//       } catch (e) {
//         print('Koordinat dönüşüm hatası: $e');
//         _showSnackbar('Koordinat değerleri geçersiz');
//         return;
//       }

//       flutter_map.Marker userMarker = flutter_map.Marker(
//         point: latlong.LatLng(latitude, longitude),
//         child: Container(
//           child: Column(
//             children: [
//               const Icon(
//                 Icons.location_on,
//                 color: Colors.blue,
//                 size: 40,
//               ),
//               Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Text(
//                   'Konumunuz',
//                   style: TextStyle(fontSize: 10),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//       if (!mounted) return;

//       setState(() {
//         _markers = [userMarker];
//         _mapController.move(latlong.LatLng(latitude, longitude), 15.0);
//       });

//       print('Konum başarıyla işlendi: $latitude, $longitude');
//     } catch (e) {
//       print('Veri işleme hatası detayı: $e');
//     }
//   }

//   // Firestore'dan konumu al ve bir değişkene ata
//   Future<latlong.LatLng?> _getLocationFromFirestore() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         // Önce cache'den okumayı dene
//         try {
//           DocumentSnapshot doc = await FirebaseFirestore.instance
//               .collection('Users')
//               .doc(user.uid)
//               .get(const GetOptions(source: Source.cache));

//           if (doc.exists) {
//             Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//             if (data.containsKey('location')) {
//               var locationData = data['location'];
//               return latlong.LatLng(
//                 locationData['latitude'].toDouble(),
//                 locationData['longitude'].toDouble(),
//               );
//             }
//           }
//         } catch (cacheError) {
//           // Cache hatası durumunda sessizce devam et
//         }

//         // Cache'den okunamadıysa sunucudan dene
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .get();

//         if (doc.exists) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           if (data.containsKey('location')) {
//             var locationData = data['location'];
//             return latlong.LatLng(
//               locationData['latitude'].toDouble(),
//               locationData['longitude'].toDouble(),
//             );
//           }
//         }
//       } catch (e) {
//         // Sadece gerçek hataları logla
//         if (e is! FirebaseException || e.code != 'unavailable') {
//           print('Firestore veri okuma hatası: $e');
//         }
//       }
//     }
//     return null;
//   }

//   // dispose metodu, widget yok edildiğinde çalışır
//   @override
//   void dispose() {
//     // Stream'i temizle
//     _locationSubscription?.cancel();
//     _controller?.dispose(); // Map controller'ı temizle
//     super.dispose();
//   }

//   // Konum izinlerini ve konumu başlatan fonksiyon
//   Future<void> _initializeLocation() async {
//     if (!mounted) return; // Widget hala mount edilmiş mi kontrol et
//     try {
//       // Konum izinlerini kontrol et
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw 'Konum izni reddedildi';
//         }
//       }
//       // Konum servislerini kontrol et
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw 'Konum servisleri kapalı';
//       }
//       // Konumu al
//       await _getCurrentLocation();
//       // Konum alındıktan sonra rotayı çiz
//       if (_currentLatitude != null && _currentLongitude != null) {
//         await _getPolyline();
//       }
//     } catch (e) {
//       if (!mounted) return;
//       print('Konum alınamadı: $e');
//     } finally {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Anlık konumu alan fonksiyon
//   Future<void> _getCurrentLocation() async {
//     if (!mounted) return;
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       if (!mounted) return;
//       setState(() {
//         _currentLatitude = position.latitude;
//         _currentLongitude = position.longitude;
//       });
//     } catch (e) {
//       print('Konum alınamadı: $e');
//     }
//   }

//   // Sürekli konum güncellemelerini dinle
//   void _startLocationUpdates() {
//     _locationSubscription = Geolocator.getPositionStream(
//       locationSettings: const LocationSettings(
//         accuracy: LocationAccuracy.high,
//         distanceFilter: 10, // 10 metre hareket edildiğinde güncelle
//       ),
//     ).listen((Position position) async {
//       if (!mounted) return; // Widget hala ağaçta mı kontrol et
//       setState(() {
//         _currentLatitude = position.latitude;
//         _currentLongitude = position.longitude;
//       });

//       // Yeni konuma göre rotayı güncelle
//       await _getPolyline();

//       // Harita kamerasını yeni konuma göre güncelle (isteğe bağlı)
//       if (_controller != null && mounted) {
//         _controller!.animateCamera(
//           google_maps.CameraUpdate.newLatLng(
//             google_maps.LatLng(_currentLatitude!, _currentLongitude!),
//           ),
//         );
//       }
//     }, onError: (error) {
//       if (mounted) {
//         print("Konum takibi hatası: $error");
//       }
//     });
//   }

//   // Harita üzerindeki işaretçileri oluşturan fonksiyon
//   Set<google_maps.Marker> _cretaeMarker() {
//     Set<google_maps.Marker> markers = <google_maps.Marker>{};

//     // Anlık konum işaretçisi
//     if (_currentLatitude != null && _currentLongitude != null) {
//       markers.add(
//         google_maps.Marker(
//           infoWindow: const google_maps.InfoWindow(title: "Anlık Konumunuz"),
//           markerId: const google_maps.MarkerId("currentLocation"),
//           position: google_maps.LatLng(_currentLatitude!, _currentLongitude!),
//           icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
//               google_maps.BitmapDescriptor.hueAzure),
//         ),
//       );
//     }

//     // Firebase konum işaretçisi
//     if (_destLatitude != null && _destLongitude != null) {
//       markers.add(
//         google_maps.Marker(
//           markerId: const google_maps.MarkerId('firebaseLocation'),
//           position: google_maps.LatLng(_destLatitude!, _destLongitude!),
//           icon: _carIcon ?? google_maps.BitmapDescriptor.defaultMarker,
//           infoWindow: const google_maps.InfoWindow(
//             title: 'Kayıtlı Konum',
//             snippet: 'Firebase\'den alınan konum',
//           ),
//         ),
//       );
//     }

//     return markers;
//   }

//   void _addMarker(google_maps.LatLng position) {
//     latlong.LatLng latlongPosition =
//         latlong.LatLng(position.latitude, position.longitude);
//     setState(() {
//       if (!_markers.any((marker) => marker.point == latlongPosition)) {
//         _markers.add(
//           flutter_map.Marker(
//             point: latlongPosition,
//             child: Container(
//               child: const Icon(
//                 Icons.location_on,
//                 color: Colors.red,
//                 size: 40,
//               ),
//             ),
//           ),
//         );
//       }
//     });

//     // Kartı göster
//     _showLocationCard(latlongPosition);
//   }

//   void _showLocationCard(latlong.LatLng position) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Konum Bilgisi'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                   'Koordinatlar: \\${position.latitude}, \\${position.longitude}'),
//               Text('Saat: \\${DateTime.now()}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => _saveLocation(position),
//               child: const Text('Kaydet'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Kapat'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _saveLocation(latlong.LatLng position) async {
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

//         // Varış noktasını güncelle
//         setState(() {
//           _destLatitude = position.latitude;
//           _destLongitude = position.longitude;
//         });

//         // Rotayı ve işaretçileri güncelle
//         _setDestinationFromFirestore();
//         _loadMarkersFromFirestore();
//         _getPolyline();
//       } else {
//         _showSnackbar('Kullanıcı oturum açmamış.');
//       }
//     } catch (e) {
//       _showSnackbar('Konum kaydedilemedi: $e');
//     }
//   }

//   // Harita tipini değiştiren fonksiyon (normal/uydu)
//   void _onMapTypeButtonPressed() {
//     setState(() {
//       _currentMapType = _currentMapType == google_maps.MapType.normal
//           ? google_maps.MapType.satellite
//           : google_maps.MapType.normal;
//     });
//   }

//   // Belirli bir konuma giden fonksiyon
//   goToLoc() {
//     if (_currentLatitude != null &&
//         _currentLongitude != null &&
//         _controller != null) {
//       _controller!.animateCamera(
//         google_maps.CameraUpdate.newLatLng(
//           google_maps.LatLng(_currentLatitude!, _currentLongitude!),
//         ),
//       );
//     }
//   }

//   // Rota çizen fonksiyon
//   Future<void> _getPolyline() async {
//     if (!mounted) return;
//     if (_currentLatitude == null || _currentLongitude == null || !_showRoute) {
//       polylines.clear(); // Eğer _showRoute false ise rotayı temizle
//       if (mounted) {
//         setState(() {});
//       }
//       return;
//     }

//     try {
//       List<latlong.LatLng> polylineCoordinates = [];

//       // Önceki rotayı temizle
//       polylines.clear();

//       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         googleApiKey: GOOGLE_API_KEY,
//         request: PolylineRequest(
//           origin: PointLatLng(_currentLatitude!, _currentLongitude!),
//           destination: PointLatLng(_destLatitude!, _destLongitude!),
//           mode: TravelMode.driving,
//         ),
//       );

//       if (!mounted) return;

//       if (result.points.isNotEmpty) {
//         for (var point in result.points) {
//           polylineCoordinates
//               .add(latlong.LatLng(point.latitude, point.longitude));
//         }
//         _addPolyLine(polylineCoordinates);
//       } else {
//         print('Rota bulunamadı: \${result.errorMessage}');
//       }
//     } catch (e) {
//       print('Rota çizilirken hata oluştu: $e');
//     }
//   }

//   // Rota çizgisini haritaya ekleyen fonksiyon
//   _addPolyLine(List<latlong.LatLng> polylineCoordinates) {
//     if (!mounted) return;
//     google_maps.PolylineId id = const google_maps.PolylineId("poly");
//     google_maps.Polyline polyline = google_maps.Polyline(
//       polylineId: id,
//       color: Colors.pink,
//       points: polylineCoordinates
//           .map((point) => google_maps.LatLng(point.latitude, point.longitude))
//           .toList(),
//       width: 8,
//     );
//     polylines[id] = polyline;
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   // Kullanıcı konumunu Firestore'dan al ve bitiş noktası olarak ayarla
//   Future<void> _setDestinationFromFirestore() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       try {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .get(const GetOptions(source: Source.cache)); // Önce cache'den dene
//         if (!doc.exists) {
//           doc = await FirebaseFirestore.instance
//               .collection('Users')
//               .doc(user.uid)
//               .get(); // Cache'de yoksa sunucudan çek
//         }
//         if (doc.exists) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           if (data.containsKey('location')) {
//             var locationData = data['location'];
//             setState(() {
//               _destLatitude = locationData['latitude'];
//               _destLongitude = locationData['longitude'];
//             });
//           } else {
//             print('Konum verisi bulunamadı.');
//           }
//         }
//       } catch (e) {
//         print('Firestore verileri yüklenemedi: $e');
//       }
//     }
//   }

//   // Rota gösterimi için yeni fonksiyon
//   void _toggleRoute() {
//     setState(() {
//       _showRoute = !_showRoute;
//     });
//     _getPolyline(); // Rota durumunu güncelle
//   }

//   void _loadMarkersFromFirestore() async {
//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         _showSnackbar('Lütfen önce giriş yapın');
//         return;
//       }

//       // Önce cache'den okumayı dene
//       try {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(user.uid)
//             .get(const GetOptions(source: Source.cache));

//         if (doc.exists) {
//           await _processFirestoreDocument(doc);
//           return;
//         }
//       } catch (cacheError) {
//         print('Cache\'den okuma hatası: $cacheError');
//       }

//       // Cache'den okunamazsa sunucudan dene
//       DocumentSnapshot doc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(user.uid)
//           .get(const GetOptions(source: Source.server));

//       if (doc.exists) {
//         await _processFirestoreDocument(doc);
//       } else {
//         _showSnackbar('Kullanıcı verisi bulunamadı');
//       }
//     } catch (e) {
//       print('Firestore veri yükleme hatası: $e');
//       _showSnackbar(
//           'Veriler yüklenirken bir hata oluştu. Lütfen internet bağlantınızı kontrol edin.');
//     }
//   }

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
//           title: const Text('Konum Bilgisi Eksik'),
//           content: const Text('Lütfen konum bilgilerinizi güncelleyiniz.'),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Tamam'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // build metodu, widget'ın kullanıcı arayüzünü oluşturur
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           const SizedBox(width: 20), // Sol kenardan boşluk ekledim
//           FloatingActionButton(
//             onPressed: _onMapTypeButtonPressed,
//             child: const Icon(Icons.layers),
//           ),
//           const SizedBox(width: 10),
//           FloatingActionButton(
//             onPressed: goToLoc,
//             child: const Icon(Icons.map),
//           ),
//           const SizedBox(width: 10),
//           FloatingActionButton(
//             onPressed: _toggleRoute,
//             child: Icon(_showRoute ? Icons.timeline : Icons.timeline_outlined),
//           ),
//           const SizedBox(width: 10),
//           FloatingActionButton(
//             onPressed: () {
//               setState(() {
//                 // Sayfayı yeniden yüklemek için gerekli işlemler
//                 _setDestinationFromFirestore();
//                 _loadMarkersFromFirestore();
//                 _getPolyline();
//               });
//             },
//             child: const Icon(Icons.refresh),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   flex: 5,
//                   child: google_maps.GoogleMap(
//                     polylines: Set<google_maps.Polyline>.of(polylines.values),
//                     markers: _cretaeMarker(),
//                     myLocationEnabled: true,
//                     onTap: (point) {
//                       _addMarker(point);
//                     },
//                     myLocationButtonEnabled: true,
//                     mapType: _currentMapType,
//                     initialCameraPosition: _initialCameraPosition,
//                     tiltGesturesEnabled: true,
//                     compassEnabled: true,
//                     scrollGesturesEnabled: true,
//                     zoomGesturesEnabled: true,
//                     onMapCreated: (google_maps.GoogleMapController controller) {
//                       _controller = controller;
//                     },
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
