import 'package:flutter/material.dart';
import '../database_helper.dart'; // นำเข้าฐานข้อมูลที่สร้างไว้
import 'author_home.dart'; // หน้าหลักนักเขียน
import 'reader_home.dart'; // หน้าหลักนักอ่าน

class SignInScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper(); // ใช้ SQLite แทน Firebase

  SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // โลโก้แอป
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Sign In',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () async {
                  // ปิดแป้นพิมพ์เมื่อกดปุ่ม Sign In
                  FocusScope.of(context).unfocus();

                  // ตรวจสอบว่าได้ใส่อีเมลและรหัสผ่านหรือยัง
                  if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter email and password')),
                    );
                    return;
                  }

                  // แสดง CircularProgressIndicator (หมุนค้าง) ขณะกำลังเชื่อมต่อกับฐานข้อมูล
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    // ตรวจสอบข้อมูลผู้ใช้จาก SQLite
                    var user = await dbHelper.getUser(emailController.text, passwordController.text);
                    print(user); // ตรวจสอบว่ามีข้อมูลผู้ใช้หรือไม่

                    if (user != null) {
                      String userRole = user['role'];

                      // ปิด CircularProgressIndicator
                      Navigator.of(context).pop();

                      // นำทางไปยังหน้าหลักตาม role ของผู้ใช้
                      if (userRole == 'writer') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const AuthorHomeScreen()), // หน้านักเขียน
                        );
                      } else if (userRole == 'reader') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ReaderHomeScreen()), // หน้านักอ่าน
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unknown user role')),
                        );
                      }
                    } else {
                      Navigator.of(context).pop(); // ปิด CircularProgressIndicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not found or wrong credentials')),
                      );
                    }
                  } catch (e) {
                    // จัดการข้อผิดพลาดเมื่อเชื่อมต่อฐานข้อมูล
                    Navigator.of(context).pop(); // ปิด CircularProgressIndicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signUp');
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(color: Colors.brown[800]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
