import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gpsproject/features/feature_gps/screens/login_screen.dart';
import 'package:gpsproject/features/feature_gps/screens/profile_screen.dart';
import 'package:gpsproject/features/feature_gps/screens/register_screen.dart';
import 'package:gpsproject/pages/HomePage.dart';
import 'package:gpsproject/pages/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Bisiklet Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => CardDetailsPage(),
        '/map': (context) => Maps(),
        // '/HomePage': (context) => CardDetailsPage(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}
