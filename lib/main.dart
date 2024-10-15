import 'package:btc_app1/screen/coin_management_screen.dart';
import 'package:flutter/material.dart';
import 'screen/sign_in_screen.dart';
import 'screen/reader_home.dart'; // Reader Home Screen
import 'screen/ManageCoins.dart'; // Coin Management Screen
import 'screen/reader_profile.dart'; // Reader Profile Screen
import 'screen/reader_library.dart'; // My Library Screen
import 'screen/author_home.dart'; // Author Home Screen
import 'screen/author_management.dart'; // Author Management Screen
import 'screen/author_profile.dart'; // Author Profile Screen
// ignore: duplicate_import
import 'screen/coin_management_screen.dart'; // Coin Management Screen
import 'screen/sign_up_screen.dart'; // Sign Up Screen
import 'database_helper.dart'; // สำหรับการจัดการ SQLite

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // สร้างฐานข้อมูล SQLite เมื่อเริ่มต้นแอป
  final dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();

  runApp(const MyApp()); // เรียกใช้ MyApp
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: '/',  // กำหนดเส้นทางเริ่มต้น
      routes: {
        '/': (context) => SignInScreen(),  // หน้า SignIn
        '/signin': (context) => SignInScreen(),  // หน้า SignIn
        '/signUp': (context) => const SignUpScreen(), // หน้า SignUp
        '/readerHome': (context) => const ReaderHomeScreen(),  // หน้า Reader Home
        '/authorHome': (context) => const AuthorHomeScreen(),  // หน้า Author Home
        '/authorManagement': (context) => const AuthorManagementScreen(), // หน้า Author Management
        '/authorProfile': (context) => const AuthorProfilePage(),  // หน้า Author Profile
        '/coinManagement': (context) => const CoinManagementScreen(),  // หน้า Coin Management
         '/ManagementCoins': (context) => const CoinManagement(),  // หน้า Coin Management
        '/manageCoins': (context) => const CoinManagement(),  // หน้า Manage Coins
        '/profile': (context) => const ProfileScreen(),  // หน้า Reader Profile
        '/library': (context) => const MyLibraryScreen(),  // หน้า My Library
      },
    );
  }
}
