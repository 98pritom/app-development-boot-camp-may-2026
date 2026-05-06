import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/models/expense.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/utils/category_helper.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Expense>>(
      valueListenable:
          Hive.box<Expense>(AppConstants.expenseBoxName).listenable(),
      builder: (context, box, _) {
        final expenses = box.values.toList(growable: false);
        final now = DateTime.now();
        final lastMonth = now.month == 1 ? 12 : now.month - 1;
        final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;

        final thisMonthTotal = expenses
            .where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month,
            )
            .fold<double>(0, (sum, expense) => sum + expense.amount);

        final currentMonthExpenses = expenses
            .where(
              (expense) =>
                  expense.date.year == now.year &&
                  expense.date.month == now.month,
            )
            .toList(growable: false);

        final lastMonthTotal = expenses
            .where(
              (expense) =>
                  expense.date.year == lastMonthYear &&
                  expense.date.month == lastMonth,
            )
            .fold<double>(0, (sum, expense) => sum + expense.amount);

        final difference = thisMonthTotal - lastMonthTotal;
        final differenceText = difference == 0
            ? '→ No change'
            : difference > 0
                ? '↑ +৳${difference.abs().toStringAsFixed(2)}'
                : '↓ -৳${difference.abs().toStringAsFixed(2)}';
        final differenceColor = difference == 0
            ? const Color(0xFF666E7A)
            : difference > 0
                ? Colors.red.shade400
                : Colors.green.shade400;

        final Map<String, double> categoryTotals = {};
        for (final expense in currentMonthExpenses) {
          categoryTotals[expense.category] =
              (categoryTotals[expense.category] ?? 0) + expense.amount;
        }
        final categoryEntries = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];

        final Map<int, double> monthTotals = {};
        for (final expense in expenses) {
          final key = expense.date.year * 100 + expense.date.month;
          monthTotals[key] = (monthTotals[key] ?? 0) + expense.amount;
        }

        final monthEntries = monthTotals.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        String trendText = 'Not enough data';
        IconData trendIcon = Icons.trending_flat;
        Color trendColor = const Color(0xFF666E7A);
        
        if (monthEntries.length >= 2) {
          final last = monthEntries[monthEntries.length - 1].value;
          final previous = monthEntries[monthEntries.length - 2].value;
          if (last > previous) {
            trendText = 'Spending is increasing';
            trendIcon = Icons.trending_up;
            trendColor = Colors.red.shade400;
          } else if (last < previous) {
            trendText = 'Spending is decreasing';
            trendIcon = Icons.trending_down;
            trendColor = Colors.green.shade400;
          } else {
            trendText = 'Spending is stable';
            trendIcon = Icons.trending_flat;
            trendColor = const Color(0xFF666E7A);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // This Month Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00CC99),
                      const Color(0xFF00CC99).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00CC99).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Month',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '৳${thisMonthTotal.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_month,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Comparison Cards
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
                          Text(
                            'Last Month',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF666E7A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '৳${lastMonthTotal.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          Text(
                            'Difference',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: const Color(0xFF666E7A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            differenceText,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: differenceColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Breakdown Pie Chart
              if (categoryEntries.isNotEmpty) ...[
                Text(
                  'Category Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                  child: SizedBox(
                    height: 280,
                    child: PieChart(
                      PieChartData(
                        sections: categoryEntries.asMap().entries.map((entry) {
                          final categoryEntry = entry.value;
                          final percentage = thisMonthTotal == 0
                              ? 0.0
                              : (categoryEntry.value / thisMonthTotal) * 100;
                          final categoryColor =
                              CategoryHelper.getCategoryColor(categoryEntry.key);

                          return PieChartSectionData(
                            value: categoryEntry.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 100,
                            color: categoryColor.withValues(alpha: 0.8),
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Legend
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categoryEntries.map((entry) {
                    final categoryColor =
                        CategoryHelper.getCategoryColor(entry.key);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Category Breakdown Section
              // Text(
              //   'Category Breakdown',
              //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
              const SizedBox(height: 12),
              if (categoryEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No expenses this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF999DAA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: categoryEntries.map((entry) {
                    final categoryColor =
                        CategoryHelper.getCategoryColor(entry.key);
                    final categoryIcon =
                        CategoryHelper.getCategoryIcon(entry.key);
                    final percentage = thisMonthTotal == 0
                        ? 0.0
                        : (entry.value / thisMonthTotal) * 100;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
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
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    categoryIcon,
                                    color: categoryColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}% of total',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall?.copyWith(
                                              color:
                                                  const Color(0xFF999DAA),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '৳${entry.value.toStringAsFixed(2)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall?.copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                minHeight: 6,
                                backgroundColor:
                                    Colors.grey.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    categoryColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // Spending Trend Bar Chart
              if (monthEntries.isNotEmpty) ...[
                Text(
                  'Spending Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                  child: SizedBox(
                    height: 280,
                    child: BarChart(
                      BarChartData(
                        barGroups: monthEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final monthEntry = entry.value;

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: monthEntry.value,
                                color: const Color(0xFF6C5CE7)
                                    .withValues(alpha: 0.8),
                                width: 16,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '৳${value.toInt()}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: const Color(0xFF999DAA),
                                      ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= monthEntries.length) {
                                  return const SizedBox();
                                }
                                final entry = monthEntries[index];
                                final month = entry.key % 100;
                                final monthName = [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                                ][month - 1];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    monthName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall?.copyWith(
                                          fontSize: 10,
                                          color: const Color(0xFF999DAA),
                                        ),
                                  ),
                                );
                              },
                              reservedSize: 30,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          horizontalInterval: null,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withValues(alpha: 0.1),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '৳${rod.toY.toStringAsFixed(2)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Monthly Trend Section
              Row(
                children: [
                  // Expanded(
                  //   child: Text(
                  //     'Spending Trend',
                  //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  // ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendIcon,
                          size: 16,
                          color: trendColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trendText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (monthEntries.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'No expense data yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF999DAA),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Column(
                  children: monthEntries.map((entry) {
                    final year = entry.key ~/ 100;
                    final month = entry.key % 100;
                    final label = '${monthNames[month - 1]} $year';
                    final isLatest = entry.key == monthEntries.last.key;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLatest
                              ? const Color(0xFF0066CC).withValues(alpha: 0.05)
                              : Colors.white,
                          border: isLatest
                              ? Border.all(
                                  color: const Color(0xFF0066CC)
                                      .withValues(alpha: 0.2),
                                  width: 1,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFF6C5CE7),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  if (isLatest)
                                    const SizedBox(height: 2),
                                  if (isLatest)
                                    Text(
                                      'Current',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(0xFF0066CC),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '৳${entry.value.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall?.copyWith(
                                    color: const Color(0xFF0066CC),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}
