import 'package:flutter/material.dart';
import 'add_subscriber_button.dart';

class SubscribersToolbar extends StatelessWidget {
  const SubscribersToolbar({
    super.key,
    required this.search,
    required this.onSearch,
  });
  final String search;
  final ValueChanged<String> onSearch;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 24,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Subscribers',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const AddSubscriberButton(),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        initialValue: search,
        onChanged: onSearch,
        decoration: const InputDecoration(
          labelText: 'Search name, email or phone',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    ],
  );
}
