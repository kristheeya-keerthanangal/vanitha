import 'package:material_ui/material_ui.dart';
import '../../../data/app_database.dart';
import '../../shared/date_time_format.dart';
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
      'Region': subscriber.isForeign ? 'Foreign' : 'Domestic',
      'Created': formatIstDateTime(subscriber.createdAt),
      'Updated': formatIstDateTime(subscriber.updatedAt),
    },
  );
}
