import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_samples/src/app.dart';

void main() {
  testWidgets('renders the provider examples home', (tester) async {
    await tester.pumpWidget(const EcommerceApp());
    await tester.pumpAndSettle();

    expect(find.text('Ecommerce Samples'), findsOneWidget);
    expect(find.text('Shopify'), findsOneWidget);
    expect(find.text('BigCommerce'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Stripe'),
      300,
      scrollable: find.byType(Scrollable),
    );

    expect(find.text('Stripe'), findsOneWidget);
  });
}
