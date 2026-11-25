import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/backup_provider.dart';

class BackupExitOverlay extends ConsumerWidget {
  const BackupExitOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(backupCoordinatorProvider);

    return ListenableBuilder(
      listenable: coordinator,
      builder: (context, _) => Stack(
        children: [
          child,
          if (coordinator.isExitPending)
            PopScope(
              canPop: false,
              child: Material(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 28,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: 36,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Backup in progress, please wait...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The application will close automatically once the backup completes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
