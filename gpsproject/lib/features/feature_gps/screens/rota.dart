import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class RotaScreen extends StatefulWidget {
  @override
  _RotaScreenState createState() => _RotaScreenState();

  GoogleMapController? getMapController(BuildContext context) {
    final state = context.findAncestorStateOfType<_RotaScreenState>();
    return state?._googleMapController;
  }
}

class _RotaScreenState extends State<RotaScreen> {
  GoogleMapController? _googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _checkUserLocation() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (!data.containsKey('location')) {
            _showNoLocationAlert();
          }
        }
      } catch (e) {
        _showSnackbar('Kullanıcı konumu kontrol edilemedi: $e');
      }
    }
  }

  void _showNoLocationAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konum Bilgisi Eksik'),
          content: Text('Lütfen konum bilgilerinizi güncelleyiniz.'),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
      _loadMarkersFromFirestore();
      _checkUserLocation(); // Kullanıcının konum bilgisi kontrol ediliyor
    });
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('Konum servisleri etkin değil. Lütfen etkinleştirin.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Konum izni verilmedi.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Konum izni kalıcı olarak reddedildi.');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        _googleMapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            13.0,
          ),
        );
      }
    } catch (e) {
      _showSnackbar('Konum alınamadı: $e');
    }
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
    final String apiKey =
        'YOUR_GOOGLE_MAPS_API_KEY'; // Buraya kendi API anahtarınızı ekleyin
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<LatLng> polylineCoordinates = [];
        if (data['routes'].isNotEmpty) {
          data['routes'][0]['legs'][0]['steps'].forEach((step) {
            polylineCoordinates.add(LatLng(
              step['end_location']['lat'],
              step['end_location']['lng'],
            ));
          });
          setState(() {
            _polylines = {
              Polyline(
                polylineId: PolylineId('route'),
                points: polylineCoordinates,
                color: Colors.blue,
                width: 5,
              ),
            };
          });
        } else {
          _showSnackbar('Rota bulunamadı.');
        }
      } else {
        _showSnackbar('Rota alınamadı: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showSnackbar('Rota alınamadı: $e');
    }
  }

  void _loadMarkersFromFirestore() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('location')) {
            var locationData = data['location'];
            double latitude = locationData['latitude'];
            double longitude = locationData['longitude'];

            Marker userMarker = Marker(
              markerId: MarkerId('userLocation'),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(title: 'Konumunuz'),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            );

            setState(() {
              _markers = {userMarker};
              _googleMapController?.animateCamera(
                CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 15.0),
              );
            });

            // Mevcut konumu al
            Position currentPosition = await Geolocator.getCurrentPosition();
            LatLng currentLatLng =
                LatLng(currentPosition.latitude, currentPosition.longitude);

            // Rota çiz
            await _drawRoute(currentLatLng, LatLng(latitude, longitude));
          } else {
            _showSnackbar('Konum verisi bulunamadı.');
          }
        }
      } else {
        _showSnackbar('Kullanıcı oturum açmamış.');
      }
    } catch (e) {
      _showSnackbar('Firestore verileri yüklenemedi: $e');
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      if (!_markers.any((marker) => marker.position == position)) {
        _markers.add(
          Marker(
            markerId: MarkerId(position.toString()),
            position: position,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    });

    // Kartı göster
    _showLocationCard(position);
  }

  void _showLocationCard(LatLng position) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konum Bilgisi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Koordinatlar: ${position.latitude}, ${position.longitude}'),
              Text('Saat: ${DateTime.now()}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _saveLocation(position),
              child: Text('Kaydet'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Kapat'),
            ),
          ],
        );
      },
    );
  }

  void _saveLocation(LatLng position) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          'timestamp': DateTime.now(),
        });
        Navigator.pop(context); // Kartı kapat
        _showSnackbar('Konum başarıyla kaydedildi.');
      } else {
        _showSnackbar('Kullanıcı oturum açmamış.');
      }
    } catch (e) {
      _showSnackbar('Konum kaydedilemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: GoogleMap(
              onMapCreated: (controller) => _googleMapController = controller,
              initialCameraPosition: CameraPosition(
                target: LatLng(41.015137, 28.979530),
                zoom: 13.0,
              ),
              markers: _markers,
              polylines: _polylines,
              onTap: (point) {
                _addMarker(point);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Kart İçeriği',
                        style: TextStyle(fontSize: 12),
                      ),
                      // Diğer kart içeriği buraya eklenebilir
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: FloatingActionButton(
                      onPressed: () {
                        _googleMapController?.animateCamera(
                          CameraUpdate.zoomIn(),
                        );
                      },
                      child: Icon(Icons.zoom_in),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: FloatingActionButton(
                      onPressed: () {
                        _googleMapController?.animateCamera(
                          CameraUpdate.zoomOut(),
                        );
                      },
                      child: Icon(Icons.zoom_out),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
