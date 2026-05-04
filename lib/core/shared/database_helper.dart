import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final databaseHelperProvider = Provider((ref) => DatabaseHelper());

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db'); // single file

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN firstName TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN lastName TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN createdAt INTEGER');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT,
        firstName TEXT,
        lastName TEXT,
        createdAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        createdAt INTEGER,
        lastMessage TEXT,
        lastMessageTime INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE user_conversations (
        userId TEXT,
        conversationId TEXT,
        PRIMARY KEY (userId, conversationId)
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversationId TEXT,
        senderId TEXT,
        content TEXT,
        createdAt INTEGER
      )
    ''');
  }
}
