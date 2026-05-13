import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller/available_users_controller.dart';

class AvailableUsers extends ConsumerStatefulWidget {
  final String currentUserId;
  const AvailableUsers({super.key, required this.currentUserId});

  @override
  ConsumerState<AvailableUsers> createState() => _AvailableUsersState();
}

class _AvailableUsersState extends ConsumerState<AvailableUsers> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(availableUsersController.notifier).search(widget.currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(availableUsersController);

    if (state is NoAvailableUsers) {
      return Center(child: Text("No users found"));
    }

    if (state is ErrorState) {
      debugPrint("Something went wrong ${state.message}");
    }

    if (state is LoadingState) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is UsersAvailable) {
      final users = state.users;

      return Scaffold(
        appBar: AppBar(
          title: Text("Select a user to start chatting"),
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),

        body: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            return ListTile(
              onTap: () async {
                final conversationId = await ref
                    .read(availableUsersController.notifier)
                    .createConversation(userId: widget.currentUserId, selectedUserId: user.id);

                print("Conversation id $conversationId");

                if (conversationId.isNotEmpty) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/chat", arguments: conversationId);
                }
              },
              title: Text("${user.firstName} ${user.lastName}"),
              subtitle: Text("(${user.email})"),
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
