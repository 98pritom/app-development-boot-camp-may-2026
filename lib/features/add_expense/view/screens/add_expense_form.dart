import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/expense.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/category_helper.dart';
import '../../view_model/add_expense_view_model.dart';

class AddExpenseForm extends ConsumerStatefulWidget {
  const AddExpenseForm({
    super.key,
    this.expense,
  });

  final Expense? expense;

  @override
  ConsumerState<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends ConsumerState<AddExpenseForm> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toString(),
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    
    // Initialize the notifier with existing expense data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addExpenseProvider.notifier).initializeForm(widget.expense);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveExpense() async {
    final notifier = ref.read(addExpenseProvider.notifier);
    final success = await notifier.saveExpense(widget.expense);

    if (!mounted) return;

    if (success) {
      notifier.resetForm();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final addExpenseState = ref.watch(addExpenseProvider);
    final selectedCategory =
        addExpenseState.selectedCategory ?? widget.expense?.category;
    final selectedDate = addExpenseState.selectedDate ?? widget.expense?.date;
    final isEditing = widget.expense != null;
    
    final dateLabel = selectedDate == null
        ? 'No date selected'
        : '${selectedDate.year}-'
              '${selectedDate.month.toString().padLeft(2, '0')}-'
              '${selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add New Expense'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Error Message
              if (addExpenseState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    addExpenseState.error!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),

              // Amount Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _amountController,
                    onChanged: (value) {
                      ref.read(addExpenseProvider.notifier).setAmount(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            '৳',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF0066CC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Category Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      hintText: 'Select category',
                      prefixIcon: const Icon(Icons.category),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    items: AppConstants.expenseCategories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: CategoryHelper.getCategoryColor(category)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    CategoryHelper.getCategoryIcon(category),
                                    size: 16,
                                    color: CategoryHelper.getCategoryColor(category),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(category),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      ref.read(addExpenseProvider.notifier).setSelectedCategory(value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      ref.read(addExpenseProvider.notifier).pickDate(context, widget.expense);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE0E6ED),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Color(0xFF0066CC),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Color(0xFF666E7A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Note Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Note',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    onChanged: (value) {
                      ref.read(addExpenseProvider.notifier).setNote(value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Add a note (optional)',
                      prefixIcon: Icon(Icons.note),
                      prefixIconConstraints: BoxConstraints(minWidth: 0),
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
                  onPressed: addExpenseState.isLoading ? null : _handleSaveExpense,
                  child: addExpenseState.isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : Text(
                          isEditing ? 'Update Expense' : 'Save Expense',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
