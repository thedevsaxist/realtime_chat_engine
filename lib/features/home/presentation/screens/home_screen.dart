import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:realtime_chat_engine/core/theme/font_weights.dart';
import 'package:realtime_chat_engine/features/home/presentation/controller/home_controller.dart';

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
                  ElevatedButton(onPressed: () => ref.invalidate(homeControllerProvider), child: const Text("Retry")),
                ],
              ),
            ),
          ),
        );
      }
    }

    if (state is HomeControllerStateSuccess) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.data.data.length,
                itemBuilder: (context, index) {
                  final timeSent = DateTime.parse(state.data.data.values.elementAt(index).first.createdAt);

                  String time;

                  if (timeSent.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                    final formatter = DateFormat('MM/dd/yyyy');
                    time = formatter.format(timeSent);
                  } else {
                    final formatter = DateFormat('HH:mm');
                    time = formatter.format(timeSent);
                  }

                  return ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/chat',
                      arguments: state.data.data.values.elementAt(index).first.conversationId,
                    ),
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text(state.data.data.values.elementAt(index).last.senderId),
                    titleTextStyle: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: AppFontWeight.semiBold),
                    subtitle: Text(state.data.data.values.elementAt(index).last.content),
                    subtitleTextStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: AppFontWeight.regular),

                    trailing: Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: AppFontWeight.medium),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () => ref.read(homeControllerProvider.notifier).clearCache(),
              child: Text("Clear all data"),
            ),

            const SizedBox(height: 50),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
