import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_push_notifications/app.dart';

void main() {
  testWidgets('shows startup error when Firebase is not configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const PushNotificationsApp(startupError: 'Firebase not configured'),
    );

    expect(find.text('Startup error'), findsOneWidget);
    expect(find.text('Firebase failed to initialize.'), findsOneWidget);
  });
}
