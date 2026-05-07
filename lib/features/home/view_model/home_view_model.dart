import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/models/expense.dart';
import '../../../core/constants/app_constants.dart';
import 'home_state.dart';

final homeProvider = NotifierProvider<HomeViewModel, HomeState>(HomeViewModel.new);

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() {
    final box = Hive.box<Expense>(AppConstants.expenseBoxName);

    box.listenable().addListener(() {
      _updateExpenses(box.values.toList(growable: false));
    });

    return HomeState(
      expenses: box.values.toList(growable: false),
      isLoading: false,
    );
  }

  void _updateExpenses(List<Expense> expenses) {
    // Sort by newest first (most recent date first)
    final sorted = expenses.toList()..sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(expenses: sorted, isLoading: false);
  }

  void setTabIndex(int index) {
    state = state.copyWith(currentTabIndex: index);
  }
}
