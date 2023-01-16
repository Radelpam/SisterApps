import 'dart:async';

import 'package:babysitters_app/Styles/Styles.dart';
import 'package:babysitters_app/pages/home_screen.dart';
import 'package:babysitters_app/pages/loadings/loading_page.dart';
import 'package:babysitters_app/pages/parte2/Menu_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'functions/notifications/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initMessaging();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      title: 'Material App',
      home: LoadingPage(),
    );
  }
}
