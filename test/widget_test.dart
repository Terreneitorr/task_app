import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';

void main() {
  testWidgets('TaskApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(TaskApp() as Widget);
    expect(find.byType(TaskApp), findsOneWidget);
  });
}

class TaskApp {
}