import 'package:flutter/material.dart';

import 'package:flutter_push_notifications/features/clock/domain/entities/clock_snapshot.dart';
import 'package:flutter_push_notifications/features/clock/presentation/view_models/clock_view_model.dart';

class ClockSection extends StatelessWidget {
  const ClockSection({required this.viewModel, super.key});

  final ClockViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final snapshot = viewModel.snapshot;
        if (snapshot == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _ClockCard(snapshot: snapshot);
      },
    );
  }
}

class _ClockCard extends StatelessWidget {
  const _ClockCard({required this.snapshot});

  final ClockSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateTime = snapshot.dateTime;
    final offset = snapshot.timeZoneOffset;
    final offsetSign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live clock',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _formatTime(dateTime),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(dateTime),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${snapshot.timeZoneName} (UTC$offsetSign$hours:$minutes)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }

  String _formatDate(DateTime dateTime) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];
    return '$weekday, $month ${dateTime.day}, ${dateTime.year}';
  }
}
