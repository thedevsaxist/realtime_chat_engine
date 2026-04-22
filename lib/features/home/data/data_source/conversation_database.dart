// conversation_dao.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/database_helper.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation.dart';
import 'package:sqflite/sqflite.dart';

final conversationDaoProvider = Provider((ref) => ConversationDao(ref.read(databaseHelperProvider)));

class ConversationDao {
  final DatabaseHelper _helper;
  ConversationDao(this._helper);

  Future<void> insertConversation(Conversation c) async {
    final db = await _helper.database;
    await db.insert('conversations', c.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> linkUserToConversation(String userId, String conversationId) async {
    final db = await _helper.database;
    await db.insert('user_conversations', {
      'userId': userId,
      'conversationId': conversationId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // now this JOIN works because everything is in one DB
  Future<List<Conversation>> getUserConversations(String userId) async {
    final db = await _helper.database;
    final result = await db.rawQuery(
      '''
      SELECT c.*
      FROM conversations c
      INNER JOIN user_conversations uc ON c.id = uc.conversationId
      WHERE uc.userId = ?
      ORDER BY c.lastMessageTime DESC
    ''',
      [userId],
    );

    return result.map((json) => Conversation.fromJson(json)).toList();
  }

  Future<void> updateLastMessage(String conversationId, String message, int time) async {
    final db = await _helper.database;
    await db.update(
      'conversations',
      {'lastMessage': message, 'lastMessageTime': time},
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }
}
