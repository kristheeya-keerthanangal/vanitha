import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/app_database.dart';
import '../../../data/repositories/subscriber_repository.dart';
import '../../../providers/database_provider.dart';

final subscribersViewModelProvider = Provider<SubscribersViewModel>((ref) {
  final model = SubscribersViewModel(ref.watch(subscriberRepositoryProvider));
  ref.onDispose(model.dispose);
  return model;
});

class SubscribersViewModel extends ChangeNotifier {
  SubscribersViewModel(this._repository) {
    refresh();
  }
  final SubscriberRepository _repository;
  List<Subscriber> rows = [];
  Map<int, SubscriberStatus> statuses = {};
  int total = 0;
  int offset = 0;
  int pageSize = 25;
  String search = '';
  SubscriberSort sort = SubscriberSort.name;
  bool ascending = true;
  bool loading = true;
  String? error;
  Timer? _debounce;
  int _request = 0;
  bool _disposed = false;
  SubscriberFilter selectedFilter = SubscriberFilter.all;
  SubscriberOriginFilter selectedOriginFilter = SubscriberOriginFilter.all;

  void searchChanged(String value) {
    search = value;
    offset = 0;
    _request++;
    loading = true;
    error = null;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), refresh);
  }

  void changePage(int value) {
    offset = value;
    refresh();
  }

  void changePageSize(int value) {
    pageSize = value;
    offset = 0;
    refresh();
  }

  void changeSort(SubscriberSort value, bool direction) {
    sort = value;
    ascending = direction;
    offset = 0;
    refresh();
  }

  void filterChanged(SubscriberFilter filter) {
    selectedFilter = filter;
    offset = 0;
    refresh();
  }

  void originFilterChanged(SubscriberOriginFilter filter) {
    selectedOriginFilter = filter;
    offset = 0;
    refresh();
  }

  Future<void> refresh() async {
    _debounce?.cancel();
    final request = ++_request;
    loading = true;
    error = null;
    notifyListeners();
    try {
      var page = await _repository.getSubscribersPage(
        offset: offset,
        limit: pageSize,
        search: search,
        sortBy: sort,
        filterBy: selectedFilter,
        originFilter: selectedOriginFilter,
        ascending: ascending,
      );
      if (_disposed || request != _request) return;
      if (offset > 0 && offset >= page.total) {
        offset = page.total == 0
            ? 0
            : ((page.total - 1) ~/ pageSize) * pageSize;
        page = await _repository.getSubscribersPage(
          offset: offset,
          limit: pageSize,
          search: search,
          sortBy: sort,
          filterBy: selectedFilter,
          originFilter: selectedOriginFilter,
          ascending: ascending,
        );
      }
      if (_disposed || request != _request) return;
      rows = page.rows;
      statuses = page.statuses;
      total = page.total;
    } catch (_) {
      if (_disposed || request != _request) return;
      error = 'Unable to load subscribers.';
    }
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    _debounce?.cancel();
    super.dispose();
  }
}
