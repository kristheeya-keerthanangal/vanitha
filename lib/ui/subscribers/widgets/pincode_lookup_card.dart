import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../providers/postal_pincode_provider.dart';

final _sixDigitPincode = RegExp(r'^\d{6}$');

class PincodeLookupCard extends ConsumerWidget {
  const PincodeLookupCard({super.key, required this.pincode});

  final String pincode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalized = pincode.trim();
    if (!_sixDigitPincode.hasMatch(normalized)) return const SizedBox.shrink();

    final lookup = ref.watch(postalPincodeLookupProvider(normalized));
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: lookup.when(
            loading: () => _StatusRow(
              leading: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              message: 'Looking up post offices for $normalized…',
            ),
            error: (_, _) => _StatusRow(
              message: 'Could not load post office details.',
              action: TextButton(
                onPressed: () =>
                    ref.invalidate(postalPincodeLookupProvider(normalized)),
                child: const Text('Retry'),
              ),
            ),
            data: (result) => result.hasPostOffices
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Post offices for $normalized',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(result.namesAsText),
                    ],
                  )
                : _StatusRow(message: 'No post office found for $normalized.'),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.message, this.leading, this.action});

  final String message;
  final Widget? leading;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (leading != null) ...[leading!, const SizedBox(width: 12)],
      Expanded(child: Text(message)),
      ?action,
    ],
  );
}
