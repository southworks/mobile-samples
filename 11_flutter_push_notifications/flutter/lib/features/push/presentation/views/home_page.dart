import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_push_notifications/features/clock/presentation/view_models/clock_view_model.dart';
import 'package:flutter_push_notifications/features/clock/presentation/views/clock_section.dart';
import 'package:flutter_push_notifications/features/push/domain/entities/push_message.dart';
import 'package:flutter_push_notifications/features/push/presentation/view_models/push_view_model.dart';
import 'package:flutter_push_notifications/features/push/presentation/views/push_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.clockViewModel,
    required this.pushViewModel,
    super.key,
  });

  final ClockViewModel clockViewModel;
  final PushViewModel pushViewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.pushViewModel.foregroundMessageListener = _showForegroundMessage;
    unawaited(widget.pushViewModel.initialize());
  }

  void _showForegroundMessage(PushMessage message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${message.title}: ${message.body}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notifications Sample'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClockSection(viewModel: widget.clockViewModel),
          const SizedBox(height: 16),
          PushSection(viewModel: widget.pushViewModel),
        ],
      ),
    );
  }
}
