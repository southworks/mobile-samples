import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Hosts a view whose content is rendered entirely by native code.
class NativeViewScreen extends StatelessWidget {
  const NativeViewScreen({super.key});

  /// Must match the view type registered in Kotlin and Swift.
  static const String _viewType = 'examples.flutter_native_calls/native_view';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Embed native view')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('The box below is rendered by native code'),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const _NativeView(viewType: _viewType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NativeView extends StatelessWidget {
  const _NativeView({required this.viewType});

  final String viewType;

  @override
  Widget build(BuildContext context) {
    // Flutter picks the host widget; the pixels come from native code.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Native views are only available on Android and iOS in this '
              'example.',
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }
}
