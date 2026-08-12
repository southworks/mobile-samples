import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:flutter_push_notifications/features/push/domain/config/push_topic_config.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/topic_subscription_status.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_fcm_token_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_initial_push_message_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/get_notification_permission_status_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/observe_opened_push_messages_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/observe_push_messages_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/request_notification_permission_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/subscribe_to_topic_use_case.dart';
import 'package:flutter_push_notifications/features/push/domain/use_cases/unsubscribe_from_topic_use_case.dart';

class PushViewModel extends ChangeNotifier {
  PushViewModel(
    this._requestNotificationPermissionUseCase,
    this._getNotificationPermissionStatusUseCase,
    this._subscribeToTopicUseCase,
    this._unsubscribeFromTopicUseCase,
    this._observePushMessagesUseCase,
    this._observeOpenedPushMessagesUseCase,
    this._getInitialPushMessageUseCase,
    this._getFcmTokenUseCase,
  );

  final RequestNotificationPermissionUseCase
  _requestNotificationPermissionUseCase;
  final GetNotificationPermissionStatusUseCase
  _getNotificationPermissionStatusUseCase;
  final SubscribeToTopicUseCase _subscribeToTopicUseCase;
  final UnsubscribeFromTopicUseCase _unsubscribeFromTopicUseCase;
  final ObservePushMessagesUseCase _observePushMessagesUseCase;
  final ObserveOpenedPushMessagesUseCase _observeOpenedPushMessagesUseCase;
  final GetInitialPushMessageUseCase _getInitialPushMessageUseCase;
  final GetFcmTokenUseCase _getFcmTokenUseCase;

  static const String topic = PushTopicConfig.sampleTopic;

  NotificationPermissionStatus _permissionStatus =
      NotificationPermissionStatus.unknown;
  TopicSubscriptionStatus _subscriptionStatus =
      const TopicSubscriptionUnknown();
  PushMessage? _lastMessage;
  String? _fcmToken;
  String? _errorMessage;
  bool _isInitializing = false;

  final List<StreamSubscription<PushMessage>> _messageSubscriptions = [];

  void Function(PushMessage message)? foregroundMessageListener;

  NotificationPermissionStatus get permissionStatus => _permissionStatus;
  TopicSubscriptionStatus get subscriptionStatus => _subscriptionStatus;
  PushMessage? get lastMessage => _lastMessage;
  String? get fcmToken => _fcmToken;
  String? get errorMessage => _errorMessage;
  bool get isInitializing => _isInitializing;

  Future<void> initialize() async {
    if (_isInitializing) {
      return;
    }
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _permissionStatus = await _requestNotificationPermissionUseCase.execute();
      notifyListeners();

      if (_isPermissionGranted(_permissionStatus)) {
        await _subscribeInternal();
      } else {
        _subscriptionStatus = const TopicSubscriptionNotSubscribed();
      }

      final initialMessage = await _getInitialPushMessageUseCase.execute();
      if (initialMessage != null) {
        _updateLastMessage(initialMessage);
      }

      _fcmToken = await _getFcmTokenUseCase.execute();

      _messageSubscriptions
        ..add(
          _observePushMessagesUseCase.execute().listen((message) {
            _updateLastMessage(message);
            foregroundMessageListener?.call(message);
          }),
        )
        ..add(
          _observeOpenedPushMessagesUseCase.execute().listen(_updateLastMessage),
        );
    } on Object catch (error) {
      _errorMessage = error.toString();
      _subscriptionStatus = TopicSubscriptionError(_errorMessage!);
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> subscribe() async {
    _subscriptionStatus = const TopicSubscriptionInProgress();
    _errorMessage = null;
    notifyListeners();

    try {
      if (!_isPermissionGranted(_permissionStatus)) {
        _permissionStatus =
            await _requestNotificationPermissionUseCase.execute();
        notifyListeners();
        if (!_isPermissionGranted(_permissionStatus)) {
          _subscriptionStatus = const TopicSubscriptionNotSubscribed();
          _errorMessage = 'Notification permission is required to subscribe.';
          notifyListeners();
          return;
        }
      }

      await _subscribeInternal();
    } on Object catch (error) {
      _subscriptionStatus = TopicSubscriptionError(error.toString());
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> unsubscribe() async {
    _subscriptionStatus = const TopicSubscriptionInProgress();
    _errorMessage = null;
    notifyListeners();

    try {
      await _unsubscribeFromTopicUseCase.execute(topic: topic);
      _subscriptionStatus = const TopicSubscriptionNotSubscribed();
      notifyListeners();
    } on Object catch (error) {
      _subscriptionStatus = TopicSubscriptionError(error.toString());
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> refreshPermissionStatus() async {
    _permissionStatus =
        await _getNotificationPermissionStatusUseCase.execute();
    notifyListeners();
  }

  Future<void> _subscribeInternal() async {
    await _subscribeToTopicUseCase.execute(topic: topic);
    _subscriptionStatus = const TopicSubscriptionSubscribed();
    notifyListeners();
  }

  void _updateLastMessage(PushMessage message) {
    _lastMessage = message;
    notifyListeners();
  }

  bool _isPermissionGranted(NotificationPermissionStatus status) {
    return status == NotificationPermissionStatus.granted ||
        status == NotificationPermissionStatus.provisional;
  }

  @override
  void dispose() {
    for (final subscription in _messageSubscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
