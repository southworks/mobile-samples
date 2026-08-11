import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class RequestNotificationPermissionUseCase {
  const RequestNotificationPermissionUseCase(this._repository);

  final PushMessagingRepository _repository;

  Future<NotificationPermissionStatus> execute() {
    return _repository.requestPermission();
  }
}
