import 'package:realtime_chat_engine/features/auth/domain/entities/login_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_res_entity.dart';

abstract class AuthRepository {
  Future<LoginResEntity> login(LoginReqEntity reqEntity);
}