import 'package:flutter/material.dart';

import 'package:flutter_push_notifications/di/dependencies.dart';
import 'package:flutter_push_notifications/features/push/presentation/views/home_page.dart';
import 'package:flutter_push_notifications/shared/theme/app_theme.dart';
import 'package:flutter_push_notifications/shared/widgets/startup_error_page.dart';

class PushNotificationsApp extends StatelessWidget {
  const PushNotificationsApp({this.startupError, super.key});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Push Notifications Sample',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: startupError == null
          ? HomePage(
              clockViewModel: Dependencies.makeClockViewModel(),
              pushViewModel: Dependencies.makePushViewModel(),
            )
          : StartupErrorPage(error: startupError!),
    );
  }
}
