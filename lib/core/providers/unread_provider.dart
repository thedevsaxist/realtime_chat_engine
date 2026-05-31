import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';
import 'package:realtime_chat_engine/features/auth/data/data_source/auth_local_storage.dart';

import 'incoming_message_provider.dart';
import 'incoming_read_receipt_provider.dart';

final unreadCountProvider = FutureProvider.family.autoDispose<int, String>((
  ref,
  conversationId,
) async {
  // Invalidate when a new message arrives in this conversation
  ref.listen(incomingMessageProvider, (_, next) {
    next.whenData((message) {
      if (message.conversationId == conversationId) {
        ref.invalidateSelf();
      }
    });
  });

  ref.listen(incomingReadReceiptProvider, (_, next) {
    next.whenData((receipt) {
      if (receipt.conversationId == conversationId) {
        ref.invalidateSelf();
      }
    });
  });

  final user = await ref.read(authLocalStorageProvider).getUser('unreadCountProvider');
  if (user == null || user.id.isEmpty) return 0;

  return ref
      .read(chatRepositoryProvider)
      .getUnreadCount(conversationId: conversationId, userId: user.id);
});
