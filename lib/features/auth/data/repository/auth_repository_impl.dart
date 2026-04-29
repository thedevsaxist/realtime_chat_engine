import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_client.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:realtime_chat_engine/features/auth/data/models/user.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_res_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/repository/auth_repository.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/conversation_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthClient _authClient;
  final AuthLocalStorage _authLocalStorage;
  final AuthSecureStorage _authSecureStorage;
  final ConversationDao _conversationDao;

  AuthRepositoryImpl(
    this._authClient,
    this._authLocalStorage,
    this._authSecureStorage,
    this._conversationDao,
  );

  @override
  Future<LoginResEntity> login(LoginReqEntity reqEntity) async {
    try {
      final result = await _authClient.login(reqEntity.toModel());

      if (result.token.isNotEmpty) {
        final user = User(id: result.userId);

        await _authLocalStorage.saveUser(user);
        await _authSecureStorage.saveToken(result.token);

        // Populate both tables used by `ConversationDao.getUserConversations()`:
        // - `conversations`: the INNER JOIN base table
        // - `user_conversations`: the join/link table
        for (final conversation in result.conversations) {
          await _conversationDao.insertConversation(conversation);
          await _conversationDao.linkUserToConversation(user.id, conversation.id);
        }
      }

      return LoginResEntity.fromModel(result);
    } catch (e, st) {
      throw Exception("[AuthRepositoryImpl.login] -> ${e.toString()} \n $st");
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(authClientProvider),
    ref.read(authLocalStorageProvider),
    ref.read(authSecureStorageProvider),
    ref.read(conversationDaoProvider),
  ),
);
