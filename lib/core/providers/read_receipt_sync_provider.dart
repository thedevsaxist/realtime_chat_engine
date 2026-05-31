import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/chat/data/repo/chat_repository_impl.dart';

import 'incoming_read_receipt_provider.dart';

/// Persists peer read receipts while the app is running (even off the chat screen).
final readReceiptSyncProvider = Provider<void>((ref) {
  ref.listen(incomingReadReceiptProvider, (_, next) {
    next.whenData((receipt) {
      ref
          .read(chatRepositoryProvider)
          .savePeerReadReceipt(
            conversationId: receipt.conversationId,
            lastMessageId: receipt.lastMessageId,
            lastReadAt: receipt.readAt,
          );
    });
  });
});
