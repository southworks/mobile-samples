import 'package:flutter_push_notifications/features/clock/domain/entities/clock_snapshot.dart';

abstract class ClockRepository {
  Stream<ClockSnapshot> observeTicks();
}
