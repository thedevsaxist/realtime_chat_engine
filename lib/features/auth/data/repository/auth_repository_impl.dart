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

  AuthRepositoryImpl(this._authClient, this._authLocalStorage, this._authSecureStorage, this._conversationDao);

  @override
  Future<LoginResEntity> login(LoginReqEntity reqEntity) async {
    try {
      final result = await _authClient.login(reqEntity.toModel());

      if (result.token.isNotEmpty) {
        final user = User(id: result.userId, conversationIds: result.conversationIds);

        await _authLocalStorage.saveUser(user);
        await _authSecureStorage.saveToken(result.token);
        
        for (String convId in user.conversationIds){
          await _conversationDao.linkUserToConversation(user.id, convId);
        }
      }

      return LoginResEntity.fromModel(result);
    } catch (e) {
      throw Exception(e);
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
