import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studybuddy/firebase_options.dart';
import 'package:studybuddy/notifications.dart';
import 'package:studybuddy/pages/welcome.dart';

void main() async {
  // Pre App Setup
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await Firebase.initializeApp(
      name: "studdybuddy", options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initNotification();

  runApp((const Welcome()));
}
/*

 */