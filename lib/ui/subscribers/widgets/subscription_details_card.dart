import 'package:flutter/material.dart';
import '../../../data/app_database.dart';
import 'details_card.dart';

class SubscriptionDetailsCard extends StatelessWidget {
  const SubscriptionDetailsCard({super.key, required this.subscription});
  final Subscription subscription;
  @override
  Widget build(BuildContext context) => DetailsCard(
    title: 'Subscription #${subscription.id}',
    fields: {
      'Edition': subscription.edition == 'online' ? 'Online' : 'Offline',
      'Plan': switch (subscription.planType) {
        'annual' => 'Annual',
        'multi_year' => 'Multi-year',
        _ => 'Lifetime',
      },
      'Duration': '${subscription.durationYears} years',
      'Start date': subscription.startDate,
      'Expiry date': subscription.expiryDate,
      'Payment': subscription.paymentStatus == 'paid' ? 'Paid' : 'Unpaid',
    },
  );
}
