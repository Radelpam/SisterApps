import 'dart:async';

import 'package:babysitters_app/pages/home_screen.dart';
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'functions/notifications/notifications.dart';

late StreamSubscription<User?> user;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initMessaging();

  user = FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      runApp(const MyApp());
    } else {
      runApp(MaterialApp(
        home: MenuScreen(),
      ));
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      home: TestNotificaion(),
    );
  }
}
