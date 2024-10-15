import 'package:flutter/material.dart';

class AuthorManagementScreen extends StatefulWidget {
  const AuthorManagementScreen({super.key});

  @override
  _AuthorManagementScreenState createState() => _AuthorManagementScreenState();
}

class _AuthorManagementScreenState extends State<AuthorManagementScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController(); // ช่องกรอกสำหรับราคา
  String? category;

  List<Map<String, dynamic>> savedBooks = [];
  bool isLoading = false; // สถานะโหลดข้อมูล

  // ลบฟังก์ชันที่มีปัญหาออกชั่วคราว

  void addBook() {
    if (titleController.text.isNotEmpty &&
        authorController.text.isNotEmpty &&
        category != null &&
        priceController.text.isNotEmpty) {
      double? price = double.tryParse(priceController.text); // แปลงราคาเป็น double
      if (price == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid price')),
        );
        return;
      }

      setState(() {
        isLoading = true; // แสดงการโหลดข้อมูล
        savedBooks.add({
          'title': titleController.text,
          'author': authorController.text,
          'price': price,
          'category': category,
        });
        _clearForm();
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _clearForm() {
    titleController.clear();
    authorController.clear();
    descriptionController.clear();
    priceController.clear();
    setState(() {
      category = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Management'), // เปลี่ยนชื่อเป็น Author Management
        backgroundColor: Colors.brown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Book Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: authorController,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: priceController, // ช่องกรอกข้อมูลราคา
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (in coins)'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category'),
              value: category,
              items: const [
                DropdownMenuItem(value: 'comic', child: Text('Comic')),
                DropdownMenuItem(value: 'novel', child: Text('Novel')),
              ],
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : addBook, // ถ้ากำลังโหลดอยู่ disable ปุ่ม
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Add Book'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.brown, // ตัวอักษรขาว
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Saved Books',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBookList(), // แสดงหนังสือที่บันทึกแล้ว
          ],
        ),
      ),
    );
  }

  Widget _buildBookList() {
    if (savedBooks.isEmpty) {
      return const Center(
        child: Text('No books available.'),
      );
    }

    return SizedBox(
      height: 300, // Fixes issue with ListView not being scrollable
      child: ListView.builder(
        itemCount: savedBooks.length,
        itemBuilder: (context, index) {
          var book = savedBooks[index];
          return ListTile(
            title: Text(book['title']),
            subtitle: Text(
              'Author: ${book['author']} | Price: ${(book['price'] != null) ? book['price'].toStringAsFixed(2) : 'No price available'} coins',
            ),
            leading: const Icon(Icons.book, size: 50),
          );
        },
      ),
    );
  }
}
