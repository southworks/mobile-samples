import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/biometric_auth_result.dart';
import '../models/biometric_status.dart';
import '../services/biometric_auth_service.dart';

/// Demo screen that keeps UI/state in Flutter and delegates biometrics to native.
class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key, this.authService});

  final BiometricAuthService? authService;

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen>
    with WidgetsBindingObserver {
  late final BiometricAuthService _authService =
      widget.authService ?? BiometricAuthService();

  BiometricStatus? _status;
  BiometricAuthResult? _lastResult;
  String? _errorMessage;
  bool _unlocked = false;
  bool _statusLoading = false;
  bool _authenticationInProgress = false;
  bool _callingNative = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the OS cancels the prompt on backgrounding, clear Flutter's in-progress flag.
    if (state == AppLifecycleState.resumed &&
        _authenticationInProgress &&
        !_callingNative) {
      setState(() {
        _authenticationInProgress = false;
      });
    }
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _statusLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await _authService.getStatus();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = status;
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Platform error while checking biometrics: ${error.message ?? error.code}';
      });
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Invalid native status payload: ${error.message}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unexpected error while checking biometrics: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _statusLoading = false;
        });
      }
    }
  }

  Future<void> _authenticate() async {
    if (_authenticationInProgress) {
      return;
    }

    setState(() {
      _authenticationInProgress = true;
      _callingNative = true;
      _errorMessage = null;
      _lastResult = null;
    });

    try {
      // Flutter sends the authentication request, but does not access biometric APIs.
      final result = await _authService.authenticate(
        reason: 'Authenticate to access the protected content',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _lastResult = result;
        if (result.success) {
          _unlocked = true;
        }
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            'Platform error during authentication: ${error.message ?? error.code}';
      });
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Invalid native auth payload: ${error.message}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Unexpected authentication error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _authenticationInProgress = false;
          _callingNative = false;
        });
      }
    }
  }

  void _lockAgain() {
    // Lock state lives only in Flutter; no native call is required.
    setState(() {
      _unlocked = false;
      _lastResult = null;
      _errorMessage = null;
    });
  }

  String get _platformLabel {
    if (kIsWeb) {
      return 'web';
    }
    return defaultTargetPlatform.name;
  }

  bool get _canAuthenticate {
    final status = _status;
    return status != null &&
        status.available &&
        !_authenticationInProgress &&
        !_statusLoading;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Native biometric auth')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Status',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Platform', value: _platformLabel),
                _InfoRow(
                  label: 'Biometric available',
                  value: _statusLoading
                      ? 'Checking…'
                      : (_status?.available.toString() ?? 'Undefined'),
                ),
                _InfoRow(
                  label: 'Biometric type',
                  value: _status?.type.label ?? 'Undefined',
                ),
                if (_status?.reason != null)
                  _InfoRow(
                    label: 'Unavailable reason',
                    value: _status!.reason!,
                  ),
                _InfoRow(
                  label: 'Auth result',
                  value: _lastResult?.displayLabel ?? 'Undefined',
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonal(
                      onPressed: _statusLoading || _authenticationInProgress
                          ? null
                          : _refreshStatus,
                      child: const Text('Check biometric availability'),
                    ),
                    FilledButton(
                      onPressed: _canAuthenticate ? _authenticate : null,
                      child: const Text('Authenticate with biometrics'),
                    ),
                  ],
                ),
                if (_callingNative) ...[
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      // The system prompt itself is drawn natively (Kotlin/Swift).
                      Text('Calling native authentication…'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (_unlocked) ...[
            const SizedBox(height: 16),
            _Section(
              title: 'Protected content',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Protected content unlocked',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This section is rendered by Flutter after native '
                    'authentication succeeds.',
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: _lockAgain,
                    child: const Text('Lock again'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
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
