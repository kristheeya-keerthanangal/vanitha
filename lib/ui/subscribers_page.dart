import 'package:flutter/material.dart';

import 'add_subscriber_button.dart';

class SubscribersPage extends StatelessWidget {
  const SubscribersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscribers',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const AddSubscriberButton(),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Add your first subscriber to get started.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
