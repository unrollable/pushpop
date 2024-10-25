import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pushpop/models/messages.dart';
import 'package:pushpop/services/data.dart';

final messageProvider =
    StateNotifierProvider<MessageNotifier, List<Message>>((ref) {
  return MessageNotifier.loadInitialMessages();
});

class MessageNotifier extends StateNotifier<List<Message>> {
  MessageNotifier(List<Message> initialState) : super(initialState);

  static MessageNotifier loadInitialMessages() {
    List<Message> initialMessages = getMessages();
    return MessageNotifier(initialMessages);
  }

  void addMessage(Message message) {
    state = [...state, message];
  }
}
