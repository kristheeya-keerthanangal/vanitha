import 'package:flutter_riverpod/flutter_riverpod.dart';

final appShellViewModelProvider = NotifierProvider<AppShellViewModel, int>(
  AppShellViewModel.new,
);

class AppShellViewModel extends Notifier<int> {
  @override
  int build() => 0;

  void selectDestination(int index) => state = index;
}
