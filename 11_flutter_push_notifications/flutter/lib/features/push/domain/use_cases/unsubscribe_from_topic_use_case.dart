import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class UnsubscribeFromTopicUseCase {
  const UnsubscribeFromTopicUseCase(this._repository);

  final PushMessagingRepository _repository;

  Future<void> execute({required String topic}) {
    return _repository.unsubscribeFromTopic(topic: topic);
  }
}
