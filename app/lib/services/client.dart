import 'package:intl/intl.dart';
import 'package:pushpop/models/messages.dart';
import 'data.dart';
import 'notice.dart';
import 'msg_provider.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> handleNewMessage(messageData, ref) async {
  String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  Message message = Message(
    type: messageData['type'],
    time: currentTime,
    title: messageData['title'],
    content: messageData['content'],
  );
  ref.read(messageProvider.notifier).addMessage(message);

  saveMessage(message);
  showLocalNotification(message);
}

void createSSEConnection(apiKey, WidgetRef ref) async {
  SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url:
      'http://127.0.0.1:8080/events/$apiKey',
      header: {
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache",
      }).listen((event) {
          // print('Id: ' + event.id!);
          print('Event: ' + event.event!);
          print('Data: ' + event.data!);
          Map<String, dynamic> messageData = jsonDecode(event.data!);
          print(messageData);
          handleNewMessage(messageData, ref);
          // showLocalNotification(messageData);
          
      },
  );

}
