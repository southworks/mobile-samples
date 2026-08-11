import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/firebase_options.dart';

class FirebaseMessagingDataSource {
  FirebaseMessagingDataSource({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationPermissionStatus> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return _mapPermission(settings.authorizationStatus);
  }

  Future<NotificationPermissionStatus> getPermissionStatus() async {
    final settings = await _messaging.getNotificationSettings();
    return _mapPermission(settings.authorizationStatus);
  }

  Future<void> subscribeToTopic({required String topic}) {
    return _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic({required String topic}) {
    return _messaging.unsubscribeFromTopic(topic);
  }

  Stream<PushMessage> observeForegroundMessages() {
    return FirebaseMessaging.onMessage.map(_mapRemoteMessage);
  }

  Stream<PushMessage> observeOpenedMessages() {
    return FirebaseMessaging.onMessageOpenedApp.map(_mapRemoteMessage);
  }

  Future<PushMessage?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message == null) {
      return null;
    }
    return _mapRemoteMessage(message);
  }

  Future<String?> getToken() => _messaging.getToken();

  PushMessage _mapRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    return PushMessage(
      title: notification?.title ?? message.data['title'] ?? '(no title)',
      body: notification?.body ?? message.data['body'] ?? '(no body)',
      receivedAt: DateTime.now(),
    );
  }

  NotificationPermissionStatus _mapPermission(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized => NotificationPermissionStatus.granted,
      AuthorizationStatus.denied => NotificationPermissionStatus.denied,
      AuthorizationStatus.provisional =>
        NotificationPermissionStatus.provisional,
      AuthorizationStatus.notDetermined => NotificationPermissionStatus.unknown,
    };
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log(
    'Background message: ${message.notification?.title}',
    name: 'PushBackgroundHandler',
  );
}
