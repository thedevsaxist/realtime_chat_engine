import 'package:realtime_chat_engine/features/chat/data/models/get_peer_read_position_res_model.dart';

class GetPeerReadPositionResEntity {
  final String lastReadMessageId;
  final DateTime lastReadAt;

  const GetPeerReadPositionResEntity({required this.lastReadAt, required this.lastReadMessageId});

  factory GetPeerReadPositionResEntity.fromModel(GetPeerReadPositionResModel model) {
    return GetPeerReadPositionResEntity(
      lastReadAt: model.lastReadAt,
      lastReadMessageId: model.lastReadMessageId,
    );
  }

  GetPeerReadPositionResModel toModel() =>
      GetPeerReadPositionResModel(lastReadAt: lastReadAt, lastReadMessageId: lastReadMessageId);
}
