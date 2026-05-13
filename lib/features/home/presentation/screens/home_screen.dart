import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/features/auth/presentation/controller/auth_controller.dart';
import 'package:realtime_chat_engine/features/home/domain/entities/conversation_entity.dart';
import 'package:realtime_chat_engine/features/home/presentation/controller/home_controller.dart';
import 'package:realtime_chat_engine/features/home/presentation/screens/available_users.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void showError() {
    final state = ref.watch(homeControllerProvider);

    if (state is HomeControllerStateError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
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
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                spacing: 32,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  Text(state.stackTrace),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(homeControllerProvider),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (state is HomeControllerStateSuccess) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            "${state.user.firstName}'s Chats",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: AppFontWeight.bold),
          ),
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

                  final otherParticipant = conversation.participants?.firstWhere(
                    (p) => p.userId != state.user.id,
                    orElse: () => conversation.participants!.first,
                  );
                  
                  final displayName = otherParticipant?.userId ?? conversation.id;

                  if (lastMessage == null) {
                    return ListTile(
                      onTap: () => Navigator.pushNamed(context, '/chat', arguments: conversation.id),
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(displayName),
                      titleTextStyle: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.semiBold),
                      subtitle: const Text('No messages yet'),
                      subtitleTextStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),
                    );
                  }

                  final timeSent = lastMessage.createdAt;
                  final time = timeSent.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                      ? DateFormat('MM/dd/yyyy').format(timeSent)
                      : DateFormat('HH:mm').format(timeSent);

                  return ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: conversation.id,
                    ),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(displayName),
                    titleTextStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.semiBold),
                    subtitle: Text(lastMessage.content),
                    subtitleTextStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),
                    trailing: Text(
                      time,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(fontWeight: AppFontWeight.medium),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: .symmetric(horizontal: 16, vertical: 12),
                backgroundColor: Colors.red,
              ),
              onPressed: () => ref.read(authControllerProvider.notifier).logOut(),
              child: Text(
                "Log out",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showCupertinoSheet(
              context: context,
              builder: (context) {
                return AvailableUsers(currentUserId: state.user.id);
              },
            );
          },
          child: Icon(Icons.edit),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
