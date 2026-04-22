import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:realtime_chat_engine/core/shared/constants.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

final authSecureStorageProvider = Provider((ref) => AuthSecureStorage());

class AuthSecureStorage {
  static Database? _database;

  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auth.db');
    
    _database ??= await openDatabase(
        path,
        version: 1,
        password: Constants.authDbPassword,
        onCreate: (db, version) {
          db.execute("CREATE TABLE auth (token TEXT)");
        },
      );
    return _database!;
  }

  Future<void> saveToken(String token) async {
    await _database?.execute("INSERT INTO auth (token) VALUES (?)", [token]);
  }

  Future<String?> getToken() async {
    final result = await _database?.query("auth");
    if (result?.isNotEmpty ?? false) {
      return result?.first['token'] as String;
    }
    return null;
  }

  Future<void> deleteToken() async {
    await _database?.delete("auth");
  }
}
