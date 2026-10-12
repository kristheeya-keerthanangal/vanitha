import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/loading_state.dart';
import '../shared/error_state.dart';
import '../shared/empty_state.dart';
import 'view_models/subscriber_details_view_model.dart';
import 'widgets/subscriber_identity_card.dart';
import 'widgets/subscriber_contact_card.dart';
import 'widgets/subscriber_address_card.dart';
import 'widgets/subscriber_subscriptions_section.dart';

class SubscriberDetailsPage extends ConsumerWidget {
  const SubscriberDetailsPage({super.key, required this.id});
  final int id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = subscriberDetailsViewModelProvider(id);
    final details = ref.watch(provider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Back to subscribers',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/subscribers');
                  }
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Subscriber details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: details.when(
            loading: () => const LoadingState(),
            error: (_, _) => ErrorState(
              message: 'Unable to load subscriber.',
              onRetry: () => ref.invalidate(provider),
            ),
            data: (value) => value == null
                ? const EmptyState(message: 'Subscriber not found.')
                : ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final subscriberDetails = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SubscriberIdentityCard(
                                subscriber: value.subscriber,
                              ),
                              const SizedBox(height: 16),
                              SubscriberContactCard(
                                subscriber: value.subscriber,
                              ),
                              const SizedBox(height: 16),
                              SubscriberAddressCard(
                                subscriber: value.subscriber,
                              ),
                            ],
                          );
                          final subscriptions = SubscriberSubscriptionsSection(
                            subscriptions: value.subscriptions,
                          );

                          if (constraints.maxWidth >= 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: subscriberDetails),
                                const SizedBox(width: 24),
                                Expanded(child: subscriptions),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              subscriberDetails,
                              const SizedBox(height: 24),
                              subscriptions,
                            ],
                          );
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
