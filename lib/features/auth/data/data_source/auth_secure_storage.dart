import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

final authSecureStorageProvider = Provider((ref) => AuthSecureStorage());

class AuthSecureStorage {
  Database? _database;

  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');

    _database ??= await openDatabase(
      path,
      version: 2,
      password: Constants.authDbPassword,
      onCreate: (db, version) {
        db.execute("CREATE TABLE auth (token TEXT, refreshToken TEXT)");
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute("ALTER TABLE auth ADD COLUMN refreshToken TEXT");
        }
      },
    );
    return _database!;
  }

  Future<void> saveToken(String token, String refreshToken) async {
    try {
      final db = await database;
      await db.delete("auth");
      await db.insert("auth", {"token": token, "refreshToken": refreshToken});
    } catch (e) {
      debugPrint("Unable to save token");
    }
  }

  Future<String?> getRefreshToken() async {
    final db = await database;
    final result = await db.query("auth", limit: 1);
    if (result.isNotEmpty) return result.first['refreshToken'] as String?;
    return null;
  }

  Future<String?> getToken() async {
    final db = await database;
    final result = await db.query("auth", limit: 1);
    if (result.isNotEmpty) {
      return result.first['token'] as String;
    }
    return null;
  }

  Future<void> deleteTokens() async {
    final db = await database;
    await db.delete("auth");
    await db.close();
    _database = null;
  }
}
