import 'package:multiple_result/multiple_result.dart';
import 'package:realtime_chat_engine/core/shared/app_exception.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/login_res_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_req_entity.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/register_res_entity.dart';

abstract class AuthRepository {
  Future<LoginResEntity> login(LoginReqEntity reqEntity);
  Future<Result<RegisterResEntity, AppException>> register(RegisterReqEntity reqEntity);
}