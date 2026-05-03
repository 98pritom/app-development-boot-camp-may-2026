import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_card.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = <Expense>[
      Expense(
        id: 'e1',
        title: 'Coffee',
        amount: 4.5,
        date: DateTime.now(),
        category: 'Food',
      ),
      Expense(
        id: 'e2',
        title: 'Taxi',
        amount: 18.0,
        date: DateTime.now(),
        category: 'Travel',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
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
