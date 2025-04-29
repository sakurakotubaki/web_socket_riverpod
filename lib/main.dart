import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

// build_runner watch command
// flutter pub run build_runner watch --delete-conflicting-outputs

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// Message model for chat
class Message {
  final String content;
  final bool sentByMe;

  Message({required this.content, required this.sentByMe});
}

// WebSocket connection provider
@riverpod
WebSocketChannel webSocketChannel(Ref ref) {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );
  
  ref.onDispose(() {
    channel.sink.close();
  });
  
  return channel;
}

// Provider for WebSocket stream
@riverpod
Stream<dynamic> webSocketStream(Ref ref) {
  final channel = ref.watch(webSocketChannelProvider);
  return channel.stream;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo with Riverpod';
    return const MaterialApp(title: title, home: MyHomePage(title: title));
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageController = TextEditingController();
    final socketData = ref.watch(webSocketStreamProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Send a message'),
            ),
            const SizedBox(height: 24),
            switch(socketData) {
              AsyncData() => Text('${socketData.value}'),
              AsyncError(:final error) => Text('Error: $error'),
              _ => const CircularProgressIndicator(),
            }
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (messageController.text.isNotEmpty) {
            // メッセージを送信
            ref.read(webSocketChannelProvider).sink.add(messageController.text);
          }
        },
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ),
    );
  }
}