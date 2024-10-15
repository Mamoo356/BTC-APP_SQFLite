import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key});

  @override
  _MyLibraryScreenState createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  late Database _db;
  List<Map<String, dynamic>> _purchasedBooks = [];
  bool _isLoading = true;
  int _userCoins = 0;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  @override
  void dispose() {
    _db.close(); // ปิดฐานข้อมูลเมื่อปิดหน้าเพื่อป้องกันการใช้ทรัพยากรไม่เหมาะสม
    super.dispose();
  }

  Future<void> _initializeDatabase() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var databasesPath = await getDatabasesPath();
      String path = p.join(databasesPath, 'library.db');

      // เปิดฐานข้อมูล
      _db = await openDatabase(
        path,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE books(id INTEGER PRIMARY KEY, title TEXT, author TEXT, description TEXT, imageUrl TEXT, downloadUrl TEXT)',
          );
          await db.execute(
            'CREATE TABLE transactions(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, amount INTEGER, date TEXT)',
          );
          await db.execute(
            'CREATE TABLE user(id INTEGER PRIMARY KEY, coins INTEGER)',
          );
          await db.insert('user', {'id': 1, 'coins': 100}); // Initial coins
        },
        version: 1,
      );

      await _loadPurchasedBooks();
      await _loadUserCoins();
    } catch (e) {
      // Handle database initialization error
      print('Error initializing database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPurchasedBooks() async {
    try {
      final List<Map<String, dynamic>> books = await _db.query('books');
      setState(() {
        _purchasedBooks = books;
      });
    } catch (e) {
      print('Error loading purchased books: $e');
    }
  }

  Future<void> _loadUserCoins() async {
    try {
      final List<Map<String, dynamic>> user = await _db.query('user');
      if (user.isNotEmpty) {
        setState(() {
          _userCoins = user.first['coins'];
        });
      }
    } catch (e) {
      print('Error loading user coins: $e');
    }
  }

  Future<void> _deductCoins(int amount) async {
    if (_userCoins >= amount) {
      try {
        // Deduct coins
        int newBalance = _userCoins - amount;
        await _db.update(
          'user',
          {'coins': newBalance},
          where: 'id = ?',
          whereArgs: [1],
        );

        // Record transaction
        await _db.insert('transactions', {
          'type': 'Deduction',
          'amount': amount,
          'date': DateTime.now().toIso8601String(),
        });

        // Update UI
        await _loadUserCoins();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transaction successful: $amount coins deducted.')),
        );
      } catch (e) {
        print('Error deducting coins: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to complete transaction. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient coins! Please recharge your account.')),
      );
    }
  }

  Future<void> _downloadBook(String downloadUrl, String title) async {
    const int downloadCost = 10;

    // Check if the user has enough coins to download
    if (_userCoins < downloadCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient coins to download this book.')),
      );
      return;
    }

    // Deduct coins and proceed with the download
    await _deductCoins(downloadCost);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$title.pdf';
      final file = File(filePath);

      if (await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title is already downloaded!')),
        );
        return;
      }

      // Simulate a file write operation
      await file.writeAsString('Sample PDF content');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $title successfully!')),
      );
    } catch (e) {
      print('Error downloading book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to download book. Please try again.')),
      );
    }
  }

  Future<void> _shareBook(String title) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing $title')),
    );
  }

  void _showBookDetails(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext buildContext) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book['title'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text('Author: ${book['author']}'),
                  const SizedBox(height: 10),
                  Text(book['description']),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: const Color.fromARGB(255, 130, 92, 78),
      child: ListTile(
        leading: Image.asset(book['imageUrl'], width: 50),
        title: Text(
          book['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(book['author'], style: const TextStyle(color: Colors.white70)),
        trailing: Column(
          children: [
            ElevatedButton(
              onPressed: () => _downloadBook(book['downloadUrl'], book['title']),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.brown,
                minimumSize: const Size(80, 30),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Download', style: TextStyle(color: Colors.brown)),
            ),
            const SizedBox(height: 5),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareBook(book['title']),
              iconSize: 24,
            ),
          ],
        ),
        onTap: () => _showBookDetails(book),
      ),
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 130, 92, 78),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _purchasedBooks.length,
              itemBuilder: (BuildContext buildContext, index) {
                return _buildBookCard(_purchasedBooks[index]);
              },
            ),
    );
  }
}
