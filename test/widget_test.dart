import 'package:flutter_test/flutter_test.dart';
import 'package:task_app/main.dart';

void main() {
  testWidgets('TaskApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskApp());
    expect(find.byType(TaskApp), findsOneWidget);
  });
}