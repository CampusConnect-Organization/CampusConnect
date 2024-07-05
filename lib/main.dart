import 'package:campus_connect_app/helpers/notification.helpers.dart';
import 'package:campus_connect_app/view/splash.view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();
  await messaging.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await showNotification(
      message.notification!.title.toString(),
      message.notification!.body.toString(),
    );
  });

  await initializeNotifications();

  runApp(const App());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      theme: ThemeData(
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 14.0,
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
          ),
          titleLarge: TextStyle(
            fontSize: 18.0,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashView(),
    );
  }
}
