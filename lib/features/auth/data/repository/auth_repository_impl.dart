import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:realtime_chat_engine/core/shared/app_exception.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_client.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_res_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/repository/auth_repository.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_res_entity.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_secure_storage.dart';
import 'package:realtime_chat_engine/features/home/data/data_source/conversation_database.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthClient _authClient;
  final ConversationDao _conversationDao;
  final AuthLocalStorage _authLocalStorage;
  final AuthSecureStorage _authSecureStorage;

  AuthRepositoryImpl(
    this._authClient,
    this._conversationDao,
    this._authLocalStorage,
    this._authSecureStorage,
  );

  @override
  Future<Result<RegisterResEntity, AppException>> register(RegisterReqEntity reqEntity) async {
    final result = await _authClient.register(reqEntity.toModel());

    return result.when(
      (response) async {
        if (response.token.isNotEmpty) {
          await _authLocalStorage.saveUser(response.user);
          await _authSecureStorage.saveToken(response.token, response.refreshToken);
        }
        return Success(RegisterResEntity.fromModel(response));
      },
      (error) => Error(error),
    );
  }

  @override
  Future<LoginResEntity> login(LoginReqEntity reqEntity) async {
    try {
      final result = await _authClient.login(reqEntity.toModel());

      if (result.token.isNotEmpty) {
        await _authLocalStorage.saveUser(result.user);
        await _authSecureStorage.saveToken(result.token, result.refreshToken);

        // Populate both tables used by `ConversationDao.getUserConversations()`:
        // - `conversations`: the INNER JOIN base table
        // - `user_conversations`: the join/link table
        for (final conversation in result.conversations) {
          await _conversationDao.insertConversation(conversation);
          await _conversationDao.linkUserToConversation(result.user.id, conversation.id);
        }
      }

      return LoginResEntity.fromModel(result);
    } catch (e, st) {
      throw AppException(
        errorClass: 'AuthRepositoryImpl',
        errorMethod: 'login',
        message: e.toString(),
        stackTrace: st,
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    ref.read(authClientProvider),
    ref.read(conversationDaoProvider),
    ref.read(authLocalStorageProvider),
    ref.read(authSecureStorageProvider),
  ),
);
