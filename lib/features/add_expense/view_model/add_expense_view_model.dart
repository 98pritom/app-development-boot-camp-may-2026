import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riverpod/riverpod.dart';

import '../../../core/models/expense.dart';
import '../../../core/constants/app_constants.dart';

class AddExpenseState {
  final String? selectedCategory;
  final DateTime? selectedDate;
  final String amount;
  final String note;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const AddExpenseState({
    this.selectedCategory,
    this.selectedDate,
    this.amount = '',
    this.note = '',
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  AddExpenseState copyWith({
    String? selectedCategory,
    DateTime? selectedDate,
    String? amount,
    String? note,
    bool? isLoading,
    String? error,
    bool? isSuccess,
    bool clearCategory = false,
    bool clearDate = false,
  }) {
    return AddExpenseState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      amount: amount ?? this.amount,
      note: note ?? this.note,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

final addExpenseProvider = NotifierProvider<AddExpenseNotifier, AddExpenseState>(
  AddExpenseNotifier.new,
);

class AddExpenseNotifier extends Notifier<AddExpenseState> {
  @override
  AddExpenseState build() => const AddExpenseState();

  void setSelectedCategory(String? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  void setSelectedDate(DateTime? date) {
    state = state.copyWith(
      selectedDate: date,
      clearDate: date == null,
    );
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount, error: null);
  }

  void setNote(String note) {
    state = state.copyWith(note: note, error: null);
  }

  Future<void> pickDate(BuildContext context, Expense? existingExpense) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = today.subtract(Duration(days: AppConstants.expenseDateRangeDays));
    final selectedDate = state.selectedDate ?? existingExpense?.date;
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
      setSelectedDate(pickedDate);
    }
  }

  String? _validateForm(Expense? existingExpense) {
    if (state.amount.trim().isEmpty) {
      return 'Please enter an amount';
    }

    final amount = double.tryParse(state.amount.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }

    if (state.selectedCategory == null && existingExpense?.category == null) {
      return 'Please select a category';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final earliest = today.subtract(Duration(days: AppConstants.expenseDateRangeDays));
    final selectedDate = state.selectedDate ?? existingExpense?.date ?? today;
    final date = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (date.isAfter(today) || date.isBefore(earliest)) {
      return 'Date must be within the last ${AppConstants.expenseDateRangeDays} days.';
    }

    return null;
  }

  Future<bool> saveExpense(Expense? existingExpense) async {
    final validationError = _validateForm(existingExpense);
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final amount = double.parse(state.amount.trim());
      final selectedCategory = state.selectedCategory ?? existingExpense?.category ?? 'Other';
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final rawDate = state.selectedDate ?? existingExpense?.date ?? today;
      final date = DateTime(rawDate.year, rawDate.month, rawDate.day);
      final note = state.note.trim();

      final expense = existingExpense == null
          ? Expense.create(
              amount: amount,
              category: selectedCategory,
              date: date,
              note: note,
            )
          : Expense(
              id: existingExpense.id,
              amount: amount,
              category: selectedCategory,
              date: date,
              note: note,
            );

      final box = Hive.box<Expense>(AppConstants.expenseBoxName);
      await box.put(expense.id, expense);

      state = state.copyWith(isLoading: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error saving expense: $e');
      return false;
    }
  }

  void resetForm() {
    state = const AddExpenseState();
  }

  void initializeForm(Expense? expense) {
    if (expense != null) {
      state = state.copyWith(
        amount: expense.amount.toString(),
        note: expense.note,
        selectedCategory: expense.category,
        selectedDate: expense.date,
      );
    }
  }
}
