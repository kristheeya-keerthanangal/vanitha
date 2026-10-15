import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/subscriber_repository.dart';
import '../shared/empty_state.dart';
import '../shared/error_state.dart';
import '../shared/loading_state.dart';
import 'view_models/mailing_list_view_model.dart';

class MailingListPage extends ConsumerWidget {
  const MailingListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(mailingListViewModelProvider);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Mailing list',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh mailing list',
                        onPressed: model.loading ? null : model.refresh,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MailingSettings(model: model),
                  if (!model.loading && model.error == null) ...[
                    const SizedBox(height: 24),
                    Text('Subscribers: ${model.total}'),
                    if (model.incompleteCount > 0) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${model.incompleteCount} subscribers have incomplete mailing details.',
                              ),
                              const Text(
                                'An address or PIN code is missing or blank.',
                              ),
                              TextButton(
                                onPressed: () =>
                                    _showIncomplete(context, model),
                                child: const Text('View affected subscribers'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          if (model.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: LoadingState(),
            )
          else if (model.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ErrorState(message: model.error!, onRetry: model.refresh),
            )
          else if (model.total == 0)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(message: 'No subscribers in the mailing list.'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              sliver: SliverList.builder(
                itemCount: model.rows.length,
                itemBuilder: (context, index) => _MailingSubscriberTile(
                  entry: model.rows[index],
                  onTap: () => _openSubscriber(
                    context,
                    model,
                    model.rows[index].subscriberId,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openSubscriber(
    BuildContext context,
    MailingListViewModel model,
    int id,
  ) async {
    await context.push('/subscribers/$id');
    if (context.mounted) await model.refresh();
  }

  Future<void> _showIncomplete(
    BuildContext context,
    MailingListViewModel model,
  ) async {
    final affected = model.incompleteRows;
    final id = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incomplete mailing details (${affected.length})'),
        content: SizedBox(
          width: 520,
          height: 360,
          child: ListView.builder(
            itemCount: affected.length,
            itemBuilder: (context, index) => _MailingSubscriberTile(
              entry: affected[index],
              onTap: () =>
                  Navigator.of(context).pop(affected[index].subscriberId),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (id != null && context.mounted) {
      await _openSubscriber(context, model, id);
    }
  }
}

class _MailingSubscriberTile extends StatelessWidget {
  const _MailingSubscriberTile({required this.entry, required this.onTap});

  final MailingListEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    key: ValueKey(entry.subscriberId),
    contentPadding: EdgeInsets.zero,
    title: Text(entry.name),
    subtitle: Text(
      '${entry.isAddressMissing ? 'Missing address' : entry.postalAddress}\n'
      '${entry.isPostalCodeMissing ? 'Missing PIN code' : entry.postalCode}',
    ),
    isThreeLine: true,
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _MailingSettings extends StatelessWidget {
  const _MailingSettings({required this.model});

  final MailingListViewModel model;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      _setting<String>(
        label: 'Paper',
        value: 'A4',
        options: const {'A4': 'A4'},
      ),
      _setting<MailingOrientation>(
        label: 'Orientation',
        value: model.orientation,
        options: const {
          MailingOrientation.portrait: 'Portrait',
          MailingOrientation.landscape: 'Landscape',
        },
        onChanged: model.changeOrientation,
      ),
      _setting<MailingLabelSize>(
        label: 'Label size',
        value: model.labelSize,
        options: {for (final size in MailingLabelSize.values) size: size.label},
        onChanged: model.changeLabelSize,
      ),
      _setting<MailingOrdering>(
        label: 'Ordering',
        value: model.ordering,
        options: const {
          MailingOrdering.name: 'Name',
          MailingOrdering.postalCode: 'PIN code',
        },
        onChanged: model.changeOrdering,
      ),
      _setting<String>(
        label: 'Font size',
        value: 'Automatic',
        options: const {'Automatic': 'Automatic'},
      ),
      _setting<bool>(
        label: 'Cutting guides',
        value: model.cuttingGuides,
        options: const {true: 'On', false: 'Off'},
        onChanged: model.changeCuttingGuides,
      ),
    ],
  );

  Widget _setting<T>({
    required String label,
    required T value,
    required Map<T, String> options,
    ValueChanged<T>? onChanged,
  }) => SizedBox(
    width: 220,
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: [
            for (final option in options.entries)
              DropdownMenuItem(value: option.key, child: Text(option.value)),
          ],
          onChanged: onChanged == null
              ? null
              : (value) {
                  if (value != null) onChanged(value);
                },
        ),
      ),
    ),
  );
}
