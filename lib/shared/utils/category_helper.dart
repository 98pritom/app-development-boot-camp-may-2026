import 'package:flutter/material.dart';

class CategoryHelper {
  static IconData getCategoryIcon(String category) {
    return switch (category.toLowerCase()) {
      'food' => Icons.restaurant,
      'transport' => Icons.directions_car,
      'shopping' => Icons.shopping_bag,
      'bills' => Icons.receipt_long,
      'other' || _ => Icons.category,
    };
  }

  static Color getCategoryColor(String category) {
    return switch (category.toLowerCase()) {
      'food' => const Color(0xFFFF6B6B),
      'transport' => const Color(0xFF4ECDC4),
      'shopping' => const Color(0xFFFFD93D),
      'bills' => const Color(0xFF6C5CE7),
      'other' || _ => const Color(0xFF95E1D3),
    };
  }
}
