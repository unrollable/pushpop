import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pushpop/models/messages.dart';
import 'package:pushpop/models/settings.dart';
import 'package:pushpop/services/data.dart';
import 'package:pushpop/utils/util.dart';
import 'dart:async';
import 'client.dart';
import 'notice.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final messageProvider =
    StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  final notifier = MessageNotifier(ref);
  notifier.loadInitialMessages();
  return notifier;
});

class MessageNotifier extends StateNotifier<List<Message>> {
  final Ref ref;
  StreamSubscription? sseSubscription;
  Timer? heartbeatTimer;

  MessageNotifier(this.ref) : super([]);

  void loadInitialMessages() {
    List<Message> initialMessages = getMessages();
    state = initialMessages;
    _initSSEConnection();
  }

  void _initSSEConnection() async {
    Settings settings = getSettings();
    if (settings.apiKey.isEmpty || settings.apiKey == null) {
      settings = await updateSetting('apiKey', genApiKey());
    }

    sseSubscription?.cancel();
    sseSubscription = createSSEConnection(ref).listen((message) {
      handleNewMessage(message);
    });

    heartbeatTimer?.cancel();
    heartbeatTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      _sendHeartbeat(settings);
    });
  }

  void handleNewMessage(Message message) async {
    saveMessage(message);
    showLocalNotification(message);
    addMessageToPage(message);
  }

  void addMessageToPage(Message message) {
    state = [...state, message];
  }

  void _sendHeartbeat(Settings settings) async {
    try {
      var server = settings.serverHost;
      var port = settings.serverPort;
      var url = 'http://$server:$port/heartbeat';
      print("send heartbeat to $url");
      await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"apikey": settings.apiKey}),
      );
    } catch (e) {
      print("Heartbeat error: $e");
    }
  }

  void closeConnect() {
    sseSubscription?.cancel();
    heartbeatTimer?.cancel();
    SSEClient.unsubscribeFromSSE();
  }

  void reconnect() {
    closeConnect();
    _initSSEConnection();
  }

  @override
  void dispose() {
    closeConnect();
    super.dispose();
  }
}
