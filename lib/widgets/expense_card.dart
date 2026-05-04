import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final noteText = expense.note.isEmpty ? 'No note' : expense.note;

    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(noteText),
        subtitle: Text('${expense.category} • ${_formatDate(expense.date)}'),
        trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
      ),
    );
  }
}
