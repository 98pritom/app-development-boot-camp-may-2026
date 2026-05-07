import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/expense.dart';
import 'add_expense_state.dart';

final addExpenseProvider = NotifierProvider<AddExpenseViewModel, AddExpenseState>(AddExpenseViewModel.new);

class AddExpenseViewModel extends Notifier<AddExpenseState> {
  @override
  AddExpenseState build() {
    return const AddExpenseState();
  }

  ExpenseCategory _parseCategory(String value) {
    for (final category in ExpenseCategory.values) {
      if (category.name == value) {
        return category;
      }
    }
    return ExpenseCategory.other;
  }

  void initializeForm(Expense? expense) {
    if (expense != null) {
      state = state.copyWith(
        title: expense.note,
        amount: expense.amount,
        date: expense.date,
        category: _parseCategory(expense.category),
      );
    }
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setAmount(String amount) {
    final parsedAmount = double.tryParse(amount);
    state = state.copyWith(amount: parsedAmount);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setCategory(ExpenseCategory category) {
    state = state.copyWith(category: category);
  }

  void setNote(String note) {
    state = state.copyWith(title: note);
  }

  void setSelectedCategory(ExpenseCategory? category) {
    if (category == null) {
      return;
    }
    state = state.copyWith(category: category);
  }

  Future<void> pickDate(BuildContext context, Expense? expense) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = today.subtract(Duration(days: AppConstants.expenseDateRangeDays));
    final selectedDate = state.date ?? expense?.date;
    final currentDate = selectedDate ?? today;
    final initialDate = currentDate.isBefore(earliest)
        ? earliest
        : currentDate.isAfter(today)
            ? today
            : currentDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliest,
      lastDate: today,
    );

    if (pickedDate != null) {
      setDate(pickedDate);
    }
  }

  Future<bool> saveExpense(Expense? existingExpense) async {
    // Validation
    if (state.amount == null || state.amount == 0) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: 'Please enter an amount',
      );
      return false;
    }

    if (state.amount! <= 0) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: 'Amount must be greater than 0',
      );
      return false;
    }

    if (state.category == null) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: 'Please select a category',
      );
      return false;
    }

    if (state.date == null) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: 'Please select a date',
      );
      return false;
    }

    // Validate date is within 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = today.subtract(Duration(days: AppConstants.expenseDateRangeDays));
    final selectedDate = DateTime(state.date!.year, state.date!.month, state.date!.day);

    if (selectedDate.isBefore(earliest) || selectedDate.isAfter(today)) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: 'Date must be within the last ${AppConstants.expenseDateRangeDays} days',
      );
      return false;
    }

    state = state.copyWith(status: AddExpenseStatus.loading);
    try {
      final newExpense = Expense(
        id: existingExpense?.id ?? DateTime.now().toString(),
        note: state.title ?? '',
        amount: state.amount!,
        date: state.date!,
        category: state.category!.toString().split('.').last,
      );
      final box = Hive.box<Expense>(AppConstants.expenseBoxName);
      await box.put(newExpense.id, newExpense);
      state = state.copyWith(status: AddExpenseStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AddExpenseStatus.failure,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void resetForm() {
    state = const AddExpenseState();
  }
}
