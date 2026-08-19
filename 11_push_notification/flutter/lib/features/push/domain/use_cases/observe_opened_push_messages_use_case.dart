import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class ObserveOpenedPushMessagesUseCase {
  const ObserveOpenedPushMessagesUseCase(this._repository);

  final PushMessagingRepository _repository;

  Stream<PushMessage> execute() => _repository.observeOpenedMessages();
}
