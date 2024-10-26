import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pushpop/models/messages.dart';
import 'package:pushpop/models/settings.dart';
import 'package:pushpop/services/data.dart';
import 'package:pushpop/utils/util.dart';
import 'dart:async';
import 'client.dart';
import 'notice.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

final messageProvider =
    StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  final notifier = MessageNotifier(ref);
  notifier.loadInitialMessages();
  return notifier;
});

class MessageNotifier extends StateNotifier<List<Message>> {
  final Ref ref;
  StreamSubscription? sseSubscription;

  MessageNotifier(this.ref) : super([]);

  void loadInitialMessages() {
    List<Message> initialMessages = getMessages();
    state = initialMessages;
    _initSSEConnection();
  }

  void _initSSEConnection() async {
    Settings settings = getSettings();
    if (settings.apiKey.isEmpty || settings.apiKey == null) {
      await updateSetting('apiKey', genApiKey());
    }

    sseSubscription = createSSEConnection(ref).listen((message) {
      handleNewMessage(message);
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

  void closeConnect() {
    sseSubscription?.cancel();
    SSEClient.unsubscribeFromSSE();
  }

  void reconnect() {
    closeConnect();
    _initSSEConnection();
  }

  @override
  void dispose() {
    sseSubscription?.cancel();
    super.dispose();
  }
}
