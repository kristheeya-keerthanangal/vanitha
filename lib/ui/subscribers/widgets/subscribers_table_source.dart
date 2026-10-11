import 'package:flutter/material.dart';
import '../../../data/app_database.dart';

class SubscribersTableSource extends DataTableSource {
  SubscribersTableSource({
    required this.rows,
    required this.offset,
    required this.total,
    required this.onOpen,
  });
  final List<Subscriber> rows;
  final int offset;
  final int total;
  final ValueChanged<int> onOpen;
  @override
  DataRow? getRow(int index) {
    final local = index - offset;
    if (local < 0 || local >= rows.length) return null;
    final row = rows[local];
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => onOpen(row.id),
      cells: [
        DataCell(Text(row.displayNumber)),
        DataCell(Text(row.name)),
        DataCell(Text(row.email ?? '—')),
        DataCell(Text(row.phone ?? '—')),
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
