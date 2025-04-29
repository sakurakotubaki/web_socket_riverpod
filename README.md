### WebSocketとは？
WebSocketは、双方向通信を可能にする通信プロトコルです。クライアント（例: Webブラウザ）とサーバー間で、持続的な接続を確立し、リアルタイムでデータを送受信することができます。HTTPのようにリクエストとレスポンスの繰り返しではなく、一度接続が確立されると、双方が自由にデータを送信できます。

<img src="assets/web-socket2.png" alt="WebSocketの通信フロー" width="600"/>

---

### どのようなケースで使う？
WebSocketは、リアルタイム性が求められる以下のようなケースで使用されます：
- **チャットアプリケーション**（例: Slack, Discord）
- **リアルタイム通知**（例: 株価やスポーツのスコア更新）
- **オンラインゲーム**（例: マルチプレイヤーゲーム）
- **コラボレーションツール**（例: Google Docsのリアルタイム編集）
- **IoTデバイスとの通信**（例: センサーやスマートデバイスのデータ送受信）

---

### プロトコルはHTTPと違う？
はい、WebSocketはHTTPとは異なるプロトコルです。ただし、WebSocket接続は最初にHTTPを使用してハンドシェイクを行い、その後、WebSocketプロトコルに切り替わります。

#### 主な違い：
1. **通信モデル**:
    - HTTP: リクエスト/レスポンス型（クライアントがリクエストを送信し、サーバーが応答）
    - WebSocket: 双方向通信（クライアントとサーバーが自由にデータを送受信）

2. **接続の持続性**:
    - HTTP: 通常、リクエストごとに接続を開閉
    - WebSocket: 接続を維持し続ける

3. **プロトコルのレイヤー**:
    - HTTP: アプリケーション層プロトコル
    - WebSocket: 独自のプロトコル（TCP上で動作）

4. **ヘッダーのオーバーヘッド**:
    - HTTP: 各リクエスト/レスポンスにヘッダーが付与される
    - WebSocket: 一度接続が確立されると、ヘッダーのオーバーヘッドが少ない

WebSocketは、リアルタイム性や効率性が求められるアプリケーションに適していますが、HTTPは汎用的な通信に適しています。

## FlutterでのWebSocketの実装
公式の解説を参考に実装していきます。

[Communicate with WebSockets](https://docs.flutter.dev/cookbook/networking/web-sockets)

専用のライブラリを追加する。

https://pub.dev/packages/web_socket_channel

```shell
flutter pub add web_socket_channel
```

1. WebSocketサーバーに接続する
   web_socket_channel パッケージは、WebSocket サーバーに接続するために必要なツールを提供します。

このパッケージはWebSocketChannelを提供し、サーバからのメッセージをリッスンしたり、サーバにメッセージをプッシュしたりできる。

Flutterでは、以下の行を使ってサーバに接続するWebSocketChannelを作成する：

```dart
final channel = WebSocketChannel.connect(
  Uri.parse('wss://echo.websocket.events'),
);
```

2. サーバーからのメッセージを聞く
   接続が確立したら、サーバーからのメッセージを聞く。

テスト・サーバにメッセージを送信した後、同じメッセージを送り返します。

この例では、StreamBuilder ウィジェットを使って新しいメッセージをリッスンし、Text ウィジェットを使ってメッセージを表示します。

```dart
StreamBuilder(
  stream: channel.stream,
  builder: (context, snapshot) {
    return Text(snapshot.hasData ? '${snapshot.data}' : '');
  },
),
```

この仕組み
WebSocketChannelはサーバからのメッセージのStreamを提供します。

Streamクラスはdart:asyncパッケージの基本的な部分です。これは、データソースからの非同期イベントをリッスンする方法を提供します。単一の非同期応答を返す Future とは異なり、Stream クラスは時間をかけて多くのイベントを配信することができます。

StreamBuilderウィジェットはStreamに接続し、与えられたbuilder()関数を使ってイベントを受け取るたびにFlutterに再構築を依頼します。

3. サーバにデータを送る
   サーバにデータを送信するには、WebSocketChannelが提供するシンクにメッセージをadd()する。

```dart
channel.sink.add('Hello!');
```

この仕組み
WebSocketChannel は、サーバにメッセージをプッシュするための StreamSink を提供します。

StreamSink クラスは、同期または非同期のイベントをデータソースに追加する一般的な方法を提供します。

4. WebSocket 接続を閉じる
   WebSocket の使用が終わったら、接続を閉じます：
```dart
channel.sink.close();
```

**完全な例**

```dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(title: title, home: MyHomePage(title: title));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final _channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: const InputDecoration(labelText: 'Send a message'),
              ),
            ),
            const SizedBox(height: 24),
            StreamBuilder(
              stream: _channel.stream,
              builder: (context, snapshot) {
                return Text(snapshot.hasData ? '${snapshot.data}' : '');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }
}
```