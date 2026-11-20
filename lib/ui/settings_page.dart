import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
              'Import a JSON array with subscriber_name, address, and pincode. '
              'All three fields must be nonempty strings. '
              'Exact duplicates are skipped. Existing records are kept.',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: model.isBusy || model.preview != null
                  ? null
                  : () async {
                      await model.selectFile();
                      if (!context.mounted || model.preview == null) return;
                      await showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => _ImportConfirmationDialog(model: model),
                      );
                      model.cancel();
                    },
              icon: model.isBusy
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: const Text('Import subscribers'),
            ),
            if (model.error != null && model.preview == null) ...[
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
            const SizedBox(height: 24),
            const _SubscriberExportSection(),
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
            'Includes all subscriber fields, IDs, and timestamps. '
            'This complete export cannot be loaded by the three-field importer above.',
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
