import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

List<MessageEntity> applyPeerReadToMessages({
  required List<MessageEntity> messages,
  required String? lastReadByPeerMessageId,
  required String currentUserId,
  DateTime? peerReadAt,
}) {
  // Need at least one anchor to determine the read horizon
  if (lastReadByPeerMessageId == null && peerReadAt == null) return messages;

  DateTime? pivotAt = peerReadAt;

  // Only fall back to scanning the list if we have no timestamp at all
  if (pivotAt == null && lastReadByPeerMessageId != null) {
    pivotAt = messages.where((m) => m.id == lastReadByPeerMessageId).firstOrNull?.createdAt;
  }

  if (pivotAt == null) return messages;

  return messages.map((m) {
    if (m.senderId != currentUserId) return m;
    final isRead = !m.createdAt.isAfter(pivotAt!);
    return m.copyWith(isRead: isRead);
  }).toList();
}
