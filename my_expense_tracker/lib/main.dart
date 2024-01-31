import 'package:flutter/material.dart';

void main() {
  runApp(MyExpenseApp());
}

class MyExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _expenses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Total Expenses: \$${_getTotalExpense()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          child: Text('\$${_expenses[index].amount.toStringAsFixed(2)}'),
                        ),
                      ),
                    ),
                    title: Text(_expenses[index].title),
                    subtitle: Text('Date: ${_expenses[index].date.toString().split(' ')[0]}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewExpense(context),
        child: Icon(Icons.add),
      ),
    );
  }

  double _getTotalExpense() {
    return _expenses.isEmpty ? 0.0 : _expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  void _startAddNewExpense(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return NewExpense(_addNewExpense);
      },
    );
  }

  void _addNewExpense(String title, double amount, DateTime selectedDate) {
    final newExpense = Expense(
      title: title,
      amount: amount,
      date: selectedDate,
    );

    setState(() {
      _expenses.add(newExpense);
    });
  }
}

class NewExpense extends StatefulWidget {
  final Function(String, double, DateTime) addExpenseCallback;

  NewExpense(this.addExpenseCallback);

  @override
  _NewExpenseState createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedDate == null) {
      return;
    }

    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    if (enteredAmount <= 0) {
      return;
    }

    widget.addExpenseCallback(enteredTitle, enteredAmount, _selectedDate);

    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 5,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Title'),
                controller: _titleController,
                onSubmitted: (_) => _submitData(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Amount'),
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSubmitted: (_) => _submitData(),
              ),
              Container(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No Date Chosen'
                            : 'Picked Date: ${_selectedDate.toString().split(' ')[0]}',
                      ),
                    ),
                    TextButton(
                      onPressed: _presentDatePicker,
                      child: Text(
                        'Choose Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Add Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Expense {
  final String title;
  final double amount;
  final DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
  });
}
