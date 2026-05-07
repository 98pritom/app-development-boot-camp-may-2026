import 'package:flutter/material.dart';

import '../../../../core/models/expense.dart';

class ExpenseSummary extends StatelessWidget {
  const ExpenseSummary({
    super.key,
    required this.expenses,
  });

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final total = expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final monthlyTotal = expenses
        .where(
          (expense) =>
              expense.date.year == now.year &&
              expense.date.month == now.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final previousMonthTotal = expenses
        .where(
          (expense) =>
              expense.date.year == previousMonth.year &&
              expense.date.month == previousMonth.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);
    final isSpendingIncreased = monthlyTotal > previousMonthTotal;
    final trendIcon = isSpendingIncreased ? Icons.trending_up : Icons.trending_down;
    final trendColor =
        isSpendingIncreased ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
    final trendText = isSpendingIncreased ? 'Higher spending' : 'Lower spending';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0066CC),
                  const Color(0xFF0066CC).withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0066CC).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '৳${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: const Color(0xFF00CC99),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'This Month',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF666E7A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳${monthlyTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            trendIcon,
                            size: 18,
                            color: trendColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trend',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF666E7A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            trendIcon,
                            size: 30,
                            color: trendColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              trendText,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: trendColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
