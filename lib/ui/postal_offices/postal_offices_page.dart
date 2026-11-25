import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../shared/empty_state.dart';
import '../shared/error_state.dart';
import '../shared/loading_state.dart';
import '../subscribers/view_models/subscribers_view_model.dart';
import 'view_models/postal_offices_view_model.dart';

class PostalOfficesPage extends ConsumerWidget {
  const PostalOfficesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(postalOfficesViewModelProvider);

    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(
                  'Postal offices',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await context.push('/postal-offices/new');
                    if (context.mounted) {
                      model.refresh();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add postal office'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (model.loading)
              const SizedBox(height: 200, child: LoadingState())
            else if (model.error != null)
              ErrorState(message: model.error!, onRetry: model.refresh)
            else if (model.offices.isEmpty)
              const EmptyState(
                message:
                    'No postal offices configured. Add your first postal office to get started.',
              )
            else
              Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: model.offices.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final office = model.offices[index];
                    final ruleCount = model.ruleCounts[office.id] ?? 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        office.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Text(
                              '$ruleCount ${ruleCount == 1 ? 'rule' : 'rules'} configured',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: office.isActive
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                office.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: office.isActive
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: 'Edit office',
                            onPressed: () async {
                              await context.push('/postal-offices/${office.id}');
                              if (context.mounted) model.refresh();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete office',
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () => _confirmDelete(context, ref, model, office.id, office.name),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await context.push('/postal-offices/${office.id}');
                        if (context.mounted) model.refresh();
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PostalOfficesViewModel model,
    int id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete postal office?'),
        content: Text(
          'Are you sure you want to delete "$name"? All associated pincode rules will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await model.deleteOffice(id);
      try {
        ref.read(subscribersViewModelProvider).refresh();
      } catch (_) {}
    }
  }
}
