import 'package:flutter/material.dart';

import 'async_task_screen.dart';
import 'biometric_auth_screen.dart';
import 'call_native_view_screen.dart';
import 'event_channel_screen.dart';
import 'native_view_screen.dart';
import 'wifi_status_screen.dart';

/// Entry point list that links to each native-interoperability sample.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<_SampleEntry> _samples = <_SampleEntry>[
    _SampleEntry(
      title: 'Biometric auth',
      subtitle: 'Flutter calls code native biometric authentication',
      icon: Icons.fingerprint,
      builder: (context) => const BiometricAuthScreen(),
    ),
    _SampleEntry(
      title: 'Embed native view',
      subtitle: 'Flutter embeds a view rendered by native code',
      icon: Icons.widgets_outlined,
      builder: (context) => const NativeViewScreen(),
    ),
    _SampleEntry(
      title: 'Call native view',
      subtitle: 'MethodChannel opens a native Activity / UIViewController',
      icon: Icons.open_in_new,
      builder: (context) => const CallNativeViewScreen(),
    ),
    _SampleEntry(
      title: 'Async native task',
      subtitle: 'Flutter runs native work and shows the async result',
      icon: Icons.sync,
      builder: (context) => const AsyncTaskScreen(),
    ),
    _SampleEntry(
      title: 'EventChannel sample',
      subtitle: 'Native pushes a tick stream; Flutter listens and cancels',
      icon: Icons.timeline,
      builder: (context) => const EventChannelScreen(),
    ),
    _SampleEntry(
      title: 'Pigeon sample',
      subtitle: 'Type-safe WifiStatus generated for Dart, Kotlin and Swift',
      icon: Icons.wifi,
      builder: (context) => const WifiStatusScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter + native calls')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _samples.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sample = _samples[index];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: Icon(sample.icon),
              title: Text(sample.title),
              subtitle: Text(sample.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: sample.builder)),
            ),
          );
        },
      ),
    );
  }
}

class _SampleEntry {
  const _SampleEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
