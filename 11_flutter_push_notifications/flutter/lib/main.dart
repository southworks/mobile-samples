import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:flutter_push_notifications/app.dart';
import 'package:flutter_push_notifications/features/push/data/datasources/firebase_messaging_data_source.dart';
import 'package:flutter_push_notifications/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? startupError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } on Object catch (error) {
    startupError = error;
  }

  runApp(PushNotificationsApp(startupError: startupError));
}
