import 'package:flutter/material.dart';
import '../../core/models/expense.dart';

class CategoryHelper {
  static IconData getCategoryIcon(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => Icons.restaurant,
      ExpenseCategory.transport => Icons.directions_car,
      ExpenseCategory.shopping => Icons.shopping_bag,
      ExpenseCategory.entertainment => Icons.movie,
      ExpenseCategory.health => Icons.health_and_safety,
      ExpenseCategory.other => Icons.category,
    };
  }

  static Color getCategoryColor(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => const Color(0xFFFF6B6B),
      ExpenseCategory.transport => const Color(0xFF4ECDC4),
      ExpenseCategory.shopping => const Color(0xFFFFD93D),
      ExpenseCategory.entertainment => const Color(0xFF6C5CE7),
      ExpenseCategory.health => const Color(0xFF45B7D1),
      ExpenseCategory.other => const Color(0xFF95E1D3),
    };
  }

  static String getCategoryLabel(ExpenseCategory category) {
    return switch (category) {
      ExpenseCategory.food => 'Food',
      ExpenseCategory.transport => 'Transport',
      ExpenseCategory.shopping => 'Shopping',
      ExpenseCategory.entertainment => 'Entertainment',
      ExpenseCategory.health => 'Health',
      ExpenseCategory.other => 'Other',
    };
  }
}
