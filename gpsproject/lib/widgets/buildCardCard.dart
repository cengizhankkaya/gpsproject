import 'package:flutter/material.dart';

Widget buildCarCard(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    height: MediaQuery.of(context).size.height * 0.2,
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          spreadRadius: 5,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/white_car.png', height: 80, fit: BoxFit.cover),
        const SizedBox(height: 3),
        const Text(
          'Fortuner GR',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 3),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('870km', style: TextStyle(color: Colors.grey)),
            Text('50L', style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 3),
        const Text('\$45.00/h', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
