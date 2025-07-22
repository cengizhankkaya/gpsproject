import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:latlong2/latlong.dart' as latlong;

class LocationServices {
  Future<latlong.LatLng?> getLocationFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Önce cache'den okumayı dene
        try {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .get(const GetOptions(source: Source.cache));

          if (doc.exists) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            if (data.containsKey('location')) {
              var locationData = data['location'];
              return latlong.LatLng(
                locationData['latitude'].toDouble(),
                locationData['longitude'].toDouble(),
              );
            }
          }
        } catch (cacheError) {
          // Cache hatası durumunda sessizce devam et
        }

        // Cache'den okunamadıysa sunucudan dene
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('location')) {
            var locationData = data['location'];
            return latlong.LatLng(
              locationData['latitude'].toDouble(),
              locationData['longitude'].toDouble(),
            );
          }
        }
      } catch (e) {
        // Sadece gerçek hataları logla
        if (e is! FirebaseException || e.code != 'unavailable') {
          print('Firestore veri okuma hatası: $e');
        }
      }
    }
    return null;
  }
}
