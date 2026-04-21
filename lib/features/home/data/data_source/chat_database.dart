import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/chat_store_contract.dart';

import '../../domain/entities/message_entity.dart';

final chatDatabaseProvider = Provider((ref) => ChatDatabase());

class ChatDatabase implements ChatStoreContract {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'chat_database.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages(
        id TEXT PRIMARY KEY,
        conversationId TEXT,
        senderId TEXT,
        content TEXT,
        createdAt TEXT
      )
    ''');
  }

  @override
  Future<void> addMessage(MessageEntity message) async {
    final db = await database;
    final model = message.toModel().toJson();
    await db.insert('messages', model);
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    final db = await database;
    final result = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'createdAt',
    );
    return result.map((json) => MessageEntity.fromModel(MessageModel.fromJson(json))).toList();
  }

  @override
  Future<void> deleteMessage(String conversationId, String messageId) async {
    final db = await database;
    await db.delete('messages', where: 'id = ? AND conversationId = ?', whereArgs: [messageId, conversationId]);
  }

  @override
  Future<void> clearCache() async {
    final db = await database;
    await db.delete('messages');
  }
}
