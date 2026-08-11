import 'package:flutter_push_notifications/features/clock/domain/entities/clock_snapshot.dart';
import 'package:flutter_push_notifications/features/clock/domain/repositories/clock_repository.dart';

class ObserveClockTicksUseCase {
  const ObserveClockTicksUseCase(this._repository);

  final ClockRepository _repository;

  Stream<ClockSnapshot> execute() => _repository.observeTicks();
}
