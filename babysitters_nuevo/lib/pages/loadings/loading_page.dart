import 'dart:async';

import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/pages/home_screen.dart';
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late StreamSubscription<User?> user;
  @override
  void initState() {
    getuserlogin();

    // TODO: implement initState
    super.initState();
  }

  late Timer _timer;
  //Toma 2 segundos de retraso para apreciar el cargado, junto a la verificacion de datos, donde verifica si el usuario ya tiene un ingreso o no
  getuserlogin() async {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {});
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        if (user == null) {
          _timer.cancel();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const TestNotificaion(),
              ),
              (route) => false);
        } else {
          _timer.cancel();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const MenuScreen(),
              ),
              (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    //cancel the timer here
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      width: media.width * 1,
      height: media.height * 1,
      color: colorprincipal,
      child: Center(
          child: CircularProgressIndicator(
        color: textColor1,
      )),
    );
  }
}
