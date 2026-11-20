import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/database_provider.dart';
import '../subscriber_form.dart';
import '../view_models/subscribers_view_model.dart';

class AddSubscriberButton extends ConsumerWidget {
  const AddSubscriberButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () async {
        final added = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AddSubscriberForm(
            repository: ref.read(subscriberRegistrationRepositoryProvider),
          ),
        );
        if (added == true && context.mounted) {
          ref.read(subscribersViewModelProvider).refresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subscriber added successfully')),
          );
        }
      },
      icon: const Icon(Icons.person_add),
      label: const Text('Add subscriber'),
    );
  }
}
