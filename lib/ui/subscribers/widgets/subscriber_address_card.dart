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
      'Postal address': subscriber.postalAddress,
      'City': subscriber.city,
      'State': subscriber.state,
      'Postal code': subscriber.postalCode,
      'Country': subscriber.country,
    },
  );
}
