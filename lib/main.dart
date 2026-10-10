import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'screens/sign_in_screen.dart';
import 'services/local_storage_service.dart';
import 'services/sample_data_bridge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = LocalStorageService();
  await storageService.initAndSeedIfNeeded();
  await loadLeilaSampleData(storageService);

  await appThemeController.load();

  runApp(ProjectSlaApp(storageService: storageService));
}

class ProjectSlaApp extends StatelessWidget {
  final LocalStorageService storageService;

  const ProjectSlaApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeController,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Project & SLA Task Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: mode,
          home: SignInScreen(storageService: storageService),
        );
      },
    );
  }
}
