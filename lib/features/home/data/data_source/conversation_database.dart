// conversation_dao.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/database_helper.dart';
import 'package:realtime_chat_engine/features/home/data/models/conversation_model.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';

final conversationDaoProvider = Provider(
  (ref) => ConversationDao(ref.read(databaseHelperProvider)),
);

class ConversationDao {
  final DatabaseHelper _helper;
  ConversationDao(this._helper);

  Future<void> insertConversation(ConversationModel c) async {
    final db = await _helper.database;

    if (c.messages == null) {
      debugPrint("[ConversationDao -> insertConversation] c.messages in empty");
    }

    final MessageModel? last = (c.messages == null || c.messages!.isEmpty)
        ? null
        : c.messages!.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);

    await db.insert('conversations', {
      'id': c.id,
      'createdAt': c.createdAt.millisecondsSinceEpoch,
      'lastMessage': last?.content ?? '',
      'lastMessageTime': (last?.createdAt ?? c.createdAt).millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final m in c.messages!) {
      await db.insert('messages', m.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    for (final p in (c.participants ?? [])) {
      await db.insert('conversation_participants', {
        'conversationId': c.id,
        'userId': p.userId,
        'firstName': p.firstName,
        'lastName': p.lastName,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> linkUserToConversation(String userId, String conversationId) async {
    final db = await _helper.database;
    await db.insert('user_conversations', {
      'userId': userId,
      'conversationId': conversationId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // now this JOIN works because everything is in one DB
  Future<List<ConversationModel>> getUserConversations(String userId) async {
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

    final conversations = <ConversationModel>[];
    for (final json in result) {
      final participants = await db.query(
        'conversation_participants',
        where: 'conversationId = ?',
        whereArgs: [json['id']],
      );
      conversations.add(ConversationModel.fromJson({
        ...json,
        'participants': participants,
      }));
    }
    return conversations;
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

  Future<void> clearAll() async {
    final db = await _helper.database;
    await db.delete('messages');
    await db.delete('conversations');
    await db.delete('user_conversations');
    await db.delete('conversation_participants');
  }
}
