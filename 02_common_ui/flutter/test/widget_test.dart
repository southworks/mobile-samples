import 'package:flutter_test/flutter_test.dart';

import 'package:common_ui/main.dart';

void main() {
  testWidgets('App shows Basics tab by default', (WidgetTester tester) async {
    await tester.pumpWidget(const CommonUiApp());

    expect(find.text('Basics'), findsWidgets);
    expect(find.text('Layout'), findsOneWidget);
    expect(find.text('Navigation'), findsOneWidget);
    expect(find.text('Inputs'), findsOneWidget);
    expect(find.text('Text with title font.'), findsOneWidget);
  });
}
