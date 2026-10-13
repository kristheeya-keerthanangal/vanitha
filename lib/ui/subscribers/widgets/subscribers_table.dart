import 'package:flutter/material.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../view_models/subscribers_view_model.dart';
import 'subscribers_table_source.dart';

class SubscribersTable extends StatefulWidget {
  const SubscribersTable({
    super.key,
    required this.model,
    required this.onOpen,
  });
  final SubscribersViewModel model;
  final ValueChanged<int> onOpen;
  @override
  State<SubscribersTable> createState() => _SubscribersTableState();
}

class _SubscribersTableState extends State<SubscribersTable> {
  late SubscribersTableSource _source;
  var _sourceInitialized = false;
  SubscribersTableSource _createSource() => SubscribersTableSource(
    rows: widget.model.rows,
    statuses: widget.model.statuses,
    offset: widget.model.offset,
    total: widget.model.total,
    onOpen: widget.onOpen,
    colorScheme: Theme.of(context).colorScheme,
  );
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sourceInitialized) _source.dispose();
    _source = _createSource();
    _sourceInitialized = true;
  }

  @override
  void didUpdateWidget(covariant SubscribersTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _source.dispose();
    _source = _createSource();
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    return PaginatedDataTable(
      showEmptyRows: false,
      key: ValueKey((
        model.offset,
        model.pageSize,
        model.search,
        model.selectedFilter,
        model.sort,
        model.ascending,
      )),
      initialFirstRowIndex: model.offset,
      rowsPerPage: model.pageSize,
      availableRowsPerPage: const [10, 25, 50],
      onRowsPerPageChanged: (size) {
        if (size != null) model.changePageSize(size);
      },
      onPageChanged: model.changePage,
      showCheckboxColumn: false,
      showFirstLastButtons: true,
      sortColumnIndex: model.sort == SubscriberSort.number ? 0 : 1,
      sortAscending: model.ascending,
      columns: [
        DataColumn(
          label: const Text('Subscriber number'),
          onSort: (_, ascending) =>
              model.changeSort(SubscriberSort.number, ascending),
        ),
        DataColumn(
          label: const Text('Name'),
          onSort: (_, ascending) =>
              model.changeSort(SubscriberSort.name, ascending),
        ),
        const DataColumn(label: Text('Status')),
        const DataColumn(label: Text('Expires on')),
      ],
      source: _source,
    );
  }
}
