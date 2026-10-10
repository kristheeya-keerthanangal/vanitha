import 'package:flutter/material.dart';
import '../../../data/app_database.dart';
import 'details_card.dart';

class SubscriberIdentityCard extends StatelessWidget {
  const SubscriberIdentityCard({super.key, required this.subscriber});
  final Subscriber subscriber;
  @override
  Widget build(BuildContext context) => DetailsCard(
    title: 'Subscriber details',
    fields: {
      'Subscriber number': subscriber.displayNumber,
      'Name': subscriber.name,
      'Type': subscriber.subscriberType == 'individual'
          ? 'Individual'
          : 'Organization',
      'Created': subscriber.createdAt,
      'Updated': subscriber.updatedAt,
    },
  );
}
