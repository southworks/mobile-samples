import 'package:flutter_push_notifications/features/push/domain/repositories/push_messaging_repository.dart';

class GetFcmTokenUseCase {
  const GetFcmTokenUseCase(this._repository);

  final PushMessagingRepository _repository;

  Future<String?> execute() => _repository.getToken();
}
