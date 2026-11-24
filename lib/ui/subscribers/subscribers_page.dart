import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/subscriber_repository.dart';
import '../shared/loading_state.dart';
import '../shared/error_state.dart';
import '../shared/empty_state.dart';
import 'view_models/subscribers_view_model.dart';
import 'widgets/subscribers_toolbar.dart';
import 'widgets/pincode_lookup_card.dart';
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
            PincodeLookupCard(pincode: model.search),
            const SizedBox(height: 36),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SegmentedButton<SubscriberFilter>(
                  segments: const [
                    ButtonSegment(
                      value: SubscriberFilter.all,
                      label: Text('All'),
                    ),
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
                SegmentedButton<SubscriberOriginFilter>(
                  segments: const [
                    ButtonSegment(
                      value: SubscriberOriginFilter.all,
                      label: Text('All'),
                    ),
                    ButtonSegment(
                      value: SubscriberOriginFilter.domestic,
                      label: Text('Domestic'),
                    ),
                    ButtonSegment(
                      value: SubscriberOriginFilter.foreign,
                      label: Text('Foreign'),
                    ),
                  ],
                  selected: {model.selectedOriginFilter},
                  onSelectionChanged: (selection) =>
                      model.originFilterChanged(selection.single),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (model.loading)
              const SizedBox(height: 160, child: LoadingState())
            else if (model.error != null)
              ErrorState(message: model.error!, onRetry: model.refresh)
            else if (model.total == 0)
              EmptyState(message: _emptyMessage(model))
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

  String _emptyMessage(SubscribersViewModel model) {
    if (model.search.trim().isNotEmpty) return 'No matching subscribers.';
    final origin = model.selectedOriginFilter;
    final status = model.selectedFilter;
    if (origin == SubscriberOriginFilter.foreign) {
      return switch (status) {
        SubscriberFilter.all => 'No foreign subscribers.',
        SubscriberFilter.active => 'No active foreign subscribers.',
        SubscriberFilter.expired => 'No expired foreign subscribers.',
      };
    }
    if (origin == SubscriberOriginFilter.domestic) {
      return switch (status) {
        SubscriberFilter.all => 'No domestic subscribers.',
        SubscriberFilter.active => 'No active domestic subscribers.',
        SubscriberFilter.expired => 'No expired domestic subscribers.',
      };
    }
    return switch (status) {
      SubscriberFilter.all => 'Add your first subscriber to get started.',
      SubscriberFilter.active => 'No active subscribers.',
      SubscriberFilter.expired => 'No expired subscribers.',
    };
  }
}
