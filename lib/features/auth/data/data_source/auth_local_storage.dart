import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/database_helper.dart';
import 'package:realtime_chat_engine/features/auth/data/models/user.dart';
import 'package:sqflite/sqflite.dart';

final authLocalStorageProvider = Provider((ref) => AuthLocalStorage(ref.read(databaseHelperProvider)));

class AuthLocalStorage {
  final DatabaseHelper _helper;
  AuthLocalStorage(this._helper);

  Future<void> saveUser(User user) async {
    final db = await _helper.database;
    await db.insert('users', {'id': user.id}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteUser(String userId) async {
    final db = await _helper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
