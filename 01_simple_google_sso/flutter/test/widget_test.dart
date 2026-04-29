import 'package:authors_collection/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows startup error screen when firebase is not configured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const AuthorsCollectionApp(startupError: 'Firebase missing'),
    );

    expect(
      find.text('Falta completar la configuración de Firebase'),
      findsOneWidget,
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
