import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/app_spacing.dart';
import 'package:realtime_chat_engine/core/theme/padding_styles.dart';
import 'package:realtime_chat_engine/core/theme/radius_styles.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/message_entity.dart';
import 'package:realtime_chat_engine/features/chat/presentation/controller/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      final isAway = scrollController.position.maxScrollExtent - scrollController.offset > 200;
      if (isAway != _showScrollButton) setState(() => _showScrollButton = isAway);
    });
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.conversationId));
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView.separated(
                        controller: scrollController,
                        separatorBuilder: (context, index) => AppSpacing.sh,
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final data = state.messages[index];

                          if (data.senderId != state.user.id) {
                            return ChatBubble(
                              conversationId: widget.conversationId,
                              data: data,
                              alignment: Alignment.centerLeft,
                              bubbleColor: AppColors.grayBubble,
                              textColor: AppColors.neutral900,
                            );
                          }

                          if (data.senderId == state.user.id) {
                            return ChatBubble(
                              conversationId: widget.conversationId,
                              data: data,
                              alignment: Alignment.centerRight,
                              bubbleColor: AppColors.primaryBlue,
                              textColor: AppColors.neutral100,
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),

                    if (_showScrollButton)
                      Positioned(
                        bottom: 8,
                        right: 0,
                        left: 0,
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton.filled(
                            onPressed: _scrollToBottom,
                            icon: Icon(Icons.arrow_downward),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              TextField(
                maxLines: 4,
                minLines: 1,
                controller: messageController,
                style: TextStyle(height: 1.3),
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textColorGray),
                  contentPadding: AppPaddingStyles.paddingH8V4,
                  filled: true,
                  fillColor: AppColors.textFieldColor,
                  suffix: GestureDetector(
                    onTap: () {
                      ref
                          .read(chatControllerProvider(widget.conversationId).notifier)
                          .sendMessage(messageController.text);
                      messageController.clear();

                      _scrollToBottom();
                    },

                    child: Icon(Icons.send),
                  ),
                  border: OutlineInputBorder(borderSide: .none, borderRadius: AppRadiusStyles.full),
                  enabledBorder: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: AppRadiusStyles.borderRadius12,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: AppRadiusStyles.borderRadius12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatBubble extends ConsumerWidget {
  const ChatBubble({
    super.key,
    required this.data,
    required this.alignment,
    required this.textColor,
    required this.bubbleColor,
    required this.conversationId,
  });

  final MessageEntity data;
  final AlignmentGeometry alignment;
  final Color textColor;
  final Color bubbleColor;

  final String conversationId;

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
          // width: 220,
          constraints: BoxConstraints(maxWidth: 220),
          padding: AppPaddingStyles.paddingH16V12,
          decoration: BoxDecoration(
            borderRadius: AppRadiusStyles.borderRadius16,
            color: bubbleColor,
          ),
          child: Text(
            data.content,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
