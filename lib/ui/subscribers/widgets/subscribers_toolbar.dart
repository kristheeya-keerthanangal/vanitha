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
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
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
        decoration: InputDecoration(
          labelText: 'Search subscribers',
          hint: Text('Enter Name, email or phone'),
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
        ),
      ),
    ],
  );
}
