import 'package:firebase_session/firebase_options.dart';
import 'package:firebase_session/screens/chat_screen.dart';
import 'package:firebase_session/screens/home_screen.dart';
import 'package:firebase_session/screens/login_screen.dart';
import 'package:firebase_session/screens/splashscreen.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //داخل التطبيق firebase لحتى اعمل تهيئة لل
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //platformباستخدام الخيارات اللي اعطيتك ياها لهذا ال  firebase اعمل تهيئة لل
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      home: SplashScreen(),
    ),
  );
}
