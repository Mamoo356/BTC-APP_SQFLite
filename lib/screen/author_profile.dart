import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthorProfilePage extends StatefulWidget {
  const AuthorProfilePage({super.key});

  @override
  _AuthorProfilePageState createState() => _AuthorProfilePageState();
}

class _AuthorProfilePageState extends State<AuthorProfilePage> {
  late Database _db;
  String authorName = "Author Name";
  String authorBio = "This is a short bio about the author.";
  File? profileImage;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    _db = await openDatabase(
      join(await getDatabasesPath(), 'author_profile.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE profile(id INTEGER PRIMARY KEY, name TEXT, bio TEXT, imagePath TEXT)',
        );
      },
      version: 1,
    );
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final List<Map<String, dynamic>> maps = await _db.query('profile');
    if (maps.isNotEmpty) {
      setState(() {
        authorName = maps.first['name'];
        authorBio = maps.first['bio'];
        if (maps.first['imagePath'] != null) {
          profileImage = File(maps.first['imagePath']);
        }
      });
    }
  }

  Future<void> _saveProfileData(String name, String bio, String? imagePath) async {
    await _db.insert(
      'profile',
      {'name': name, 'bio': bio, 'imagePath': imagePath},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _loadProfileData();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Profile'),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                profileImage != null
                    ? CircleAvatar(
                        radius: 60,
                        backgroundImage: FileImage(profileImage!),
                      )
                    : const CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150'), // Placeholder สำหรับรูปโปรไฟล์
                      ),
                const SizedBox(height: 20),
                Text(
                  authorName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  authorBio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 30),
               ElevatedButton.icon(
  onPressed: () {
    _showEditProfileDialog(context);
  },
  icon: const Icon(Icons.edit, color: Colors.white), // ไอคอนเป็นสีขาว
  label: const Text('Edit Profile'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.brown[400], // สีพื้นหลังปุ่ม
    foregroundColor: Colors.white, // สีตัวอักษรเป็นสีขาว
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    textStyle: const TextStyle(fontSize: 18), // กำหนดขนาดตัวอักษร
  ),
),

                const SizedBox(height: 20),
               ElevatedButton.icon(
  onPressed: () {
    _signOut(context);
  },
  icon: const Icon(Icons.logout, color: Colors.white), // ไอคอนเป็นสีขาว
  label: const Text('Sign Out'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red, // สีพื้นหลังปุ่ม
    foregroundColor: Colors.white, // สีตัวอักษรเป็นสีขาว
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    textStyle: const TextStyle(fontSize: 18),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: authorName);
    final bioController = TextEditingController(text: authorBio);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Choose from Gallery'),
              ),
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera),
                label: const Text('Take a Picture'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  authorName = nameController.text;
                  authorBio = bioController.text;
                });
                _saveProfileData(authorName, authorBio, profileImage?.path);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันออกจากระบบ
  void _signOut(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/signin', (Route<dynamic> route) => false); 
  }
}
