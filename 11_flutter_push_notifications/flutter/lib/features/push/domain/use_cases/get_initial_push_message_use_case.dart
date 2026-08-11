import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class GetInitialPushMessageUseCase {
  const GetInitialPushMessageUseCase(this._repository);

  final PushMessagingRepository _repository;

  Future<PushMessage?> execute() => _repository.getInitialMessage();
}
