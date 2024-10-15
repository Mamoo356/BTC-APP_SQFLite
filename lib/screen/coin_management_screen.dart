import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
// ignore: unused_import
import 'package:path/path.dart' as path;
import '../database_helper.dart'; // import DatabaseHelper

class CoinManagementScreen extends StatefulWidget {
  const CoinManagementScreen({super.key});

  @override
  _CoinManagementScreenState createState() => _CoinManagementScreenState();
}

class _CoinManagementScreenState extends State<CoinManagementScreen> {
  int _currentCoins = 0;
  String _userPassword = ''; // Store the password of the logged-in user
  List<Map<String, dynamic>> _transactionHistory = [];
  bool _isLoading = true;
  late Database _db;
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instance of DatabaseHelper
  TextEditingController _withdrawAmountController = TextEditingController(); // Controller for entering the amount to withdraw

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _db = await _dbHelper.db;
      await _getCurrentCoinBalance();
      await _getTransactionHistory();
      await _getUserPassword(); // Fetch the password of the logged-in user
    } catch (error) {
      print('Error initializing database: $error');
    } finally {
      setState(() {
        _isLoading = false; // Stop showing loading spinner after data is loaded
      });
    }
  }

  Future<void> _getCurrentCoinBalance() async {
    try {
      final List<Map<String, dynamic>> userResult = await _db.query('Users');
      if (userResult.isNotEmpty && userResult.first.containsKey('coinBalance')) {
        setState(() {
          _currentCoins = userResult.first['coinBalance'] ?? 0; // Set to 0 if coinBalance is missing
        });
      } else {
        await _db.insert('Users', {'coinBalance': 100, 'password': 'default'}); // Set initial balance to 100 coins
        setState(() {
          _currentCoins = 100;
        });
      }
    } catch (error) {
      print('Error fetching coin balance: $error');
    }
  }

  Future<void> _getTransactionHistory() async {
    try {
      final List<Map<String, dynamic>> transactionResult = await _db.query('transactions', orderBy: 'timestamp DESC');
      setState(() {
        _transactionHistory = transactionResult;
      });
    } catch (error) {
      print('Error fetching transaction history: $error');
    }
  }

  // Fetch the password of the logged-in user
  Future<void> _getUserPassword() async {
    try {
      Map<String, dynamic>? currentUser = await _dbHelper.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _userPassword = currentUser['password']; // Store the password of the logged-in user
        });
      }
    } catch (error) {
      print('Error fetching user password: $error');
    }
  }

  Future<void> _withdrawCoins(int amount) async {
    if (amount > _currentCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient coin balance for withdrawal')),
      );
      return;
    }

    try {
      await _db.transaction((txn) async {
        await txn.update('Users', {'coinBalance': _currentCoins - amount});
        await txn.insert('transactions', {
          'action': 'Withdraw',
          'amount': amount,
          'timestamp': DateTime.now().toString(),
        });
      });

      setState(() {
        _currentCoins -= amount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal successful')),
      );
      await _getTransactionHistory();
    } catch (error) {
      print('Error withdrawing coins: $error');
    }
  }

  Future<void> _verifyPasswordAndWithdraw() async {
    TextEditingController passwordController = TextEditingController();
    bool passwordVerified = false;

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        backgroundColor: Colors.brown[100],
        title: Text('Verify Password', style: TextStyle(color: Colors.brown[800])),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please enter your password to proceed with the withdrawal.', style: TextStyle(color: Colors.brown[700])),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.brown[700]),
                filled: true,
                fillColor: Colors.brown[50],
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (passwordController.text == _userPassword) { // Verify password
                passwordVerified = true;
                Navigator.of(dialogContext).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password verification failed.')),
                );
              }
            },
            style: TextButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Verify', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.brown[700])),
          ),
        ],
      ),
    );

    if (passwordVerified) {
      int withdrawAmount = int.tryParse(_withdrawAmountController.text) ?? 0;
      if (withdrawAmount > 0) {
        await _withdrawCoins(withdrawAmount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Management', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Current Coins: $_currentCoins',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _withdrawAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter amount to withdraw',
                            labelStyle: TextStyle(color: Colors.brown[700]),
                            filled: true,
                            fillColor: Colors.brown[50],
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _verifyPasswordAndWithdraw,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[800],
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('Withdraw Coins'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: _transactionHistory.isNotEmpty
                        ? ListView.builder(
                            itemCount: _transactionHistory.length,
                            itemBuilder: (context, index) {
                              var transaction = _transactionHistory[index];
                              return Card(
                                color: Colors.brown[50],
                                child: ListTile(
                                  title: Text(transaction['action'], style: TextStyle(color: Colors.brown[700])),
                                  subtitle: Text('Amount: ${transaction['amount']}', style: TextStyle(color: Colors.brown[500])),
                                  trailing: Text(
                                    transaction['timestamp'],
                                    style: TextStyle(color: Colors.brown[500]),
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No transaction history yet.',
                              style: TextStyle(color: Colors.brown[700], fontSize: 16),
                            ),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
