import 'package:flutter/material.dart';

class BookDetailsScreen extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int price;

  const BookDetailsScreen({
    required this.title,
    required this.imageUrl,
    required this.price, // ตรวจสอบให้แน่ใจว่ามี required
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageUrl.isNotEmpty
                ? Image.network(imageUrl, height: 200, fit: BoxFit.cover)
                : Icon(Icons.book, size: 100, color: Colors.brown[600]),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('\$${price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 20),
            // คำอธิบายหนังสือ
            const Text(
              'Book description goes here...',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // ปุ่มเพิ่มหนังสือเข้าสู่ My Library
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // เพิ่มฟังก์ชันเพิ่มหนังสือเข้าสู่ My Library
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to My Library'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[800],
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20)),
                child: const Text('Add to My Library'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
