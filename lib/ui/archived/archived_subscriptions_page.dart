import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_database.dart';
import '../shared/date_time_format.dart';
import '../shared/empty_state.dart';
import '../shared/error_state.dart';
import '../shared/loading_state.dart';
import 'view_models/archived_subscriptions_view_model.dart';

class ArchivedSubscriptionsPage extends ConsumerWidget {
  const ArchivedSubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Archived subscriptions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      Expanded(
        child: ref
            .watch(archivedSubscriptionsViewModelProvider)
            .when(
              loading: () => const LoadingState(),
              error: (_, _) => ErrorState(
                message: 'Unable to load archived subscriptions.',
                onRetry: () =>
                    ref.invalidate(archivedSubscriptionsViewModelProvider),
              ),
              data: (rows) => rows.isEmpty
                  ? const EmptyState(message: 'No archived subscriptions.')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              'Subscription #${row.subscription.id} · ${row.subscriber.name}',
                            ),
                            subtitle: Text(
                              '${row.subscriber.displayNumber}\n'
                              '${row.subscription.startDate} – ${row.subscription.expiryDate}\n'
                              'Archived ${formatIstDateTime(row.subscription.archivedAt!)}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(
                              '/archived/${row.subscription.id}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
      ),
    ],
  );
}
