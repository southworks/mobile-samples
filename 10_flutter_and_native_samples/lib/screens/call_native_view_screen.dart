import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/call_native_view_service.dart';

/// Flutter host that asks native code to open a full-screen profile UI.
class CallNativeViewScreen extends StatefulWidget {
  const CallNativeViewScreen({super.key, this.service});

  final CallNativeViewService? service;

  @override
  State<CallNativeViewScreen> createState() => _CallNativeViewScreenState();
}

class _CallNativeViewScreenState extends State<CallNativeViewScreen> {
  late final CallNativeViewService _service =
      widget.service ?? CallNativeViewService();

  String? _errorMessage;
  bool _opening = false;

  Future<void> _openNativeProfile() async {
    if (_opening) {
      return;
    }

    setState(() {
      _opening = true;
      _errorMessage = null;
    });

    try {
      // Flutter only requests navigation; the Activity/UIViewController is native.
      await _service.openProfile();
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Platform error while opening native view: ${error.message ?? error.code}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unexpected error while opening native view: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Call native view')),
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
                    label: 'Native screen',
                    value: defaultTargetPlatform == TargetPlatform.iOS
                        ? 'UIViewController'
                        : 'Activity',
                  ),
                  _InfoRow(
                    label: 'State',
                    value: _opening ? 'Opening native screen…' : 'Idle',
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _opening ? null : _openNativeProfile,
                    child: const Text('Open native profile'),
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
