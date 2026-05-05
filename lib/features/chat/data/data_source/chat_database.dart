import 'package:realtime_chat_engine/core/shared/database_helper.dart';
import 'package:realtime_chat_engine/features/home/data/models/message_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/data_source/chat_store_contract.dart';

import '../../../home/domain/entities/message_entity.dart';
final chatDatabaseProvider = Provider((ref) => ChatDatabase(ref.read(databaseHelperProvider)));

class ChatDatabase implements ChatStoreContract {
  final DatabaseHelper _helper;
  ChatDatabase(this._helper);

  @override
  Future<void> addMessage(MessageEntity message) async {
    final db = await _helper.database;
    await db.insert('messages', message.toModel().toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<MessageEntity>> getMessages(String conversationId) async {
    final db = await _helper.database;
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
    final db = await _helper.database;
    await db.delete('messages', where: 'id = ? AND conversationId = ?', whereArgs: [messageId, conversationId]);
  }

  @override
  Future<void> clearCache() async {
    final db = await _helper.database;
    await db.delete('messages');
  }
}
