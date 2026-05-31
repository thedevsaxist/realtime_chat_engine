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
      final conversationId = json['id'].toString();

      final participants = await db.query(
        'conversation_participants',
        where: 'conversationId = ?',
        whereArgs: [conversationId],
      );

      final messages = await db.query(
        'messages',
        where: 'conversationId = ?',
        whereArgs: [conversationId],
        orderBy: 'createdAt',
      );

      conversations.add(
        ConversationModel.fromJson({...json, 'participants': participants, 'messages': messages}),
      );
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

  Future<({String? lastReadByMe, String? lastReadByPeer, DateTime? peerReadAt})> getReadState(
    String conversationId,
  ) async {
    final db = await _helper.database;
    final rows = await db.query(
      'conversations',
      columns: ['lastReadByMeMessageId', 'lastReadByPeerMessageId', 'lastReadByPeerAt'],
      where: 'id = ?',
      whereArgs: [conversationId],
    );
    if (rows.isEmpty) return (lastReadByMe: null, lastReadByPeer: null, peerReadAt: null);

    final row = rows.first;
    final peerReadAtMs = row['lastReadByPeerAt'] as int?;
    return (
      lastReadByMe: row['lastReadByMeMessageId'] as String?,
      lastReadByPeer: row['lastReadByPeerMessageId'] as String?,
      peerReadAt: peerReadAtMs != null ? DateTime.fromMillisecondsSinceEpoch(peerReadAtMs) : null,
    );
  }

  Future<void> setLastReadByMe(String conversationId, String messageId, int lastReadAt) async {
    await _setReadCursor(
      conversationId: conversationId,
      column: 'lastReadByMeMessageId',
      lastReadAt: lastReadAt,
      messageId: messageId,
    );
  }

  Future<void> setLastReadByPeer(String conversationId, String messageId, int lastReadAt) async {
    final current = await getReadState(conversationId);
    if (current.lastReadByPeer != null) {
      final isNewer = await isMessageAtOrAfter(conversationId, messageId, current.lastReadByPeer!);
      if (!isNewer) return;
    }
    await _setReadCursor(
      conversationId: conversationId,
      column: 'lastReadByPeerMessageId',
      lastReadAt: lastReadAt,
      messageId: messageId,
    );
  }

  Future<int> getLocalUnreadCount(
    String conversationId,
    String userId,
    Future<int> Function({required String conversationId}) fallbackToRemote,
  ) async {
    final db = await _helper.database;
    final readState = await getReadState(conversationId);

    // Build the query based on what we know
    String? where;
    List<Object?>? whereArgs;

    if (readState.lastReadByMe != null) {
      // Find the timestamp of the last message I read
      final lastReadRow = await db.query(
        'messages',
        columns: ['createdAt'],
        where: 'conversationId = ? AND id = ?',
        whereArgs: [conversationId, readState.lastReadByMe],
        limit: 1,
      );

      if (lastReadRow.isNotEmpty) {
        final lastReadAt = lastReadRow.first['createdAt'] as int;
        // Count peer messages strictly after that timestamp
        where = 'conversationId = ? AND senderId != ? AND createdAt > ?';
        whereArgs = [conversationId, userId, lastReadAt];
      } else {
        // lastReadByMe ID exists in state but not in local DB —
        // we can't trust local state, fall through to API
        return fallbackToRemote(conversationId: conversationId);
      }
    } else {
      // No read state at all — every peer message is unread
      where = 'conversationId = ? AND senderId != ?';
      whereArgs = [conversationId, userId];
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE $where',
      whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> _setReadCursor({
    required String conversationId,
    required String column,
    required String messageId,
    required int lastReadAt,
  }) async {
    final db = await _helper.database;

    final isMe = column == 'lastReadByMeMessageId';
    final messageIdCol = isMe ? 'lastReadByMeMessageId' : 'lastReadByPeerMessageId';
    final readAtCol = isMe ? 'lastReadByMeAt' : 'lastReadByPeerAt';

    final updated = await db.update(
      'conversations',
      {messageIdCol: messageId, readAtCol: lastReadAt},
      where: 'id = ?',
      whereArgs: [conversationId],
    );

    if (updated == 0) {
      await db.insert('conversations', {
        'id': conversationId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': '',
        'lastMessageTime': 0,
        'lastReadByMeMessageId': isMe ? messageId : null,
        'lastReadByMeAt': isMe ? lastReadAt : null,
        'lastReadByPeerMessageId': isMe ? null : messageId,
        'lastReadByPeerAt': isMe ? null : lastReadAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<DateTime?> getMessageCreatedAt(String conversationId, String messageId) async {
    final db = await _helper.database;
    final rows = await db.query(
      'messages',
      columns: ['createdAt'],
      where: 'conversationId = ? AND id = ?',
      whereArgs: [conversationId, messageId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(rows.first['createdAt'] as int);
  }

  Future<bool> isMessageAtOrAfter(
    String conversationId,
    String messageId,
    String referenceMessageId,
  ) async {
    final db = await _helper.database;
    final rows = await db.query(
      'messages',
      columns: ['id', 'createdAt'],
      where: 'conversationId = ? AND id IN (?, ?)',
      whereArgs: [conversationId, messageId, referenceMessageId],
    );
    if (rows.length < 2) return true;

    int? messageAt;
    int? referenceAt;
    for (final row in rows) {
      final at = row['createdAt'] as int;
      if (row['id'] == messageId) messageAt = at;
      if (row['id'] == referenceMessageId) referenceAt = at;
    }
    if (messageAt == null || referenceAt == null) return true;
    return messageAt >= referenceAt;
  }
}
