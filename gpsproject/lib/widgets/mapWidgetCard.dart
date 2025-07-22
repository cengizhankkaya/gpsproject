import 'package:flutter/material.dart';
import 'package:gpsproject/pages/map_page.dart';

class mapWidgetCard extends StatelessWidget {
  const mapWidgetCard({
    super.key,
    required Animation<double>? animation,
  }) : _animation = animation;

  final Animation<double>? _animation;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return FutureBuilder(
                  future: Future.delayed(const Duration(milliseconds: 100)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Maps();
                  },
                );
              },
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          height: screenHeight * 0.3, // Ekran yüksekliğinin %30'u
          width: screenWidth * 0.8, // Ekran genişliğinin %80'i
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, spreadRadius: 5)
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Transform.scale(
              scale: _animation!.value,
              alignment: Alignment.center,
              child: Image.asset(
                'assets/maps.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
