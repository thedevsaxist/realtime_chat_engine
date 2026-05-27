import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/app_spacing.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/core/theme/padding_styles.dart';
import 'package:realtime_chat_engine/core/theme/radius_styles.dart';
import 'package:realtime_chat_engine/core/theme/text_styles.dart';
import 'package:realtime_chat_engine/features/chat/presentation/widget/chat_bubble.dart';
import 'package:realtime_chat_engine/features/chat/presentation/controller/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String receiverName;
  const ChatScreen({super.key, required this.conversationId, required this.receiverName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    _scrollController.addListener(() {
      final isAway = _scrollController.position.maxScrollExtent - _scrollController.offset > 200;
      if (isAway != _showScrollButton) setState(() => _showScrollButton = isAway);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-mark when user comes back to the app
    if (state == AppLifecycleState.resumed) _markAsRead();
  }

  void _onScroll() {
    final currentPosition = _scrollController.position;
    if (currentPosition.pixels == 0) _markAsRead;
  }

  void _markAsRead() {
    final messages = ref.read(chatControllerProvider(widget.conversationId)).messages;
    final lastMessage = messages.firstOrNull;
    if (lastMessage == null) return;

    debugPrint("Marking as read: $lastMessage...");

    ref
        .read(chatControllerProvider(widget.conversationId).notifier)
        .markAsRead(lastMessageId: lastMessage.id);
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.conversationId));

    ref.listen(
      chatControllerProvider(widget.conversationId).select((state) {
        return state.messages.length;
      }),
      (prev, next) {
        if (next > (prev ?? 0)) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      },
    );

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          leadingWidth: 35,
          centerTitle: false,
          title: Text(
            widget.receiverName,
            style: AppTextStyle.titleMedium.copyWith(letterSpacing: 0),
          ),

          actionsPadding: .only(right: 10),
          actions: [
            // user's profile picture
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade300,
              child: Text(
                widget.receiverName.split('')[0].toUpperCase(),
                style: AppTextStyle.bodyLarge.copyWith(
                  fontWeight: AppFontWeight.semiBold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListView.separated(
                        controller: _scrollController,
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
                              currentUserId: state.user.id,
                            );
                          }

                          if (data.senderId == state.user.id) {
                            return ChatBubble(
                              conversationId: widget.conversationId,
                              data: data,
                              alignment: Alignment.centerRight,
                              bubbleColor: AppColors.primaryBlue,
                              textColor: AppColors.neutral100,
                              currentUserId: state.user.id,
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

              AppSpacing.mh,

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
