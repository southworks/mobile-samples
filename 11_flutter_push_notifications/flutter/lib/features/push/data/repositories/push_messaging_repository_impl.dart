import 'package:flutter_push_notifications/features/push/data/datasources/firebase_messaging_data_source.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class PushMessagingRepositoryImpl implements PushMessagingRepository {
  PushMessagingRepositoryImpl(this._dataSource);

  final FirebaseMessagingDataSource _dataSource;

  @override
  Future<NotificationPermissionStatus> requestPermission() {
    return _dataSource.requestPermission();
  }

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() {
    return _dataSource.getPermissionStatus();
  }

  @override
  Future<void> subscribeToTopic({required String topic}) {
    return _dataSource.subscribeToTopic(topic: topic);
  }

  @override
  Future<void> unsubscribeFromTopic({required String topic}) {
    return _dataSource.unsubscribeFromTopic(topic: topic);
  }

  @override
  Stream<PushMessage> observeForegroundMessages() {
    return _dataSource.observeForegroundMessages();
  }

  @override
  Stream<PushMessage> observeOpenedMessages() {
    return _dataSource.observeOpenedMessages();
  }

  @override
  Future<PushMessage?> getInitialMessage() {
    return _dataSource.getInitialMessage();
  }

  @override
  Future<String?> getToken() {
    return _dataSource.getToken();
  }
}
