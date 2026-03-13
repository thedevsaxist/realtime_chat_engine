import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/core/theme/app_colors.dart';
import 'package:realtime_chat_engine/core/theme/padding_styles.dart';
import 'package:realtime_chat_engine/core/theme/radius_styles.dart';
import 'package:realtime_chat_engine/features/home/presentation/controller/chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatControllerProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: state.length,
              itemBuilder: (context, index) {
                final data = state[index];

                return GestureDetector(
                  onLongPress: () => ref.read(chatControllerProvider.notifier).deleteMessage(data.id),
                  child: Container(
                    width: 100,
                    padding: AppPaddingStyles.paddingH8V4,
                    decoration: BoxDecoration(
                      borderRadius: AppRadiusStyles.borderRadius16,
                      color: AppColors.primaryBlue500,
                    ),
                    child: Text(
                      data.content,
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
