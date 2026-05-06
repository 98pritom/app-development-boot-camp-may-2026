import 'package:riverpod/riverpod.dart';

class AddExpenseState {
  final String? selectedCategory;
  final DateTime? selectedDate;

  const AddExpenseState({
    this.selectedCategory,
    this.selectedDate,
  });

  AddExpenseState copyWith({
    String? selectedCategory,
    DateTime? selectedDate,
    bool clearCategory = false,
    bool clearDate = false,
  }) {
    return AddExpenseState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
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

  void resetForm() {
    state = const AddExpenseState();
  }
}
