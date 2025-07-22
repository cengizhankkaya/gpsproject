import 'package:flutter/material.dart';

import '../features/feature_gps/screens/profile_screen.dart'; // ProfileScreen dosyasının doğru yolunu ekleyin

class profileCardWidget extends StatelessWidget {
  const profileCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen()),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.2,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Color(0xffF3F3F3),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, spreadRadius: 5)
              ]),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/user.png'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Jane Cooper',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '\$4,253',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
