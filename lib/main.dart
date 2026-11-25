import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/backup_provider.dart';
import 'providers/database_provider.dart';
import 'providers/router_provider.dart';
import 'theme/app_theme.dart';
import 'ui/backup/backup_exit_overlay.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    final coordinator = ref.read(backupCoordinatorProvider);
    _lifecycleListener = AppLifecycleListener(
      onExitRequested: coordinator.handleExitRequest,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupCoordinatorProvider).checkAndRunDailyBackup();
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolving the repository initializes its database dependency at startup.
    ref.watch(subscriberRepositoryProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => BackupExitOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
