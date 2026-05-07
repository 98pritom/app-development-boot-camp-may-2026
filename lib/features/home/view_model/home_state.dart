import 'package:flutter/foundation.dart';

import '../../../../core/models/expense.dart';

@immutable
class HomeState {
  final int currentTabIndex;
  final List<Expense> expenses;
  final bool isLoading;

  const HomeState({
    this.currentTabIndex = 0,
    this.expenses = const [],
    this.isLoading = true,
  });

  HomeState copyWith({
    int? currentTabIndex,
    List<Expense>? expenses,
    bool? isLoading,
  }) {
    return HomeState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
