import 'package:riverpod/riverpod.dart';

class HomeState {
  final int currentTabIndex;

  const HomeState({
    this.currentTabIndex = 0,
  });

  HomeState copyWith({
    int? currentTabIndex,
  }) {
    return HomeState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();

  void setTabIndex(int index) {
    if (index == state.currentTabIndex) return;
    state = state.copyWith(currentTabIndex: index);
  }
}
