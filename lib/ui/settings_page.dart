import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/backup_provider.dart';
import 'settings/view_models/subscriber_import_view_model.dart';
import 'settings/view_models/subscriber_export_view_model.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(subscriberImportViewModelProvider);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text('Subscribers', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Import a subscriber export JSON file. Only name, postal address, '
              'and postal code are imported, and all three must be nonempty strings. '
              'Exact duplicates are skipped. Existing records are kept.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: model.isBusy ||
                          model.preview != null ||
                          model.completePreview != null
                      ? null
                      : () async {
                          await model.selectFile();
                          if (!context.mounted || model.preview == null) return;
                          await showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                _ImportConfirmationDialog(model: model),
                          );
                          model.cancel();
                        },
                  icon: model.isBusy && model.completePreview == null
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.file_upload_outlined),
                  label: const Text('Import subscribers'),
                ),
                FilledButton.icon(
                  onPressed: model.isBusy ||
                          model.preview != null ||
                          model.completePreview != null
                      ? null
                      : () async {
                          await model.selectCompleteFile();
                          if (!context.mounted ||
                              model.completePreview == null) {
                            return;
                          }
                          await showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) =>
                                _CompleteImportConfirmationDialog(model: model),
                          );
                          model.cancelComplete();
                        },
                  icon: model.isBusy && model.preview == null
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.restore_page_outlined),
                  label: const Text('Import all'),
                ),
              ],
            ),
            if (model.error != null &&
                model.preview == null &&
                model.completePreview == null) ...[
              const SizedBox(height: 16),
              Text(
                model.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            if (model.result case final result?) ...[
              const SizedBox(height: 16),
              Text(
                '${result.inserted} ${result.inserted == 1 ? 'subscriber' : 'subscribers'} imported. '
                '${result.skipped} ${result.skipped == 1 ? 'duplicate' : 'duplicates'} skipped.',
              ),
            ],
            if (model.completeResult case final completeResult?) ...[
              const SizedBox(height: 16),
              Text(
                '${completeResult.subscribersInserted} ${completeResult.subscribersInserted == 1 ? 'subscriber' : 'subscribers'} and '
                '${completeResult.subscriptionsInserted} ${completeResult.subscriptionsInserted == 1 ? 'subscription' : 'subscriptions'}'
                '${completeResult.postalOfficesInserted > 0 ? ', and ${completeResult.postalOfficesInserted} ${completeResult.postalOfficesInserted == 1 ? 'postal office' : 'postal offices'}' : ''} imported. '
                '${completeResult.subscribersSkipped} ${completeResult.subscribersSkipped == 1 ? 'duplicate' : 'duplicates'} skipped.',
              ),
            ],
            const SizedBox(height: 24),
            const _SubscriberExportSection(),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const _DatabaseBackupSection(),
          ],
        ),
      ),
    );
  }
}

class _SubscriberExportSection extends ConsumerWidget {
  const _SubscriberExportSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(subscriberExportViewModelProvider);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export all subscribers, including archived records, as JSON. '
            'Only name, postal address, and postal code are used when importing.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: model.isBusy ? null : model.export,
            icon: model.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download_outlined),
            label: Text(
              model.isBusy ? 'Exporting subscribers…' : 'Export subscribers',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Export all subscribers and their full subscription history, '
            'including domestic/foreign status, contact details, and archived records. '
            'Can be restored using Import all.',
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: model.isBusy ? null : model.completeExport,
            icon: model.isBusy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.file_download_outlined),
            label: const Text('Export all'),
          ),
          if (model.message != null) ...[
            const SizedBox(height: 16),
            Text(model.message!),
          ],
          if (model.error != null) ...[
            const SizedBox(height: 16),
            Text(
              model.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImportConfirmationDialog extends StatelessWidget {
  const _ImportConfirmationDialog({required this.model});

  final SubscriberImportViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final preview = model.preview;
        return PopScope(
          canPop: !model.isBusy,
          child: AlertDialog(
            title: const Text('Import subscribers?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.filename ?? ''),
                  const SizedBox(height: 16),
                  Text('Total entries: ${preview?.total ?? 0}'),
                  Text('Subscribers to insert: ${preview?.toInsert ?? 0}'),
                  Text('Duplicates to skip: ${preview?.skipped ?? 0}'),
                  const SizedBox(height: 16),
                  Text(
                    preview?.toInsert == 0
                        ? 'No new subscribers to import'
                        : 'Are you sure you want to continue?',
                  ),
                  if (model.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      model.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: model.isBusy
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(preview?.toInsert == 0 ? 'Close' : 'Cancel'),
              ),
              if (preview != null && preview.toInsert > 0)
                FilledButton(
                  onPressed: model.isBusy
                      ? null
                      : () async {
                          await model.import();
                          if (context.mounted && model.result != null) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: model.isBusy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Import ${preview.toInsert} ${preview.toInsert == 1 ? 'subscriber' : 'subscribers'}',
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CompleteImportConfirmationDialog extends StatelessWidget {
  const _CompleteImportConfirmationDialog({required this.model});

  final SubscriberImportViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final preview = model.completePreview;
        final hasItemsToInsert = preview?.hasItemsToInsert ?? false;
        return PopScope(
          canPop: !model.isBusy,
          child: AlertDialog(
            title: const Text('Import all?'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(model.filename ?? ''),
                  const SizedBox(height: 16),
                  Text('Total subscribers: ${preview?.totalSubscribers ?? 0}'),
                  Text(
                    'Subscribers to insert: ${preview?.subscribersToInsert ?? 0}',
                  ),
                  Text(
                    'Duplicates to skip: ${preview?.subscribersSkipped ?? 0}',
                  ),
                  Text(
                    'Subscriptions to insert: ${preview?.totalSubscriptionsToInsert ?? 0}',
                  ),
                  if ((preview?.totalPostalOffices ?? 0) > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Total postal offices: ${preview?.totalPostalOffices ?? 0}',
                    ),
                    Text(
                      'Postal offices to insert: ${preview?.postalOfficesToInsert ?? 0}',
                    ),
                    Text(
                      'Rules to insert: ${preview?.totalRulesToInsert ?? 0}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    !hasItemsToInsert
                        ? 'No new records to import'
                        : 'Are you sure you want to continue?',
                  ),
                  if (model.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      model.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: model.isBusy
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(!hasItemsToInsert ? 'Close' : 'Cancel'),
              ),
              if (preview != null && hasItemsToInsert)
                FilledButton(
                  onPressed: model.isBusy
                      ? null
                      : () async {
                          await model.importComplete();
                          if (context.mounted && model.completeResult != null) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: model.isBusy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          preview.postalOfficesToInsert > 0
                              ? 'Import all'
                              : 'Import ${preview.subscribersToInsert} ${preview.subscribersToInsert == 1 ? 'subscriber' : 'subscribers'}',
                        ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DatabaseBackupSection extends ConsumerWidget {
  const _DatabaseBackupSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(backupCoordinatorProvider);

    return ListenableBuilder(
      listenable: coordinator,
      builder: (context, _) {
        final settings = coordinator.settings;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('Database Backup', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text(
            'Configure daily backups of the database and data. '
            'Backups are created when the app starts once per day. '
            'You can select Google Drive for Desktop, OneDrive for Desktop, or any folder. '
            'Backups are saved as verified zip archives containing both the SQLite database and a full JSON export. '
            'The 30 most recent daily backups are retained.',
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settings.isConfigured
                              ? settings.backupDirectory!
                              : 'No backup folder selected',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: settings.isConfigured
                                ? null
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: coordinator.isBackingUp
                            ? null
                            : coordinator.selectBackupDirectory,
                        icon: const Icon(Icons.folder_open),
                        label: Text(
                          settings.isConfigured
                              ? 'Change folder'
                              : 'Choose folder',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Daily backup on startup'),
                    subtitle: const Text(
                      'Automatically create a backup once per day when the application opens',
                    ),
                    value: settings.isEnabled,
                    onChanged: coordinator.isBackingUp
                        ? null
                        : (val) => coordinator.setEnabled(val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: coordinator.isBackingUp || !settings.isConfigured
                    ? null
                    : () => coordinator.runBackup(),
                icon: coordinator.isBackingUp
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.backup_outlined),
                label: Text(
                  coordinator.isBackingUp
                      ? 'Backup in progress…'
                      : 'Back up now',
                ),
              ),
              if (settings.lastBackupTimestamp != null)
                Text(
                  'Last backup: ${settings.lastBackupTimestamp} (${settings.lastBackupStatus})',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
          if (coordinator.lastSuccessMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              coordinator.lastSuccessMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ],
          if (coordinator.lastError != null) ...[
            const SizedBox(height: 12),
            Text(
              coordinator.lastError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      );
    },
  );
  }
}
