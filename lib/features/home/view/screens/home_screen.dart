import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/models/expense.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../add_expense/view/screens/add_expense_screen.dart';
import '../../../insights/view/screens/insights_screen.dart';
import '../../view_model/home_view_model.dart';
import '../widgets/expense_summary.dart';
import '../widgets/expense_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final currentIndex = homeState.currentTabIndex;
    final titles = ['Expenses', 'Insights'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[currentIndex]),
        elevation: 1,
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildExpensesTab(context),
          const InsightsScreen(),
        ],
      ),
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                );
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(homeProvider.notifier).setTabIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context) {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable: Hive.box<Expense>(AppConstants.expenseBoxName).listenable(),
      builder: (context, box, _) {
        final expenses = box.values.toList(growable: false);
        
        return Column(
          children: [
            ExpenseSummary(expenses: expenses),
            Expanded(
              child: expenses.isEmpty
                  ? _buildEmptyState(context)
                  : ExpenseListView(expenses: expenses),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0066CC).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 64,
              color: Color(0xFF0066CC),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Expenses Yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start tracking your expenses by adding your first expense',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
