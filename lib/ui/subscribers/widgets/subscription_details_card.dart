import 'package:material_ui/material_ui.dart';
import '../../../data/app_database.dart';
import 'details_card.dart';
import 'delete_subscription_button.dart';

class SubscriptionDetailsCard extends StatelessWidget {
  const SubscriptionDetailsCard({
    super.key,
    required this.subscription,
    required this.canArchive,
  });
  final Subscription subscription;
  final bool canArchive;
  @override
  Widget build(BuildContext context) => DetailsCard(
    title: 'Subscription #${subscription.id}',
    trailing: canArchive
        ? DeleteSubscriptionButton(subscription: subscription)
        : null,
    fields: {
      'Edition': subscription.edition == 'online' ? 'Online' : 'Offline',
      'Plan': switch (subscription.planType) {
        'annual' => 'Annual',
        'multi_year' => 'Multi-year',
        _ => 'Lifetime',
      },
      'Duration': '${subscription.durationYears} years',
      'Start month': subscription.startDate,
      'Expiry month': subscription.expiryDate,
    },
  );
}
