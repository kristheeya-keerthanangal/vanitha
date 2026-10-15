import 'package:flutter/material.dart';
import '../../../data/app_database.dart';
import 'details_card.dart';

class SubscriberAddressCard extends StatelessWidget {
  const SubscriberAddressCard({super.key, required this.subscriber});
  final Subscriber subscriber;
  @override
  Widget build(BuildContext context) => DetailsCard(
    title: 'Address',
    fields: {
      'Address': subscriber.postalAddress,
      'Pincode': subscriber.postalCode,
    },
  );
}
