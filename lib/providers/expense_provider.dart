import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/expense_model.dart';
import 'package:uuid/uuid.dart';

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, List<ExpenseModel>>(
        (ref) => ExpenseNotifier());

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  ExpenseNotifier() : super([]) {
    loadExpenses();
  }

  final Box<ExpenseModel> _box = Hive.box<ExpenseModel>('expenses');

  void loadExpenses() {
    state = _box.values.toList();
  }

  void addExpense({
    required String title,
    required double amount,
    required String category,
    required DateTime date,
    required bool isIncome,
  }) {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      date: date,
      isIncome: isIncome,
    );

    _box.put(expense.id, expense);
    state = _box.values.toList();
  }

  void deleteExpense(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }
}
