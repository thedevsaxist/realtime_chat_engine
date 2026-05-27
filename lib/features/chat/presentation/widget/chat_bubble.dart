import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/padding_styles.dart';
import 'package:realtime_chat_engine/core/theme/radius_styles.dart';
import 'package:realtime_chat_engine/features/chat/presentation/controller/chat_controller.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';

class ChatBubble extends ConsumerWidget {
  final MessageEntity data;
  final AlignmentGeometry alignment;
  final Color textColor;
  final Color bubbleColor;
  final String conversationId;
  final String currentUserId;

  const ChatBubble({
    super.key,
    required this.data,
    required this.alignment,
    required this.textColor,
    required this.bubbleColor,
    required this.conversationId,
    required this.currentUserId,
  });

  Widget buildReadTick(MessageEntity message, String currentUserId) {
    if (message.senderId != currentUserId || !(message.isRead ?? false)) {
      return const SizedBox.shrink();
    }

    return Icon(Icons.check_circle, size: 13, color: Colors.white);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onLongPress: () {
          showMenu(
            position: RelativeRect.fromLTRB(120, 210, 0, 0),
            context: context,
            items: [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () => ref
                      .read(chatControllerProvider(conversationId).notifier)
                      .deleteMessage(data.id),
                  child: Row(children: [Icon(Icons.delete_rounded), Text("Delete message")]),
                ),
              ),
            ],
          );
        },
        child: Container(
          constraints: BoxConstraints(maxWidth: 220),
          padding: AppPaddingStyles.paddingA12,
          decoration: BoxDecoration(
            borderRadius: AppRadiusStyles.borderRadius16,
            color: bubbleColor,
          ),
          child: Column(
            spacing: 8,
            crossAxisAlignment: .end,
            children: [
              Text(
                data.content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
              ),

              Row(
                spacing: 4,
                mainAxisAlignment: .end,
                mainAxisSize: .min,
                children: [
                  Text(
                    TimeOfDay.fromDateTime(data.createdAt).format(context),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor),
                  ),

                  if (alignment == Alignment.centerRight) buildReadTick(data, currentUserId),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
