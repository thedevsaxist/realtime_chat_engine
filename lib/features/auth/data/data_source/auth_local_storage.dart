import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/shared/database_helper.dart';
import 'package:realtime_chat_engine/features/auth/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

final authLocalStorageProvider = Provider(
  (ref) => AuthLocalStorage(ref.read(databaseHelperProvider)),
);

class AuthLocalStorage {
  final DatabaseHelper _helper;
  AuthLocalStorage(this._helper);

  Future<void> saveUser(UserModel user) async {
    final db = await _helper.database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    try {
      final db = await _helper.database;
      final result = await db.query('users', limit: 1);
      if (result.isEmpty) return null;

      final row = Map<String, dynamic>.from(result.first);
      // Rows from older schema (id-only) or partial inserts are unusable.
      if (row['email'] == null ||
          row['firstName'] == null ||
          row['lastName'] == null ||
          row['createdAt'] == null) {
        return null;
      }

      debugPrint(row.toString());
      return UserModel.fromJson(row);
    } catch (e, st) {
      throw Exception("[AuthLocalStorage.getUser] -> ${e.toString()} \n $st");
    }
  }

  Future<void> deleteUser(String userId) async {
    final db = await _helper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }
}
