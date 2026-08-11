import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_push_notifications/features/clock/domain/entities/clock_snapshot.dart';
import 'package:flutter_push_notifications/features/clock/domain/use_cases/observe_clock_ticks_use_case.dart';

class ClockViewModel extends ChangeNotifier {
  ClockViewModel(this._observeClockTicksUseCase) {
    _subscription = _observeClockTicksUseCase.execute().listen((snapshot) {
      _snapshot = snapshot;
      notifyListeners();
    });
  }

  final ObserveClockTicksUseCase _observeClockTicksUseCase;
  late final StreamSubscription<ClockSnapshot> _subscription;

  ClockSnapshot? _snapshot;
  ClockSnapshot? get snapshot => _snapshot;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
