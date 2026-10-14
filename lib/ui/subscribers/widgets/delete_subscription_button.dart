import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_database.dart';
import '../../../providers/database_provider.dart';
import '../view_models/subscriber_details_view_model.dart';
import '../view_models/subscribers_view_model.dart';

class DeleteSubscriptionButton extends ConsumerStatefulWidget {
  const DeleteSubscriptionButton({super.key, required this.subscription});

  final Subscription subscription;

  @override
  ConsumerState<DeleteSubscriptionButton> createState() =>
      _DeleteSubscriptionButtonState();
}

class _DeleteSubscriptionButtonState
    extends ConsumerState<DeleteSubscriptionButton> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Archive subscription',
    onPressed: _busy ? null : _delete,
    icon: const Icon(Icons.archive_outlined),
  );

  Future<void> _delete() async {
    setState(() => _busy = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive subscription?'),
        content: Text(
          'Subscription #${widget.subscription.id} will be archived. '
          'This may change the subscriber’s status and renewal availability.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _busy = false);
      return;
    }
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .archiveSubscription(widget.subscription.id);
      if (!mounted) return;
      ref.invalidate(
        subscriberDetailsViewModelProvider(widget.subscription.subscriberId),
      );
      ref.read(subscribersViewModelProvider).refresh();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Subscription archived')));
    } on StateError catch (error) {
      if (mounted) {
        ref.invalidate(
          subscriberDetailsViewModelProvider(widget.subscription.subscriberId),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to archive subscription. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
