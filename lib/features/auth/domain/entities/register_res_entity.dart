import 'package:realtime_chat_engine/features/auth/data/models/register_res_model.dart';
import 'package:realtime_chat_engine/features/auth/domain/entities/user_entity.dart';

class RegisterResEntity {
  final String token;
  final UserEntity user;

  RegisterResEntity({required this.token, required this.user});

  factory RegisterResEntity.fromModel(RegisterResModel model) {
    return RegisterResEntity(token: model.token, user: UserEntity.fromModel(model.user));
  }

  RegisterResModel toModel() {
    return RegisterResModel(token: token, user: user.toModel());
  }
}
