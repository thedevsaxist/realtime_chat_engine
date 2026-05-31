import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/providers/unread_provider.dart';

import 'package:realtime_chat_engine/core/theme/app_theme_extension.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/core/theme/app_text_styles.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/available_users.dart';
import 'package:realtime_chat_engine/features/home/presentation/controller/home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void showError(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state is HomeControllerStateError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.e)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state is HomeControllerStateLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state is HomeControllerStateError) {
      if (kDebugMode) {
        debugPrint(state.e);

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                spacing: 32,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.e),
                  Text(state.st.toString()),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(homeControllerProvider),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        showError(context);
      }
    }

    if (state is HomeControllerStateSuccess) {
      return Scaffold(
        appBar: AppBar(
          leadingWidth: 55,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  state.user.firstName.split('')[0].toUpperCase(),
                  style: TextStyle(fontWeight: AppFontWeight.extraBold, color: Colors.black),
                ),
              ),
            ),
          ),
          centerTitle: false,
          title: Text(
            "Chats",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: AppFontWeight.bold),
          ),

          actions: [
            IconButton.filled(
              iconSize: 22,
              padding: .zero,
              constraints: .tight(.fromRadius(16)),
              icon: Icon(Icons.add, color: context.colorScheme.onPrimary),
              onPressed: () {
                showCupertinoSheet(
                  context: context,
                  builder: (sheetContext) {
                    return AvailableUsers(
                      currentUserId: state.user.id,
                      onConversationCreated: (conversationId, receiverName) {
                        Navigator.of(context).pushNamed(
                          "/chat",
                          arguments: {
                            'conversationId': conversationId,
                            'receiverName': receiverName,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final ConversationEntity conversation = state.conversations[index];
                  final messages = conversation.messages ?? [];
                  final lastMessage = messages.isNotEmpty
                      ? messages.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b)
                      : null;

                  final otherParticipant = conversation.participants?.firstWhereOrNull(
                    (p) => p.userId != state.user.id,
                  );

                  final displayName =
                      "${otherParticipant?.firstName} ${otherParticipant?.lastName}";

                  if (lastMessage == null) {
                    return ListTile(
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {'conversationId': conversation.id, 'receiverName': displayName},
                      ),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(displayName, style: TextStyle(letterSpacing: 0)),
                      titleTextStyle: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.semiBold),
                      subtitle: const Text('No messages yet', style: TextStyle(fontStyle: .italic)),
                      subtitleTextStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),
                    );
                  }

                  final timeSent = lastMessage.createdAt;
                  final time = timeSent.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                      ? DateFormat('MM/dd/yyyy').format(timeSent)
                      : DateFormat('HH:mm').format(timeSent);

                  final unreadAsync = ref.watch(unreadCountProvider(conversation.id));

                  return ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: {'conversationId': conversation.id, 'receiverName': displayName},
                    ),
                    leading: const CircleAvatar(child: Icon(Icons.person)),

                    title: Text(displayName, style: TextStyle(letterSpacing: -1)),
                    titleTextStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.semiBold),

                    subtitle: Text(lastMessage.content, overflow: .ellipsis, maxLines: 2),
                    subtitleTextStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),

                    trailing: unreadAsync.whenOrNull(
                      data: (count) => Column(
                        crossAxisAlignment: .end,
                        mainAxisAlignment: .center,
                        spacing: 8,
                        children: [
                          Text(
                            time,
                            style: AppTextStyle.labelSmall.copyWith(
                              fontWeight: count > 0 ? AppFontWeight.semiBold : AppFontWeight.medium,
                              color: count > 0
                                  ? context.appTheme.brandPrimary
                                  : context.colorScheme.onSurfaceVariant,
                            ),
                          ),

                          count > 0
                              ? Badge(
                                  label: Text('$count'),
                                  backgroundColor: context.appTheme.brandPrimary,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
