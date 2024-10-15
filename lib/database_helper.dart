import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDatabase(); // เรียกใช้ฟังก์ชัน initDatabase
    return _db!;
  }

  DatabaseHelper.internal();

  // ฟังก์ชันสำหรับสร้างฐานข้อมูล
  Future<Database> initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'app.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // ฟังก์ชันสร้างตารางต่าง ๆ ในฐานข้อมูล
  Future<void> _onCreate(Database db, int newVersion) async {
    // สร้างตาราง Users
    await db.execute(''' 
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // สร้างตาราง Books
    await db.execute(''' 
      CREATE TABLE Books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        imageUrl TEXT,
        price REAL NOT NULL, 
        pdfFile TEXT NOT NULL,
        author TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT
      )
    ''');

    // สร้างตาราง Notifications
    await db.execute(''' 
      CREATE TABLE Notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        authorId TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // สร้างตาราง Library สำหรับเก็บข้อมูลหนังสือที่ผู้ใช้ได้ซื้อ
    await db.execute('''
      CREATE TABLE Library (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bookId INTEGER NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        imageUrl TEXT,
        price REAL NOT NULL
      )
    ''');

    // เพิ่มข้อมูลหนังสือเริ่มต้น
    await insertInitialBooks(db);
  }

  // ฟังก์ชันเพิ่มหนังสือเริ่มต้น
  Future<void> insertInitialBooks(Database db) async {
    await db.insert('Books', {
      'title': 'The Great Novel',
      'imageUrl': 'novel1.jpg',  // เก็บเฉพาะชื่อไฟล์
      'price': 20,
      'pdfFile': '/path/to/great_novel.pdf',
      'author': 'John Doe',
      'category': 'novel',
      'description': 'A thrilling novel full of twists and turns.'
    });

    await db.insert('Books', {
      'title': 'Amazing Comic',
      'imageUrl': 'comic1.jpg',  // เก็บเฉพาะชื่อไฟล์
      'price': 25,
      'pdfFile': '/path/to/amazing_comic.pdf',
      'author': 'Jane Doe',
      'category': 'comic',
      'description': 'A comic series that will leave you wanting more.'
    });
  }

  // ฟังก์ชันสำหรับการจัดการหนังสือ
  Future<int> insertBook(String title, String imageUrl, double price, String pdfFile, String author, String category, String description) async {
    var dbClient = await db;
    Map<String, dynamic> values = {
      'title': title,
      'imageUrl': imageUrl,
      'price': price,
      'pdfFile': pdfFile,
      'author': author,
      'category': category,
      'description': description,
    };
    return await dbClient.insert('Books', values);
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    var dbClient = await db;
    return await dbClient.query('Books');
  }

  // ฟังก์ชันสำหรับการจัดการผู้ใช้
  Future<int> insertUser(String name, String email, String password, String role) async {
    var dbClient = await db;
    Map<String, dynamic> values = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
    return await dbClient.insert('Users', values);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'Users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null; 
  }

  Future<int> updateUser(int id, String name, String email, String password, String role) async {
    var dbClient = await db;
    Map<String, dynamic> values = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
    return await dbClient.update('Users', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    var dbClient = await db;
    return await dbClient.delete('Users', where: 'id = ?', whereArgs: [id]);
  }

  // ฟังก์ชันสำหรับการจัดการการแจ้งเตือน
  Future<int> insertNotification(String authorId, String title, String message) async {
    var dbClient = await db;
    Map<String, dynamic> values = {
      'authorId': authorId,
      'title': title,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    };
    return await dbClient.insert('Notifications', values);
  }

  Future<List<Map<String, dynamic>>> getNotificationsByAuthor(String authorId) async {
    var dbClient = await db;
    return await dbClient.query(
      'Notifications',
      where: 'authorId = ?',
      whereArgs: [authorId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    var dbClient = await db;
    return await dbClient.query('Notifications', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query('Users', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null; // คืนค่า null ถ้าไม่พบผู้ใช้
  }

  // ฟังก์ชันเพิ่มหนังสือลงในไลบรารี
  Future<void> addToLibrary(Map<String, dynamic> book) async {
    final dbClient = await db;
    await dbClient.insert(
      'Library', // ชื่อตารางที่ใช้เก็บหนังสือในไลบรารี
      {
        'bookId': book['id'],
        'title': book['title'],
        'author': book['author'],
        'imageUrl': book['imageUrl'],
        'price': book['price'],
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  getBooksByCategory(String s) {}
}
