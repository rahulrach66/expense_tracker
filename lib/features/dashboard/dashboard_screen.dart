import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../providers/filter_provider.dart';
import '../../core/enums/filter_type.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> _balanceAnimation;
  late AnimationController _controller;
  late Animation<double> _animation;

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  _balanceAnimation = Tween<double>(begin: 0, end: 0)
      .animate(_animation);

  _controller.forward();
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.flight;
      case 'shopping':
        return Icons.shopping_bag;
      case 'salary':
        return Icons.account_balance_wallet;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expenseProvider);
    final filter = ref.watch(filterProvider);
    final now = DateTime.now();

    // 👇 Keep the rest of your existing dashboard code BELOW this



    final expenses = allExpenses.where((e) {
      if (filter == FilterType.all) return true;

      if (filter == FilterType.thisMonth) {
        return e.date.month == now.month &&
            e.date.year == now.year;
      }

      if (filter == FilterType.lastMonth) {
        final lastMonth = DateTime(now.year, now.month - 1);
        return e.date.month == lastMonth.month &&
            e.date.year == lastMonth.year;
      }

      return true;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var e in expenses) {
      if (e.isIncome) {
        totalIncome += e.amount;
      } else {
        totalExpense += e.amount;
      }
    }

    final balance = totalIncome - totalExpense;
_balanceAnimation = Tween<double>(
  begin: 0,
  end: balance,
).animate(_animation);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          DropdownButton<FilterType>(
            value: filter,
            underline: const SizedBox(),
            onChanged: (value) {
              ref.read(filterProvider.notifier).state = value!;
            },
            items: const [
              DropdownMenuItem(
                value: FilterType.all,
                child: Text("All"),
              ),
              DropdownMenuItem(
                value: FilterType.thisMonth,
                child: Text("This Month"),
              ),
              DropdownMenuItem(
                value: FilterType.lastMonth,
                child: Text("Last Month"),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FC), Color(0xFFE3E6F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _summaryCard(totalIncome, totalExpense, balance),
              const SizedBox(height: 20),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text("No transactions yet"))
                    : ListView.builder(
  itemCount: expenses.length,
  itemBuilder: (context, index) {
    final item = expenses[index];

    return Dismissible(
      key: Key(item.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        ref
            .read(expenseProvider.notifier)
            .deleteExpense(item.id);
      },
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(_animation),
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.isIncome
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: item.isIncome
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                const SizedBox(width: 16),

                // Title + Date
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${item.category} • ${DateFormat.yMMMd().format(item.date)}",
                        style:
                            const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  "₹ ${item.amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: item.isIncome
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
      double income, double expense, double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4e73df), Color(0xFF1cc88a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
        AnimatedBuilder(
  animation: _balanceAnimation,
  builder: (context, child) {
    return Text(
      "₹ ${_balanceAnimation.value.toStringAsFixed(2)}",
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: balance >= 0
            ? Colors.white
            : Colors.redAccent,
      ),
    );
  },
),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniCard("Income", income, Colors.greenAccent),
              _miniCard("Expense", expense, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniCard(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        Text(
          "₹ ${amount.toStringAsFixed(2)}",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16),
        ),
      ],
    );
  }
}
