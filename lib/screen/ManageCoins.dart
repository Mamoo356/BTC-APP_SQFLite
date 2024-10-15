import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class CoinManagement extends StatefulWidget {
  const CoinManagement({super.key});

  @override
  _CoinManagementScreenState createState() => _CoinManagementScreenState();
}

class _CoinManagementScreenState extends State<CoinManagement> {
  int _currentCoins = 0;
  List<Map<String, dynamic>> _transactionHistory = [];
  bool _isLoading = true;
  late Database _db;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      _db = await openDatabase(
        path.join(await getDatabasesPath(), 'app.db'),
        version: 1,
        onCreate: (db, version) async {
          // สร้างตาราง Users และ Transactions ถ้ายังไม่มี
          await db.execute('''
            CREATE TABLE IF NOT EXISTS Users (
              id INTEGER PRIMARY KEY,
              name TEXT,
              email TEXT,
              password TEXT,
              role TEXT,
              coins INTEGER DEFAULT 0  -- เพิ่มค่าเริ่มต้นของเหรียญ
            )
          ''');

          await db.execute('''
            CREATE TABLE IF NOT EXISTS Transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT,
              amount INTEGER,
              date TEXT
            )
          ''');
        },
      );

      await _getCurrentCoinBalance();
      await _getTransactionHistory();
    } catch (e) {
      print('Error initializing database: $e'); // แสดงข้อความข้อผิดพลาดในคอนโซล
    } finally {
      setState(() {
        _isLoading = false; // ให้แน่ใจว่าการโหลดข้อมูลเสร็จสิ้นแล้ว
      });
    }
  }

  Future<void> _getCurrentCoinBalance() async {
    try {
      final List<Map<String, dynamic>> userResult = await _db.query('Users', where: 'id = ?', whereArgs: [1]);
      if (userResult.isNotEmpty && userResult.first['coins'] != null) {
        setState(() {
          _currentCoins = userResult.first['coins'];
        });
      } else {
        await _db.insert('Users', {
          'id': 1,
          'coins': 0,
          'name': 'User',
          'email': 'user@example.com',
          'password': 'password',
          'role': 'reader'
        });
        setState(() {
          _currentCoins = 0;
        });
      }
    } catch (e) {
      print('Error fetching coin balance: $e'); // แสดงข้อความข้อผิดพลาดในคอนโซล
    }
  }

  Future<void> _getTransactionHistory() async {
    try {
      final List<Map<String, dynamic>> transactionResult = await _db.query('Transactions', orderBy: 'date DESC');
      setState(() {
        _transactionHistory = transactionResult;
      });
    } catch (e) {
      print('Error fetching transaction history: $e'); // แสดงข้อความข้อผิดพลาดในคอนโซล
    }
  }

  Future<void> _updateCoinBalance(int amount, String action) async {
    try {
      await _db.transaction((txn) async {
        int newBalance = _currentCoins + amount;

        // อัปเดตยอดเหรียญของผู้ใช้
        await txn.update(
          'Users',
          {'coins': newBalance},
          where: 'id = ?',
          whereArgs: [1],
        );

        // เพิ่มรายการธุรกรรม
        await txn.insert('Transactions', {
          'type': action,
          'amount': amount,
          'date': DateTime.now().toIso8601String(),
        });
      });

      setState(() {
        _currentCoins += amount;
      });
      await _getTransactionHistory();
    } catch (e) {
      print('Error updating coin balance: $e'); // แสดงข้อความข้อผิดพลาดในคอนโซล
    }
  }

  void _showPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit Card'),
                onTap: () {
                  Navigator.pop(context);
                  _updateCoinBalance(50, 'Deposit');
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Bank Transfer'),
                onTap: () {
                  Navigator.pop(context);
                  _updateCoinBalance(100, 'Deposit');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Management'),
        backgroundColor: Colors.brown,
      ),
      backgroundColor: Colors.brown[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Current Coins: $_currentCoins',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showPaymentMethodDialog,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 130, 92, 78)),
                  child: const Text(
                    'Deposit Coins',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: _transactionHistory.length,
                    itemBuilder: (context, index) {
                      var history = _transactionHistory[index];
                      return ListTile(
                        title: Text('${history['type']}'),
                        subtitle: Text('Amount: ${history['amount']}'),
                        trailing: Text('${history['date']}'),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
