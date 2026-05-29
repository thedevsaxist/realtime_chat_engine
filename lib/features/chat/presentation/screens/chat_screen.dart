import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/app_spacing.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
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

  late final ChatController _chatController;
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _chatController = ref.read(chatControllerProvider(widget.conversationId).notifier);
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final isAway = _scrollController.position.maxScrollExtent - _scrollController.offset > 200;
      if (isAway != _showScrollButton) setState(() => _showScrollButton = isAway);
    });

    messageController.addListener(() => setState(() {}));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _markAsReadIfViewing();
  }

  bool get _isViewingLatest {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    final nearBottom = position.maxScrollExtent - position.pixels < 200;
    final nearTop = position.pixels < 200;
    return nearBottom || nearTop;
  }

  void _onScroll() {
    if (_isViewingLatest) _markAsReadIfViewing();
  }

  void _markAsReadIfViewing() {
    if (!_isViewingLatest) return;
    _chatController.markLatestAsRead();
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
    _chatController.markLatestAsRead();
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider(widget.conversationId));

    ref.listen(
      chatControllerProvider(widget.conversationId).select((state) => state.messages.length),
      (prev, next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (next > (prev ?? 0)) _scrollToBottom();
          _markAsReadIfViewing();
        });
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
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 0, 0),
                  filled: true,
                  fillColor: AppColors.textFieldColor,
                  suffixIcon: messageController.text.isNotEmpty
                      ? Align(
                          widthFactor: 1,
                          heightFactor: 1,
                          alignment: .bottomCenter,
                          child: IconButton.filled(
                            onPressed: () {
                              ref
                                  .read(chatControllerProvider(widget.conversationId).notifier)
                                  .sendMessage(messageController.text.trim());

                              messageController.clear();
                            },
                            icon: Icon(Icons.arrow_upward),
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(borderSide: .none, borderRadius: AppRadiusStyles.full),
                  enabledBorder: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: AppRadiusStyles.borderRadius24,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: .none,
                    borderRadius: AppRadiusStyles.borderRadius24,
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
