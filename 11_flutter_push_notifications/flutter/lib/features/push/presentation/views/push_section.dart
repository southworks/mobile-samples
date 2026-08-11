import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_push_notifications/features/push/domain/entities/notification_permission_status.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/topic_subscription_status.dart';
import 'package:flutter_push_notifications/features/push/presentation/view_models/push_view_model.dart';

class PushSection extends StatelessWidget {
  const PushSection({required this.viewModel, super.key});

  final PushViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Push notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Topic',
                  value: PushViewModel.topic,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Permission',
                  value: _permissionLabel(viewModel.permissionStatus),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Subscription',
                  value: _subscriptionLabel(viewModel.subscriptionStatus),
                ),
                if (viewModel.errorMessage case final error?) ...[
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: viewModel.isInitializing ||
                              viewModel.subscriptionStatus
                                  is TopicSubscriptionInProgress
                          ? null
                          : viewModel.subscribe,
                      child: const Text('Subscribe'),
                    ),
                    OutlinedButton(
                      onPressed: viewModel.isInitializing ||
                              viewModel.subscriptionStatus
                                  is TopicSubscriptionInProgress
                          ? null
                          : viewModel.unsubscribe,
                      child: const Text('Unsubscribe'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Last notification',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _LastNotificationCard(message: viewModel.lastMessage),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('Debug'),
                  children: [
                    if (viewModel.fcmToken case final token?)
                      SelectableText(
                        token,
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      const Text('Token not available yet.'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: viewModel.fcmToken == null
                          ? null
                          : () {
                              Clipboard.setData(
                                ClipboardData(text: viewModel.fcmToken!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FCM token copied'),
                                ),
                              );
                            },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy token'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _permissionLabel(NotificationPermissionStatus status) {
    return switch (status) {
      NotificationPermissionStatus.granted => 'Granted',
      NotificationPermissionStatus.denied => 'Denied',
      NotificationPermissionStatus.provisional => 'Provisional',
      NotificationPermissionStatus.unknown => 'Unknown',
    };
  }

  String _subscriptionLabel(TopicSubscriptionStatus status) {
    return switch (status) {
      TopicSubscriptionSubscribed() => 'Subscribed',
      TopicSubscriptionNotSubscribed() => 'Not subscribed',
      TopicSubscriptionInProgress() => 'Updating…',
      TopicSubscriptionUnknown() => 'Unknown',
      TopicSubscriptionError(:final message) => 'Error: $message',
    };
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _LastNotificationCard extends StatelessWidget {
  const _LastNotificationCard({required this.message});

  final PushMessage? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return Text(
        'No notifications received yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message!.title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(message!.body),
          const SizedBox(height: 8),
          Text(
            'Received at ${_formatDateTime(message!.receivedAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} $hour:$minute:$second';
  }
}
