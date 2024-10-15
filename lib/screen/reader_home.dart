import 'package:flutter/material.dart';
import '../database_helper.dart'; // นำเข้า DatabaseHelper
import 'reader_profile.dart'; // Import หน้าจอโปรไฟล์นักอ่าน
import 'ManageCoins.dart'; // Import หน้าจัดการเหรียญ
import 'reader_library.dart'; // Import หน้าจอ My Library

class ReaderHomeScreen extends StatefulWidget {
  const ReaderHomeScreen({super.key});

  @override
  _ReaderHomeScreenState createState() => _ReaderHomeScreenState();
}

class _ReaderHomeScreenState extends State<ReaderHomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper(); // ใช้ SQLite แทน Firebase
  String? profileImageUrl;
  String? displayName;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    var user = await dbHelper.getCurrentUser(); // ดึงข้อมูลผู้ใช้จาก SQLite
    setState(() {
      displayName = user?['name'] ?? 'User';
      profileImageUrl = user?['profileImageUrl'] ?? null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(displayName ?? 'User', style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.brown[800],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnnouncementSection(),
            _buildSectionTitle('Recommended Books'),
            SizedBox(
              height: 180,
              child: _buildBookList(), // จำกัดความสูงของ ListView
            ),
            _buildSectionTitle('New Books'),
            SizedBox(
              height: 180,
              child: _buildNewBooksList(), // จำกัดความสูงของ ListView
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Coins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.brown[800],
        unselectedItemColor: Colors.brown[300],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoinManagement()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyLibraryScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      color: Colors.brown[100],
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promotion & Announcements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown[900]),
            ),
            const SizedBox(height: 5),
            Text('50% off on selected books! Free books for members.', style: TextStyle(color: Colors.brown[800])),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[700]),
      ),
    );
  }

  Widget _buildBookList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getBooksByCategory('novel'), // ดึงข้อมูลหนังสือตามหมวดหมู่
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No books available.'));
        }

        var books = snapshot.data!;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            var book = books[index];
            return _buildBookCard(book); // แสดงข้อมูลหนังสือ
          },
        );
      },
    );
  }

  Widget _buildNewBooksList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: dbHelper.getAllBooks(), // ดึงข้อมูลหนังสือทั้งหมด
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No new books available.'));
        }

        var books = snapshot.data!;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: books.length,
          itemBuilder: (context, index) {
            var book = books[index];
            return _buildBookCard(book); // แสดงข้อมูลหนังสือใหม่
          },
        );
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    return GestureDetector(
      onTap: () {
        _showBookDetails(context, book); // แสดงรายละเอียดหนังสือ
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        color: Colors.brown[100],
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                  ? Image.asset(
                      'assets/images/${book['imageUrl']}',
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 50, color: Colors.brown);
                      },
                    )
                  : const Icon(Icons.book, size: 50, color: Colors.brown),
              const SizedBox(height: 10),
              Text(
                book['title'],
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown[900]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                book['price'] != null ? '${book['price'].toStringAsFixed(2)} coins' : 'N/A coins',
                style: TextStyle(fontSize: 12, color: Colors.brown[700], fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBookDetails(BuildContext context, Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            book['title'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.brown, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                          ? Image.asset(
                              'assets/images/${book['imageUrl']}',
                              height: 150,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.book, size: 100, color: Colors.brown),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailText('Author:', book['author']),
                _buildDetailText('Price:', '${book['price'] != null ? book['price'].toStringAsFixed(2) : 'N/A'} coins'),
                _buildDetailText('Category:', book['category']),
                _buildDetailText('Description:', book['description']),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
                fontSize: 16,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
