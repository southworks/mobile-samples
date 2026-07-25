import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/native_tick_event.dart';
import '../services/native_ticker_service.dart';

/// Listens to a native EventChannel stream and shows each tick.
class EventChannelScreen extends StatefulWidget {
  const EventChannelScreen({super.key, this.tickerService});

  final NativeTickerService? tickerService;

  @override
  State<EventChannelScreen> createState() => _EventChannelScreenState();
}

class _EventChannelScreenState extends State<EventChannelScreen> {
  late final NativeTickerService _service =
      widget.tickerService ?? NativeTickerService();

  StreamSubscription<NativeTickEvent>? _subscription;
  NativeTickEvent? _latest;
  String? _errorMessage;
  bool _listening = false;

  Future<void> _start() async {
    if (_listening) {
      return;
    }

    setState(() {
      _listening = true;
      _errorMessage = null;
      _latest = null;
    });

    // Subscribing triggers native onListen; cancelling triggers onCancel.
    _subscription = _service.ticks().listen(
      (event) {
        if (!mounted) {
          return;
        }
        setState(() {
          _latest = event;
        });
      },
      onError: (Object error) {
        if (!mounted) {
          return;
        }
        setState(() {
          _listening = false;
          if (error is PlatformException) {
            _errorMessage =
                'Platform error on EventChannel: ${error.message ?? error.code}';
          } else {
            _errorMessage = 'Unexpected EventChannel error: $error';
          }
        });
      },
      onDone: () {
        if (!mounted) {
          return;
        }
        setState(() {
          _listening = false;
        });
      },
    );
  }

  Future<void> _stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (!mounted) {
      return;
    }
    setState(() {
      _listening = false;
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latest = _latest;

    return Scaffold(
      appBar: AppBar(title: const Text('EventChannel sample')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Platform',
                    value: defaultTargetPlatform.name,
                  ),
                  _InfoRow(
                    label: 'Channel',
                    value: 'examples.flutter_native_calls/ticker',
                  ),
                  _InfoRow(
                    label: 'Listening',
                    value: _listening ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    label: 'Latest tick',
                    value: latest == null ? 'None yet' : '${latest.tick}',
                  ),
                  _InfoRow(
                    label: 'Native timestamp',
                    value: latest == null ? '—' : '${latest.timestampMs} ms',
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _listening ? null : _start,
                        child: const Text('Start listening'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _listening ? _stop : null,
                        child: const Text('Stop'),
                      ),
                      if (_listening) ...[
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
