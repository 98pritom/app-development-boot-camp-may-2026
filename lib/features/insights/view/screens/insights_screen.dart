import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../shared/utils/category_helper.dart';
import '../../view_model/insights_view_model.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsState = ref.watch(insightsProvider);
    final viewModel = ref.read(insightsProvider.notifier);

    if (insightsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (insightsState.expenses.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Monthly Comparison Card
        _buildMonthlyComparisonCard(context, viewModel),
        const SizedBox(height: 20),

        // Spending Trend Card
        _buildSpendingTrendCard(context, viewModel),
        const SizedBox(height: 20),

        // Category Breakdown Title
        Text(
          'Category Breakdown (Current Month)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Pie Chart
        _buildPieChart(viewModel),
        const SizedBox(height: 20),

        // Category List with Progress Bars
        ..._buildCategoryBreakdownList(context, viewModel),
        const SizedBox(height: 20),

        // Monthly Comparison Bar Chart
        Text(
          'Monthly Trend (Last 12 Months)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _buildMonthlyBarChart(viewModel),
        const SizedBox(height: 20),
      ],
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
              color: const Color(0xFF0066CC).withAlpha(25),
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
            'No expenses yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add your first expense to see insights!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparisonCard(
    BuildContext context,
    InsightsViewModel viewModel,
  ) {
    final currentTotal = viewModel.currentMonthTotal;
    final previousTotal = viewModel.previousMonthTotal;
    final difference = currentTotal - previousTotal;

    String trendLabel;
    Color trendColor;
    String icon;

    if (difference > 0) {
      trendLabel = '+৳${difference.toStringAsFixed(2)}';
      trendColor = Colors.red;
      icon = '↑';
    } else if (difference < 0) {
      trendLabel = '-৳${(-difference).toStringAsFixed(2)}';
      trendColor = Colors.green;
      icon = '↓';
    } else {
      trendLabel = 'No change';
      trendColor = Colors.grey;
      icon = '→';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Comparison',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Month',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '৳${currentTotal.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Previous Month',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${previousTotal.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: trendColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    icon,
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    trendLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: trendColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingTrendCard(
    BuildContext context,
    InsightsViewModel viewModel,
  ) {
    final trend = viewModel.spendingTrend;
    
    String trendText;
    Color trendColor;
    IconData trendIcon;

    switch (trend) {
      case 'increasing':
        trendText = 'Spending is increasing';
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
        break;
      case 'decreasing':
        trendText = 'Spending is decreasing';
        trendColor = Colors.green;
        trendIcon = Icons.trending_down;
        break;
      case 'stable':
        trendText = 'Spending is stable';
        trendColor = Colors.grey;
        trendIcon = Icons.trending_flat;
        break;
      case 'no_data':
        trendText = 'Not enough data';
        trendColor = Colors.grey;
        trendIcon = Icons.info_outline;
        break;
      default:
        trendText = 'No trend data';
        trendColor = Colors.grey;
        trendIcon = Icons.help_outline;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: trendColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                trendIcon,
                color: trendColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Trend',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trendText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(InsightsViewModel viewModel) {
    final expensesByCategory = viewModel.expensesByCategory;

    if (expensesByCategory.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No data for current month'),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: expensesByCategory.entries.map((entry) {
            final percentage = (entry.value / viewModel.currentMonthTotal * 100);
            return PieChartSectionData(
              color: CategoryHelper.getCategoryColor(entry.key),
              value: entry.value,
              title: '${percentage.toStringAsFixed(1)}%',
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList(),
          sectionsSpace: 2,
        ),
      ),
    );
  }

  List<Widget> _buildCategoryBreakdownList(
    BuildContext context,
    InsightsViewModel viewModel,
  ) {
    final breakdown = viewModel.categoryBreakdown;

    if (breakdown.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No expenses in current month'),
          ),
        ),
      ];
    }

    return breakdown.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value['amount'] as double;
      final percentage = double.parse(entry.value['percentage'] as String);
      final color = CategoryHelper.getCategoryColor(category);

      return Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CategoryHelper.getCategoryIcon(category),
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category Name and Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          CategoryHelper.getCategoryLabel(category),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1D26),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '৳${amount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Percentage Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 8,
                  backgroundColor: color.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMonthlyBarChart(InsightsViewModel viewModel) {
    final monthlyTotals = viewModel.monthlyTotals;
    final entries = monthlyTotals.entries.toList();

    if (entries.isEmpty || monthlyTotals.values.every((v) => v == 0)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    final maxY = monthlyTotals.values.reduce((a, b) => a > b ? a : b) * 1.1;

    return SizedBox(
      height: 350,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY : 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= entries.length) {
                    return const SizedBox();
                  }
                  // Show every other month to prevent overlap
                  if (value.toInt() % 2 != 0) {
                    return const SizedBox();
                  }
                  final key = entries[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Transform.rotate(
                      angle: -0.5, // ~28 degrees
                      child: Text(
                        key,
                        style: const TextStyle(fontSize: 9),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return const SizedBox();
                  }
                  // Format values based on magnitude
                  String label;
                  if (value >= 1000) {
                    label = '৳${(value / 1000).toStringAsFixed(0)}k';
                  } else {
                    label = '৳${value.toInt()}';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                },
                reservedSize: 45,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? (maxY / 5) : 20,
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFE0E6ED), width: 1),
              left: BorderSide(color: Color(0xFFE0E6ED), width: 1),
            ),
          ),
          barGroups: List.generate(
            entries.length,
            (index) {
              final amount = entries[index].value;
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: amount,
                    color: const Color(0xFF0066CC),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    width: 12,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
