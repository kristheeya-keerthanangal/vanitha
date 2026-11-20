import 'package:material_ui/material_ui.dart';
import '../../../data/app_database.dart';
import '../../../data/subscription_archive.dart';
import '../../shared/empty_state.dart';
import 'subscription_details_card.dart';

class SubscriberSubscriptionsSection extends StatelessWidget {
  const SubscriberSubscriptionsSection({
    super.key,
    required this.subscriptions,
  });
  final List<Subscription> subscriptions;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Subscriptions', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (subscriptions.isEmpty)
        const EmptyState(message: 'No subscriptions.')
      else
        for (final subscription in subscriptions)
          SubscriptionDetailsCard(
            subscription: subscription,
            canArchive: subscription.id == latestSubscriptionId(subscriptions),
          ),
    ],
  );
}
