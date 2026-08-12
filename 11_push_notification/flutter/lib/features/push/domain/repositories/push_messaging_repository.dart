import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';

abstract class PushMessagingRepository {
  Future<NotificationPermissionStatus> requestPermission();

  Future<NotificationPermissionStatus> getPermissionStatus();

  Future<void> subscribeToTopic({required String topic});

  Future<void> unsubscribeFromTopic({required String topic});

  Stream<PushMessage> observeForegroundMessages();

  Stream<PushMessage> observeOpenedMessages();

  Future<PushMessage?> getInitialMessage();

  Future<String?> getToken();
}
