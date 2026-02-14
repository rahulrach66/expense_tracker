import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseProvider);

    double income = 0;
    double expense = 0;

    Map<String, double> categoryTotals = {};

    for (var e in expenses) {
      if (e.isIncome) {
        income += e.amount;
      } else {
        expense += e.amount;
        categoryTotals[e.category] =
            (categoryTotals[e.category] ?? 0) + e.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Income vs Expense",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 220),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (income > expense ? income : expense) + 500,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                          toY: income, color: Colors.green, width: 30)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(
                          toY: expense, color: Colors.red, width: 30)
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return const Text("Income");
                          } else {
                            return const Text("Expense");
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text("Expense by Category",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      title: entry.key,
                      radius: 60,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
