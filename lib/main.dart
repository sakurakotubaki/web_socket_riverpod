import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main.g.dart';

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

// Provider to store all messages
@riverpod
class Messages extends _$Messages {
  @override
  List<Message> build() {
    return [];
  }
  
  void addMessage(String content, bool sentByMe) {
    state = [...state, Message(content: content, sentByMe: sentByMe)];
  }
}

// Provider for WebSocket stream
@riverpod
Stream<String> webSocketStream(Ref ref) {
  final channel = ref.watch(webSocketChannelProvider);
  return channel.stream.map((event) => event.toString());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Chat Demo';
    return const MaterialApp(title: title, home: MyHomePage(title: title));
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the WebSocket stream and add received messages
    ref.listen<AsyncValue<String>>(
      webSocketStreamProvider, 
      (_, state) {
        state.whenData((data) {
          if (data.isNotEmpty) {
            ref.read(messagesProvider.notifier).addMessage(data, false);
          }
        });
      }
    );

    final messages = ref.watch(messagesProvider);
    final webSocketState = ref.watch(webSocketStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          switch(webSocketState) {
            AsyncData(:final value) => ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
            ),
            AsyncError(:final error) => Text('Error Code $error'),
            _ => const CircularProgressIndicator(),
          }
        ],
      ),
      body: Column(
        children: [
          // WebSocket connection status
          webSocketState.when(
            data: (_) => Container(),
            error: (error, stackTrace) => Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              width: double.infinity,
              child: Text(
                'WebSocket error: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
          ),
          // Messages list - takes most of the screen
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          // Input area fixed at the bottom
          MessageInputField(),
        ],
      ),
    );
  }
}

// Message bubble widget
class MessageBubble extends StatelessWidget {
  final Message message;
  
  const MessageBubble({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: message.sentByMe 
              ? Theme.of(context).primaryColor 
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.sentByMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

// Message input field widget
class MessageInputField extends ConsumerStatefulWidget {
  const MessageInputField({super.key});

  @override
  ConsumerState<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends ConsumerState<MessageInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      
      // Send message through WebSocket
      ref.read(webSocketChannelProvider).sink.add(message);
      
      // Add to messages list
      ref.read(messagesProvider.notifier).addMessage(message, true);
      
      // Clear input field
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // WebSocketの状態を監視して、接続が切れている場合は入力を無効化
    final webSocketState = ref.watch(webSocketStreamProvider);
    final bool isConnected = webSocketState is! AsyncError;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:  0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Text input field
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: isConnected ? 'Type a message' : 'WebSocket disconnected',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
              enabled: isConnected,
            ),
          ),
          // Send button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: isConnected ? _sendMessage : null,
            color: isConnected ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ],
      ),
    );
  }
}