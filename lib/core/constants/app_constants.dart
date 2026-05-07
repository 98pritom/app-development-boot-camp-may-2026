import '../models/expense.dart';

class AppConstants {
  // Expense box name for Hive
  static const String expenseBoxName = 'expenses';

  // Expense categories
  static const List<ExpenseCategory> expenseCategories = ExpenseCategory.values;

  // Date range for adding/editing expenses (last 7 days)
  static const int expenseDateRangeDays = 7;
}
