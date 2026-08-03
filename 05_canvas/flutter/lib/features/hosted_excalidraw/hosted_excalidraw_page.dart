import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HostedExcalidrawPage extends StatefulWidget {
  const HostedExcalidrawPage({super.key});

  @override
  State<HostedExcalidrawPage> createState() => _HostedExcalidrawPageState();
}

class _HostedExcalidrawPageState extends State<HostedExcalidrawPage> {
  String _pageTitle = 'Loading...';
  bool _isLoading = false;
  int _progress = 0;
  String? _diagnosticMessage;
  InAppWebViewController? _webViewController;
  late final Uri _siteUri = HostedExcalidrawConfig.initialUri;
  late String _currentUrl = _siteUri.toString();

  Future<void> _collectDiagnostics() async {
    final controller = _webViewController;
    if (controller == null) {
      return;
    }

    try {
      final result = await controller.evaluateJavascript(
        source: '''
(() => {
  const bodyText = document.body?.innerText?.trim()?.replace(/\\s+/g, ' ').slice(0, 240) ?? '';
  return JSON.stringify({
    readyState: document.readyState,
    title: document.title,
    url: location.href,
    bodyText,
    canvasCount: document.querySelectorAll('canvas').length,
    hasLoadingText: /loading canvas/i.test(bodyText),
    userAgent: navigator.userAgent
  });
})()
''',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _diagnosticMessage = result?.toString() ?? 'No diagnostics returned';
      });
    } catch (error) {
      developer.log(
        'Diagnostics failed: $error',
        name: 'HostedExcalidrawPage',
        level: 1000,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _diagnosticMessage = 'Diagnostics failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _isLoading ? Colors.orange : Colors.green;
    final statusIcon = _isLoading
        ? Icons.autorenew_rounded
        : Icons.check_circle_outline;
    final statusLabel = _isLoading ? 'Loading' : 'Ready';

    return Scaffold(
      appBar: AppBar(title: const Text('Hosted Excalidraw')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _pageTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri.uri(_siteUri)),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      allowsInlineMediaPlayback: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsBackForwardNavigationGestures: false,
                      isInspectable: kDebugMode,
                    ),
                    onLoadStart: (controller, url) {
                      setState(() {
                        _isLoading = true;
                        _progress = 0;
                        if (url != null) {
                          _currentUrl = url.toString();
                        }
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress = progress;
                        if (progress >= 100) {
                          _isLoading = false;
                          _pageTitle = _pageTitle == 'Loading...'
                              ? 'Excalidraw'
                              : _pageTitle;
                          unawaited(
                            Future<void>.delayed(
                              const Duration(seconds: 2),
                              _collectDiagnostics,
                            ),
                          );
                        }
                      });
                    },
                    onTitleChanged: (controller, title) {
                      setState(() {
                        _pageTitle = title ?? 'Excalidraw';
                      });
                    },
                    onLoadStop: (controller, url) {
                      setState(() {
                        _isLoading = false;
                        _pageTitle = _pageTitle == 'Loading...'
                            ? 'Excalidraw'
                            : _pageTitle;
                        if (url != null) {
                          _currentUrl = url.toString();
                        }
                      });
                      unawaited(
                        Future<void>.delayed(
                          const Duration(seconds: 2),
                          _collectDiagnostics,
                        ),
                      );
                    },
                    onReceivedHttpError: (controller, request, response) {
                      if (request.isForMainFrame != true) {
                        return;
                      }

                      developer.log(
                        'HTTP ${response.statusCode} loading ${request.url}',
                        name: 'HostedExcalidrawPage',
                        level: 1000,
                      );

                      setState(() {
                        _isLoading = false;
                        _pageTitle = 'HTTP ${response.statusCode}';
                      });
                    },
                    onReceivedError: (controller, request, error) {
                      if (request.isForMainFrame != true) {
                        return;
                      }

                      developer.log(
                        'Failed to load ${request.url}: ${error.description}',
                        name: 'HostedExcalidrawPage',
                        level: 1000,
                      );

                      setState(() {
                        _isLoading = false;
                        _pageTitle = 'Failed to Load';
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      if (consoleMessage.messageLevel ==
                              ConsoleMessageLevel.ERROR ||
                          consoleMessage.messageLevel ==
                              ConsoleMessageLevel.WARNING) {
                        developer.log(
                          consoleMessage.message,
                          name: 'HostedExcalidrawConsole',
                          level:
                              consoleMessage.messageLevel ==
                                  ConsoleMessageLevel.ERROR
                              ? 1000
                              : 900,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading) ...[
              LinearProgressIndicator(
                value: _progress > 0 ? _progress / 100 : null,
              ),
              const SizedBox(height: 12),
            ],
            Text(
              'Current URL: $_currentUrl',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Base URL, room y otros query params se hardcodean en HostedExcalidrawConfig.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (_diagnosticMessage case final value?) ...[
              const SizedBox(height: 8),
              Text(
                'Diagnostics: $value',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class HostedExcalidrawConfig {
  static const String _baseUrl = 'https://giving-foxhound-top.ngrok-free.app';

  // Hardcode room/key/otros params aqui cuando tu deploy self-hosted los use.
  static const String? room = null;
  static const String? roomKey = null;
  static const Map<String, String> queryParameters = <String, String>{};

  static Uri get initialUri {
    final uri = Uri.parse(_baseUrl);
    final params = <String, String>{...uri.queryParameters, ...queryParameters};

    if (room case final value?) {
      params['room'] = value;
    }
    if (roomKey case final value?) {
      params['key'] = value;
    }

    return uri.replace(queryParameters: params.isEmpty ? null : params);
  }
}
