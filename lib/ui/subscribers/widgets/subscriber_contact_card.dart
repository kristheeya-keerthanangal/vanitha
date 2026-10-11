import 'package:flutter/material.dart';
import '../../../data/app_database.dart';
import 'details_card.dart';

class SubscriberContactCard extends StatelessWidget {
  const SubscriberContactCard({super.key, required this.subscriber});
  final Subscriber subscriber;
  @override
  Widget build(BuildContext context) => DetailsCard(
    title: 'Contact details',
    fields: {'Email': subscriber.email, 'Phone': subscriber.phone},
  );
}
