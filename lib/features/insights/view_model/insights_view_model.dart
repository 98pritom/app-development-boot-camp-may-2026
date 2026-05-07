import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/expense.dart';
import 'insights_state.dart';

final insightsProvider = NotifierProvider<InsightsViewModel, InsightsState>(InsightsViewModel.new);

class InsightsViewModel extends Notifier<InsightsState> {
  @override
  InsightsState build() {
    final box = Hive.box<Expense>(AppConstants.expenseBoxName);

    box.listenable().addListener(() {
      _updateExpenses(box.values.toList(growable: false));
    });

    return InsightsState(
      expenses: box.values.toList(growable: false),
      isLoading: false,
    );
  }

  void _updateExpenses(List<Expense> expenses) {
    state = state.copyWith(expenses: expenses, isLoading: false);
  }

  ExpenseCategory _parseCategory(String value) {
    for (final category in ExpenseCategory.values) {
      if (category.name == value) {
        return category;
      }
    }
    return ExpenseCategory.other;
  }

  // Get all expenses for a specific month
  List<Expense> _getExpensesForMonth(int year, int month) {
    return state.expenses.where(
      (e) => e.date.year == year && e.date.month == month,
    ).toList();
  }

  // Get expenses by category (current month only)
  Map<ExpenseCategory, double> get expensesByCategory {
    final now = DateTime.now();
    final currentMonthExpenses = _getExpensesForMonth(now.year, now.month);
    final map = <ExpenseCategory, double>{};
    for (final expense in currentMonthExpenses) {
      final category = _parseCategory(expense.category);
      map[category] = (map[category] ?? 0) + expense.amount;
    }
    return map;
  }

  // Get current month total
  double get currentMonthTotal {
    final now = DateTime.now();
    return _getExpensesForMonth(now.year, now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Get previous month total
  double get previousMonthTotal {
    final now = DateTime.now();
    final prevDate = DateTime(now.year, now.month - 1);
    return _getExpensesForMonth(prevDate.year, prevDate.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Get spending trend (increasing, decreasing, stable, insufficient data)
  String get spendingTrend {
    if (currentMonthTotal > previousMonthTotal) {
      return 'increasing';
    } else if (currentMonthTotal < previousMonthTotal) {
      return 'decreasing';
    } else if (currentMonthTotal == 0) {
      return 'no_data';
    } else {
      return 'stable';
    }
  }

  // Get monthly totals for the last 12 months
  Map<String, double> get monthlyTotals {
    final map = <String, double>{};
    final now = DateTime.now();
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final key = '${date.month.toString().padLeft(2, '0')}-${date.year}';
      final total = _getExpensesForMonth(date.year, date.month)
          .fold(0.0, (sum, e) => sum + e.amount);
      map[key] = total;
    }
    
    return map;
  }

  // Get month name from month number
  String getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Get category breakdown with percentages (current month)
  Map<ExpenseCategory, Map<String, dynamic>> get categoryBreakdown {
    final total = currentMonthTotal;
    if (total == 0) return {};
    
    final breakdown = <ExpenseCategory, Map<String, dynamic>>{};
    for (final category in ExpenseCategory.values) {
      final amount = expensesByCategory[category] ?? 0;
      breakdown[category] = {
        'amount': amount,
        'percentage': (amount / total * 100).toStringAsFixed(1),
      };
    }
    
    return Map.fromEntries(
      breakdown.entries.where((e) => e.value['amount'] > 0).toList()
        ..sort((a, b) => (b.value['amount'] as double).compareTo(a.value['amount'] as double))
    );
  }
}
