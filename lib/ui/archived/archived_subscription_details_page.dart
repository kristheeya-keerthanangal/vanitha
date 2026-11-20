import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../shared/date_time_format.dart';
import '../shared/empty_state.dart';
import '../shared/error_state.dart';
import '../shared/loading_state.dart';
import '../subscribers/widgets/details_card.dart';
import '../subscribers/widgets/subscriber_identity_card.dart';
import '../subscribers/widgets/subscription_details_card.dart';
import 'view_models/archived_subscriptions_view_model.dart';

class ArchivedSubscriptionDetailsPage extends ConsumerWidget {
  const ArchivedSubscriptionDetailsPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = archivedSubscriptionDetailsViewModelProvider(id);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to archived subscriptions',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/archived');
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Archived subscription details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ref
              .watch(provider)
              .when(
                loading: () => const LoadingState(),
                error: (_, _) => ErrorState(
                  message: 'Unable to load archived subscription.',
                  onRetry: () => ref.invalidate(provider),
                ),
                data: (value) => value == null
                    ? const EmptyState(
                        message: 'Archived subscription not found.',
                      )
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          SubscriberIdentityCard(subscriber: value.subscriber),
                          const SizedBox(height: 16),
                          SubscriptionDetailsCard(
                            subscription: value.subscription,
                            canArchive: false,
                          ),
                          const SizedBox(height: 16),
                          DetailsCard(
                            title: 'Archive information',
                            fields: {
                              'Archived at': formatIstDateTime(
                                value.subscription.archivedAt!,
                              ),
                              'Created at': formatIstDateTime(
                                value.subscription.createdAt,
                              ),
                              'Updated at': formatIstDateTime(
                                value.subscription.updatedAt,
                              ),
                            },
                          ),
                        ],
                      ),
              ),
        ),
      ],
    );
  }
}
