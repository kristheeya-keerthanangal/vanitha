import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/subscriber_repository.dart';
import '../shared/loading_state.dart';
import '../shared/error_state.dart';
import '../shared/empty_state.dart';
import 'view_models/subscribers_view_model.dart';
import 'widgets/subscribers_toolbar.dart';
import 'widgets/subscribers_table.dart';

class SubscribersPage extends ConsumerWidget {
  const SubscribersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(subscribersViewModelProvider);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SubscribersToolbar(
              search: model.search,
              onSearch: model.searchChanged,
            ),
            const SizedBox(height: 36),
            SegmentedButton<SubscriberFilter>(
              segments: const [
                ButtonSegment(value: SubscriberFilter.all, label: Text('All')),
                ButtonSegment(
                  value: SubscriberFilter.active,
                  label: Text('Active'),
                ),
                ButtonSegment(
                  value: SubscriberFilter.expired,
                  label: Text('Expired'),
                ),
              ],
              selected: {model.selectedFilter},
              onSelectionChanged: (selection) =>
                  model.filterChanged(selection.single),
            ),
            const SizedBox(height: 24),
            if (model.loading)
              const SizedBox(height: 160, child: LoadingState())
            else if (model.error != null)
              ErrorState(message: model.error!, onRetry: model.refresh)
            else if (model.total == 0)
              EmptyState(
                message: switch (model.selectedFilter) {
                  SubscriberFilter.all when model.search.trim().isEmpty =>
                    'Add your first subscriber to get started.',
                  SubscriberFilter.all => 'No matching subscribers.',
                  SubscriberFilter.active => 'No active subscribers.',
                  SubscriberFilter.expired => 'No expired subscribers.',
                },
              )
            else
              SubscribersTable(
                model: model,
                onOpen: (id) => context.push('/subscribers/$id'),
              ),
          ],
        ),
      ),
    );
  }
}
