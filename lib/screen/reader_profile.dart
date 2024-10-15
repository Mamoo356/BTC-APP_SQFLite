import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p; // ใช้ 'as p' เพื่อหลีกเลี่ยงการชนกับ 'BuildContext'
import 'package:path_provider/path_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Database? _database;
  String? name;
  String? email;
  int coinBalance = 0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, 'user_profile.db'); // ใช้ 'p.join' เพื่อหลีกเลี่ยงการชน

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            coinBalance INTEGER,
            profileImageUrl TEXT
          )
        ''');
      },
    );
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (_database != null) {
      final List<Map<String, dynamic>> result = await _database!.query('users', limit: 1);
      if (result.isNotEmpty) {
        final userData = result.first;
        setState(() {
          name = userData['name'];
          email = userData['email'];
          coinBalance = userData['coinBalance'];
          profileImageUrl = userData['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _updateProfile(String newName, String newEmail) async {
    if (_database != null) {
      await _database!.update(
        'users',
        {
          'name': newName,
          'email': newEmail,
        },
        where: 'id = ?',
        whereArgs: [1], // Assuming a single user
      );
      setState(() {
        name = newName;
        email = newEmail;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        profileImageUrl = _imageFile!.path; // Update the profileImageUrl
      });
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;

    if (_database != null) {
      await _database!.update(
        'users',
        {'profileImageUrl': profileImageUrl},
        where: 'id = ?',
        whereArgs: [1],
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile picture updated successfully!')),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.brown[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: profileImageUrl != null
                          ? FileImage(File(profileImageUrl!))
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email ?? 'No Email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: const Text('Select Image from Gallery'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.white, // Set button text color to brown
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      child: const Text('Take a Photo'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.brown,
                        backgroundColor: Colors.white, // Set button text color to brown
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) => email = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateProfile(name!, email!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[600],
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Update Information', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              Text(
                'Coin Balance: $coinBalance',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signOut(context), // Pass context here
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
