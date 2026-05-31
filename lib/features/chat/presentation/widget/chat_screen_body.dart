part of '../screens/chat_screen.dart';

final class _ChatScreenBody extends ConsumerWidget {
  const _ChatScreenBody({
    required this.messageController,
    required this.scrollController,
    required this.conversationId,
    required this.state,
    required this.showScrollButton,
    required this.onScrollToBottom,
  });

  final TextEditingController messageController;
  final ScrollController scrollController;
  final String conversationId;
  final ChatData state;
  final bool showScrollButton;
  final VoidCallback onScrollToBottom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final state = watchState();
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ListView.separated(
                    controller: scrollController,
                    separatorBuilder: (context, index) => AppSpacing.height8(),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final data = state.messages[index];

                      if (data.senderId != state.user.id) {
                        return ChatBubble(
                          conversationId: conversationId,
                          data: data,
                          alignment: Alignment.centerLeft,
                          bubbleColor: context.appTheme.grayBubble,
                          textColor: context.colorScheme.onSurface,
                          currentUserId: state.user.id,
                        );
                      }

                      if (data.senderId == state.user.id) {
                        return ChatBubble(
                          conversationId: conversationId,
                          data: data,
                          alignment: Alignment.centerRight,
                          bubbleColor: context.colorScheme.primary,
                          textColor: context.colorScheme.onPrimary,
                          currentUserId: state.user.id,
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),

                if (showScrollButton)
                  Positioned(
                    bottom: 8,
                    right: 0,
                    left: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: IconButton.filled(
                        onPressed: onScrollToBottom,
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          AppSpacing.height16(),

          TextField(
            maxLines: 4,
            minLines: 1,
            controller: messageController,
            style: TextStyle(height: 1.3),
            decoration: InputDecoration(
              hintText: "Type a message",
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: context.appTheme.textColorGray),
              contentPadding: EdgeInsets.fromLTRB(12, 16, 0, 0),
              filled: true,
              fillColor: context.appTheme.textFieldColor,
              suffixIcon: messageController.text.isNotEmpty
                  ? Align(
                      widthFactor: 1,
                      heightFactor: 1,
                      alignment: .bottomCenter,
                      child: IconButton.filled(
                        onPressed: () {
                          ref
                              .read(chatControllerProvider(conversationId).notifier)
                              .sendMessage(messageController.text.trim());

                          messageController.clear();
                        },
                        icon: Icon(Icons.arrow_upward),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(borderSide: .none, borderRadius: AppRadius.circle),
              enabledBorder: OutlineInputBorder(
                borderSide: .none,
                borderRadius: AppRadius.circular24,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: .none,
                borderRadius: AppRadius.circular24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
