import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() =>
      _AddExpenseScreenState();
}

class _AddExpenseScreenState
    extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';
  bool _isIncome = false;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Salary',
    'Other'
  ];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(expenseProvider.notifier).addExpense(
            title: _titleController.text,
            amount: double.parse(_amountController.text),
            category: _selectedCategory,
            date: _selectedDate,
            isIncome: _isIncome,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully ✅")),
      );

      _titleController.clear();
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration:
                    const InputDecoration(labelText: "Title"),
                validator: (value) =>
                    value!.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration:
                    const InputDecoration(labelText: "Amount"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration:
                    const InputDecoration(labelText: "Category"),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Is Income?"),
                value: _isIncome,
                onChanged: (value) {
                  setState(() {
                    _isIncome = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  "Date: ${DateFormat.yMMMd().format(_selectedDate)}",
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
