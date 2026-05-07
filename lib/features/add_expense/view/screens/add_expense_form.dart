import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../../../../shared/utils/category_helper.dart';
import '../../view_model/add_expense_state.dart';
import '../../view_model/add_expense_view_model.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  const AddExpenseForm({
    super.key,
    this.expense,
  });

  final Expense? expense;

  @override
  ConsumerState<AddExpenseForm> createState() =>
      _AddExpenseFormState();
}

class _AddExpenseFormState
    extends ConsumerState<AddExpenseForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();

    final expense = widget.expense;

    _amountController = TextEditingController(
      text: expense?.amount.toString() ?? '',
    );

    _noteController = TextEditingController(
      text: expense?.note ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(addExpenseProvider.notifier)
          .initializeForm(widget.expense);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  ExpenseCategory? _parseCategory(String? value) {
    if (value == null) {
      return null;
    }

    for (final category in ExpenseCategory.values) {
      if (category.name == value) {
        return category;
      }
    }

    return null;
  }

  Future<void> _handleSaveExpense() async {
    final notifier =
        ref.read(addExpenseProvider.notifier);

    final success =
        await notifier.saveExpense(widget.expense);

    if (!mounted) return;

    if (success) {
      notifier.resetForm();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final addExpenseState =
        ref.watch(addExpenseProvider);

    // ✅ FIXED TYPE SAFETY
    final ExpenseCategory? selectedCategory =
      addExpenseState.category ??
      _parseCategory(widget.expense?.category);

    final selectedDate =
        addExpenseState.date ??
        widget.expense?.date;

    final isEditing = widget.expense != null;

    final dateLabel = selectedDate == null
        ? 'No date selected'
        : '${selectedDate.year}-'
            '${selectedDate.month.toString().padLeft(2, '0')}-'
            '${selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Expense'
              : 'Add New Expense',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Error Message
              if (addExpenseState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(
                      color: Colors.red.shade300,
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Text(
                    addExpenseState.errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Amount
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    onChanged: (value) {
                      ref
                          .read(
                            addExpenseProvider
                                .notifier,
                          )
                          .setAmount(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: Padding(
                        padding:
                            const EdgeInsets.only(
                          left: 12,
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            '৳',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color:
                                      const Color(
                                    0xFF0066CC,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                ),
                          ),
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(
                        minWidth: 0,
                      ),
                    ),
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Category
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ FIXED: TYPE SAFETY
                  DropdownButtonFormField<
                      ExpenseCategory>(
                    initialValue: selectedCategory,

                    decoration: InputDecoration(
                      hintText:
                          'Select category',
                      prefixIcon:
                          const Icon(Icons.category),
                      prefixIconConstraints:
                          const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),

                    items: ExpenseCategory.values
                        .map(
                          (category) =>
                              DropdownMenuItem<
                                  ExpenseCategory>(
                            value: category,
                            child: Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .all(6),
                                  decoration:
                                      BoxDecoration(
                                    color: CategoryHelper
                                        .getCategoryColor(
                                            category)
                                        .withAlpha(
                                            25),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                6),
                                  ),
                                  child: Icon(
                                    CategoryHelper
                                        .getCategoryIcon(
                                            category),
                                    size: 16,
                                    color: CategoryHelper
                                        .getCategoryColor(
                                            category),
                                  ),
                                ),
                                const SizedBox(
                                    width: 8),
                                Text(category.name),
                              ],
                            ),
                          ),
                        )
                        .toList(),

                    onChanged: (value) {
                      ref
                          .read(
                            addExpenseProvider
                                .notifier,
                          )
                          .setSelectedCategory(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Date
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      ref
                          .read(
                            addExpenseProvider
                                .notifier,
                          )
                          .pickDate(
                            context,
                            widget.expense,
                          );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              const Color(0xFFE0E6ED),
                        ),
                        borderRadius:
                            BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color:
                                Color(0xFF0066CC),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(dateLabel),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Note
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    onChanged: (value) {
                      ref
                          .read(
                            addExpenseProvider
                                .notifier,
                          )
                          .setNote(value);
                    },
                    decoration:
                        const InputDecoration(
                      hintText:
                          'Add a note (optional)',
                      prefixIcon:
                          Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: addExpenseState
                              .status ==
                          AddExpenseStatus.loading
                      ? null
                      : _handleSaveExpense,
                  child: addExpenseState
                              .status ==
                          AddExpenseStatus.loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEditing
                              ? 'Update Expense'
                              : 'Save Expense',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}