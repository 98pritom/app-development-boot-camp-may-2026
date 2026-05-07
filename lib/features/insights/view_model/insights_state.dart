import 'package:flutter/foundation.dart';

import '../../../../core/models/expense.dart';

@immutable
class InsightsState {
  final List<Expense> expenses;
  final bool isLoading;

  const InsightsState({
    this.expenses = const [],
    this.isLoading = true,
  });

  InsightsState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
  }) {
    return InsightsState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
