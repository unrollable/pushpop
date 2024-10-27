import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pushpop/models/messages.dart';
import 'data.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StreamSubscription<SSEModel>? sseSubscription;

Stream<Message> createSSEConnection(Ref ref) {
  var settings = getSettings();
  String key = settings.apiKey;
  String server = settings.serverHost;
  String port = settings.serverPort;
  String protocol = settings.enableSSL ? 'https' : 'http';

  return SSEClient.subscribeToSSE(
    method: SSERequestType.POST,
    url: '$protocol://$server:$port/events',
    header: {
      "Accept": "text/event-stream",
      "Cache-Control": "no-cache",
    },
    body: {"apikey": key},
  ).map((event) {
    print('Event: ' + event.event!);
    print('Data: ' + event.data!);
    Map<String, dynamic> messageData = jsonDecode(event.data!);
    String currentTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    messageData['time'] = currentTime;
    print(messageData);
    return Message.fromJson(messageData);
  });
}
