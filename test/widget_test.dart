import 'package:flutter_test/flutter_test.dart';
import 'package:task_management_app/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskTrackerApp());
    expect(find.text('Tasks'), findsOneWidget);
  });
}