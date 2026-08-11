import 'package:flutter_push_notifications/features/clock/domain/entities/clock_snapshot.dart';
import 'package:flutter_push_notifications/features/clock/domain/repositories/clock_repository.dart';

class SystemClockRepositoryImpl implements ClockRepository {
  @override
  Stream<ClockSnapshot> observeTicks() {
    return Stream.periodic(const Duration(seconds: 1), (_) => _currentSnapshot())
        .startWith(_currentSnapshot());
  }

  ClockSnapshot _currentSnapshot() {
    final now = DateTime.now();
    final timeZoneName = now.timeZoneName;
    final timeZoneOffset = now.timeZoneOffset;

    return ClockSnapshot(
      dateTime: now,
      timeZoneName: timeZoneName,
      timeZoneOffset: timeZoneOffset,
    );
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
