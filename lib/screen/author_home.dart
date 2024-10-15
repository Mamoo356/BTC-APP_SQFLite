import 'package:btc_app1/screen/coin_management_screen.dart';
import 'package:flutter/material.dart';
import '../database_helper.dart'; // นำเข้า DatabaseHelper
import 'author_management.dart'; // หน้าจัดการหนังสือ
//import 'coin_management_screen.dart'; // หน้าจัดการเหรียญ
import 'author_profile.dart'; // หน้าดูโปรไฟล์

class AuthorHomeScreen extends StatefulWidget {
  const AuthorHomeScreen({super.key});

  @override
  _AuthorHomeScreenState createState() => _AuthorHomeScreenState();
}

class _AuthorHomeScreenState extends State<AuthorHomeScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper(); // ใช้ SQLite แทน Firebase
  int publishedBooks = 0;
  int totalOrders = 0;
  int coinsEarned = 0;
  int _selectedIndex = 0; // สำหรับการเลือกหน้าใน BottomNavigationBar

  @override
  void initState() {
    super.initState();
    _loadAuthorData();
  }

  // โหลดข้อมูลนักเขียนจากฐานข้อมูล SQLite
  Future<void> _loadAuthorData() async {
    try {
      // ดึงข้อมูลผู้ใช้จาก SQLite
      var user = await dbHelper.getUserByEmail('author_email@example.com'); // แก้ไขให้เป็นอีเมลของนักเขียนที่เข้าสู่ระบบ

      if (user != null) {
        setState(() {
          publishedBooks = user['publishedBooks'] ?? 0;
          totalOrders = user['totalOrders'] ?? 0;
          coinsEarned = user['coinsEarned'] ?? 0;
        });
      } else {
        // ถ้าไม่พบข้อมูลนักเขียน ให้แสดงข้อผิดพลาด
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Author data not found in SQLite')),
        );
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    }
  }

  // เปลี่ยนหน้าตามที่เลือกจาก BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // หน้า Home ไม่ต้องทำอะไร
        break;
      case 1:
        // ไปยัง Book Management
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthorManagementScreen()),
        );
        break;
      case 2:
        // ไปยัง Author Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthorProfilePage()), // เปลี่ยนเป็นหน้าดูโปรไฟล์
        );
        break;
      case 3:
        // ไปยัง Coin Management
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoinManagementScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Home', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // สรุปผลงาน
              _buildSummarySection(),
              const SizedBox(height: 20),

              // การแจ้งเตือน (ใช้จากฐานข้อมูล SQLite)
              _buildNotificationSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Book Management',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle), // เปลี่ยนไอคอนเป็นโปรไฟล์
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Coin Management',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[800], // สีไอคอนเมื่อเลือกแล้ว
        unselectedItemColor: Colors.brown[300], // สีไอคอนเมื่อยังไม่ถูกเลือก
        onTap: _onItemTapped, // เรียกฟังก์ชันเปลี่ยนหน้า
      ),
    );
  }

  // สรุปผลงาน
  Widget _buildSummarySection() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      color: Colors.brown[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[900]),
            ),
            const SizedBox(height: 10),
            _buildSummaryItem('Published Books', publishedBooks.toString()),
            _buildSummaryItem('Total Orders', totalOrders.toString()),
            _buildSummaryItem('Coins Earned', coinsEarned.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, color: Colors.brown[700])),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.brown[900], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // การแจ้งเตือน (ดึงข้อมูลจากฐานข้อมูล SQLite)
  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown[900]),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper.getAllNotifications(), // ดึงข้อมูลการแจ้งเตือนจาก SQLite
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return const Text('No notifications available.');
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notification = notifications[index];
                return ListTile(
                  title: Text(notification['title']),
                  subtitle: Text(notification['message']),
                  leading: Icon(Icons.notifications, color: Colors.brown[700]),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
