import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realtime_chat_engine/features/home/presentation/controller/home_controller.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeControllerProvider);

    if (state is HomeControllerStateLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state is HomeControllerStateError) {
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

    if (state is HomeControllerStateSuccess) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.data.data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(state.data.data.values.elementAt(index).first.senderId),
                    subtitle: Text(state.data.data.values.elementAt(index).first.content),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
