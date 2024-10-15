import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'author_home.dart';  // หน้าหลักนักเขียน
import 'reader_home.dart';  // หน้าหลักนักอ่าน

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? userRole; // บทบาทผู้ใช้ (นักเขียนหรือผู้อ่าน)

  final DatabaseHelper dbHelper = DatabaseHelper(); // ใช้ DatabaseHelper สำหรับ SQLite

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', // โลโก้แอป
              height: 100,
            ),
            const SizedBox(height: 20),
            Text(
              'Create New Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown[800]),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                fillColor: Colors.brown[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                fillColor: Colors.brown[100],
                filled: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                fillColor: Colors.brown[100],
                filled: true,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Role',
                border: const OutlineInputBorder(),
                fillColor: Colors.brown[100],
                filled: true,
              ),
              value: userRole,  // รองรับค่า null
              items: const [
                DropdownMenuItem(value: 'writer', child: Text('Writer')),
                DropdownMenuItem(value: 'reader', child: Text('Reader')),
              ],
              onChanged: (value) {
                setState(() {
                  userRole = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                if (userRole == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a role')));
                  return;
                }

                // ตรวจสอบว่ามีอีเมลนี้อยู่ในฐานข้อมูลแล้วหรือไม่
                var existingUser = await dbHelper.getUserByEmail(emailController.text);
                if (existingUser != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('The email address is already in use.')),
                  );
                  return;
                }

                // เพิ่มผู้ใช้ใหม่ใน SQLite
                await dbHelper.insertUser(
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  userRole!,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User Registered Successfully')),
                );

                // นำทางไปยังหน้าหลักตามบทบาทผู้ใช้
                if (userRole == 'writer') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthorHomeScreen()));
                } else if (userRole == 'reader') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ReaderHomeScreen()));
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
