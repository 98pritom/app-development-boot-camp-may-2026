import 'package:flutter/foundation.dart';

import '../../../../core/models/expense.dart';

enum AddExpenseStatus { initial, loading, success, failure }

@immutable
class AddExpenseState {
  final String? title;
  final double? amount;
  final DateTime? date;
  final ExpenseCategory? category;
  final AddExpenseStatus status;
  final String? errorMessage;

  const AddExpenseState({
    this.title,
    this.amount,
    this.date,
    this.category,
    this.status = AddExpenseStatus.initial,
    this.errorMessage,
  });

  AddExpenseState copyWith({
  String? title,
  double? amount,
  DateTime? date,
  ExpenseCategory? category,
  AddExpenseStatus? status,
  String? errorMessage,
  bool clearErrorMessage = false,
}) {
  return AddExpenseState(
    title: title ?? this.title,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    category: category ?? this.category,
    status: status ?? this.status,
    errorMessage:
        clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );
}
}
