import 'package:flutter/material.dart';
import 'package:gpsproject/widgets/buildCardCard.dart';
import 'package:gpsproject/widgets/mapWidgetCard.dart';
import 'package:gpsproject/widgets/profileWidgetCard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CardDetailsPage extends StatefulWidget {
  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    _controller =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Çıkış yaptıktan sonra kullanıcıyı giriş ekranına yönlendirebilirsiniz.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.info_outline), Text(' Information')],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          mapWidgetCard(animation: _animation),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                profileCardWidget(),
                SizedBox(
                  width: 20,
                ),
                buildCarCard(context),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [],
            ),
          )
        ],
      ),
    );
  }
}
