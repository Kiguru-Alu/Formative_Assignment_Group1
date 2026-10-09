import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management_app/main.dart';
import 'package:task_management_app/services/local_storage_service.dart';

void main() {
  testWidgets('App starts on the profile picker', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService();
    await storage.initAndSeedIfNeeded();

    await tester.pumpWidget(ProjectSlaApp(storageService: storage));
    await tester.pumpAndSettle();

    expect(find.text('Select your profile'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
