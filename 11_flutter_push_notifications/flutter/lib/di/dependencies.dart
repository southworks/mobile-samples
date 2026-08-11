import 'package:flutter_push_notifications/features/clock/data/repositories/system_clock_repository_impl.dart';
import 'package:flutter_push_notifications/features/clock/domain/use_cases/observe_clock_ticks_use_case.dart';
import 'package:flutter_push_notifications/features/clock/presentation/view_models/clock_view_model.dart';
import 'package:flutter_push_notifications/features/push/data/datasources/firebase_messaging_data_source.dart';
import 'package:flutter_push_notifications/features/push/data/repositories/push_messaging_repository_impl.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_fcm_token_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_initial_push_message_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_notification_permission_status_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/observe_opened_push_messages_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/observe_push_messages_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/request_notification_permission_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/subscribe_to_topic_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/unsubscribe_from_topic_use_case.dart';
import 'package:flutter_push_notifications/features/push/presentation/view_models/push_view_model.dart';

class Dependencies {
  static ClockViewModel makeClockViewModel() {
    final repository = SystemClockRepositoryImpl();
    return ClockViewModel(ObserveClockTicksUseCase(repository));
  }

  static PushViewModel makePushViewModel() {
    final dataSource = FirebaseMessagingDataSource();
    final repository = PushMessagingRepositoryImpl(dataSource);

    return PushViewModel(
      RequestNotificationPermissionUseCase(repository),
      GetNotificationPermissionStatusUseCase(repository),
      SubscribeToTopicUseCase(repository),
      UnsubscribeFromTopicUseCase(repository),
      ObservePushMessagesUseCase(repository),
      ObserveOpenedPushMessagesUseCase(repository),
      GetInitialPushMessageUseCase(repository),
      GetFcmTokenUseCase(repository),
    );
  }
}
