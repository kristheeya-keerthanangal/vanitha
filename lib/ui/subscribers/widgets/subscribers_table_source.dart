import 'package:flutter/material.dart';
import '../../../data/app_database.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../data/subscription_status.dart';

class SubscribersTableSource extends DataTableSource {
  SubscribersTableSource({
    required this.rows,
    required this.statuses,
    required this.offset,
    required this.total,
    required this.onOpen,
    required this.colorScheme,
  });
  final List<Subscriber> rows;
  final Map<int, SubscriberStatus> statuses;
  final int offset;
  final int total;
  final ValueChanged<int> onOpen;
  final ColorScheme colorScheme;
  @override
  DataRow? getRow(int index) {
    final local = index - offset;
    if (local < 0 || local >= rows.length) return null;
    final row = rows[local];
    final status =
        statuses[row.id] ??
        const SubscriberStatus(status: SubscriptionStatus.notSubscribed);
    final statusLabel = switch (status.status) {
      SubscriptionStatus.active => 'Active',
      SubscriptionStatus.upcoming => 'Upcoming',
      SubscriptionStatus.expired => 'Expired',
      SubscriptionStatus.notSubscribed => 'Not Subscribed',
    };
    final statusBackground = switch (status.status) {
      SubscriptionStatus.active => colorScheme.primaryContainer,
      SubscriptionStatus.upcoming => colorScheme.secondaryContainer,
      SubscriptionStatus.expired => colorScheme.errorContainer,
      SubscriptionStatus.notSubscribed => colorScheme.surfaceContainerHighest,
    };
    final statusForeground = switch (status.status) {
      SubscriptionStatus.active => colorScheme.onPrimaryContainer,
      SubscriptionStatus.upcoming => colorScheme.onSecondaryContainer,
      SubscriptionStatus.expired => colorScheme.onErrorContainer,
      SubscriptionStatus.notSubscribed => colorScheme.onSurfaceVariant,
    };
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => onOpen(row.id),
      cells: [
        DataCell(Text(row.displayNumber)),
        DataCell(Text(row.name)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusForeground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(status.expiryDate ?? '—')),
      ],
    );
  }

  @override
  int get rowCount => total;
  @override
  bool get isRowCountApproximate => false;
  @override
  int get selectedRowCount => 0;
}
