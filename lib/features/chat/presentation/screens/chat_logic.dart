part of 'chat_screen.dart';

mixin ChatLogic on ConsumerState<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late final ChatController _chatController;
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _chatController = ref.read(chatControllerProvider(widget.conversationId).notifier);
    _scrollController.addListener(_onScroll);

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final isAway = _scrollController.position.maxScrollExtent - _scrollController.offset > 200;
      if (isAway != _showScrollButton) setState(() => _showScrollButton = isAway);
    });

    messageController.addListener(() => setState(() {}));
  }

  ChatData watchState() {
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

    return state;
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
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
