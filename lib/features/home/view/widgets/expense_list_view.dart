import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/expense.dart';
import '../../../../core/constants/app_constants.dart';
import '../../view/screens/expense_detail_screen.dart';
import '../../../../shared/components/expense_card.dart';

class ExpenseListView extends StatelessWidget {
  const ExpenseListView({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  void _deleteExpense(BuildContext context, Expense expense) {
    final box = Hive.box<Expense>(AppConstants.expenseBoxName);
    box.delete(expense.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemBuilder: (context, index) {
        final expense = expenses[index];

        return Dismissible(
          key: ValueKey(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.red.shade600,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: (_) {
            _deleteExpense(context, expense);
          },
          child: ExpenseCard(
            expense: expense,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ExpenseDetailScreen(expense: expense),
                ),
              );
            },
            onDelete: () => _deleteExpense(context, expense),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemCount: expenses.length,
    );
  }
}
