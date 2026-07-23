import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/native_computation_result.dart';
import '../services/native_computation_service.dart';

/// Sends a request to native code, waits for the async result, then shows it.
class AsyncTaskScreen extends StatefulWidget {
  const AsyncTaskScreen({super.key, this.computationService});

  final NativeComputationService? computationService;

  @override
  State<AsyncTaskScreen> createState() => _AsyncTaskScreenState();
}

class _AsyncTaskScreenState extends State<AsyncTaskScreen> {
  late final NativeComputationService _service =
      widget.computationService ?? NativeComputationService();

  NativeComputationResult? _result;
  String? _errorMessage;
  bool _running = false;

  Future<void> _run() async {
    if (_running) {
      return;
    }

    setState(() {
      _running = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      // Flutter awaits here; the native side sleeps 1–10s on a background thread.
      final result = await _service.runDelayedTask();
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Platform error during computation: ${error.message ?? error.code}';
      });
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Invalid native result payload: ${error.message}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unexpected computation error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _running = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Async native task')),
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
                    label: 'Native task',
                    value: 'Random delay (1–10 s)',
                  ),
                  _InfoRow(
                    label: 'State',
                    value: _running ? 'Processing on native thread…' : 'Idle',
                  ),
                  _InfoRow(
                    label: 'Result',
                    value: _result?.result ?? 'None yet',
                  ),
                  _InfoRow(
                    label: 'Native duration',
                    value: _result == null ? '—' : '${_result!.durationMs} ms',
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
                        onPressed: _running ? null : _run,
                        child: const Text('Run native computation'),
                      ),
                      if (_running) ...[
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
