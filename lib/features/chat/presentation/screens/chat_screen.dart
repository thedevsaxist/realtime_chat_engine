import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/app_spacing.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/core/theme/radius_styles.dart';
import 'package:realtime_chat_engine/core/theme/text_styles.dart';
import 'package:realtime_chat_engine/features/chat/presentation/widget/chat_bubble.dart';
import 'package:realtime_chat_engine/features/chat/presentation/controller/chat_controller.dart';

part 'chat_logic.dart';
part '../widget/chat_screen_body.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String receiverName;
  const ChatScreen({super.key, required this.conversationId, required this.receiverName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver, ChatLogic {
  @override
  void initState() {
    super.initState(); // ChatLogic.initState() runs here
    WidgetsBinding.instance.addObserver(this); // ← this is now _ChatScreenState ✓
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ← same here
    super.dispose(); // ChatLogic.dispose() runs here
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _markAsReadIfViewing();
  }

  @override
  Widget build(BuildContext context) {
    final state = watchState();

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
        body: _ChatScreenBody(
          messageController: messageController,
          scrollController: _scrollController,
          conversationId: widget.conversationId,
          state: state,
          showScrollButton: _showScrollButton,
          onScrollToBottom: _scrollToBottom,
        ),
      ),
    );
  }
}
