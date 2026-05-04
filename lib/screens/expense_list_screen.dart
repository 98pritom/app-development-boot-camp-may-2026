import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_card.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = <Expense>[
      Expense.create(
        amount: 4.5,
        category: 'Food',
        date: DateTime.now(),
        note: 'Coffee',
      ),
      Expense.create(
        amount: 18.0,
        category: 'Transport',
        date: DateTime.now(),
        note: 'Taxi',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return ExpenseCard(expense: expenses[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemCount: expenses.length,
      ),
    );
  }
}
