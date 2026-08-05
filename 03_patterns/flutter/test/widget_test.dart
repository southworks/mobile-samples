import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/main.dart';
import 'package:patterns/shared/storage/shared_task_store.dart';

void main() {
  setUp(() {
    final seedFlags = SeedFlagStore()
      ..setBool(SharedTaskStore.seedPopulatedKey, true);
    SharedTaskStore.configureShared(SharedTaskStore(seedFlags: seedFlags));
  });

  tearDown(SharedTaskStore.resetShared);

  testWidgets('Root page shows MVVM and Clean Arc entries', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());

    expect(find.text('Task Manager'), findsOneWidget);
    expect(find.text('MVVM Task Manager'), findsOneWidget);
    expect(find.text('Clean Arc Task Manager'), findsOneWidget);
  });

  testWidgets('Navigates into MVVM task list', (tester) async {
    SharedTaskStore.shared.createTask(title: 'Demo task');

    await tester.pumpWidget(const TaskManagerApp());
    await tester.tap(find.text('MVVM Task Manager'));
    await tester.pumpAndSettle();

    expect(find.text('MVVM'), findsOneWidget);
    expect(find.text('Demo task'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
