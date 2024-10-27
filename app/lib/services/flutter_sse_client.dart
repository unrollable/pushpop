library flutter_client_sse;

import 'dart:async';
import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:http/http.dart' as http;

/// Model for representing an SSE event.
class SSEModel {
  /// ID of the event.
  String? id = '';

  /// Event name.
  String? event = '';

  /// Event data.
  String? data = '';

  /// Constructor for [SSEModel].
  SSEModel({this.data, this.id, this.event});

  /// Constructs an [SSEModel] from a data string.
  SSEModel.fromData(String data) {
    id = data.split("\n")[0].split('id:')[1];
    event = data.split("\n")[1].split('event:')[1];
    this.data = data.split("\n")[2].split('data:')[1];
  }
}

/// A client for subscribing to Server-Sent Events (SSE).
class SSEClient {
  static http.Client _client = http.Client();
  static StreamController<SSEModel>? _streamController;
  static bool _isConnecting = false;

  /// Retry the SSE connection after a delay.
  static void _retryConnection({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    Map<String, dynamic>? body,
  }) {
    if (_isConnecting) return;
    print('---RETRY CONNECTION---');
    _isConnecting = true;
    Future.delayed(Duration(seconds: 5), () {
      _isConnecting = false;
      subscribeToSSE(
        method: method,
        url: url,
        header: header,
        body: body,
      );
    });
  }

  /// Subscribe to Server-Sent Events.
  static Stream<SSEModel> subscribeToSSE({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    Map<String, dynamic>? body,
  }) {
    _closeStream();
    _streamController = StreamController<SSEModel>();

    var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    print("--SUBSCRIBING TO SSE---");

    try {
      _client = http.Client();
      var request = http.Request(
        method == SSERequestType.GET ? "GET" : "POST",
        Uri.parse(url),
      );

      header.forEach((key, value) {
        request.headers[key] = value;
      });

      if (body != null) {
        request.body = jsonEncode(body);
      }

      Future<http.StreamedResponse> response = _client.send(request);

      response.asStream().listen((data) {
        data.stream.transform(Utf8Decoder()).transform(LineSplitter()).listen(
          (dataLine) {
            if (dataLine.isEmpty) {
              _streamController?.add(currentSSEModel);
              currentSSEModel = SSEModel(data: '', id: '', event: '');
              return;
            }

            Match match = lineRegex.firstMatch(dataLine)!;
            var field = match.group(1);
            if (field == null || field.isEmpty) return;

            var value =
                field == 'data' ? dataLine.substring(5) : match.group(2) ?? '';
            switch (field) {
              case 'event':
                currentSSEModel.event = value;
                break;
              case 'data':
                currentSSEModel.data =
                    (currentSSEModel.data ?? '') + value + '\n';
                break;
              case 'id':
                currentSSEModel.id = value;
                break;
              default:
                print('---ERROR---');
                _retryConnection(
                  method: method,
                  url: url,
                  header: header,
                  body: body,
                );
            }
          },
          onError: (e) {
            print('---ERROR---');
            _retryConnection(
              method: method,
              url: url,
              header: header,
              body: body,
            );
          },
        );
      }, onError: (e) {
        print('---ERROR---');
        _retryConnection(
          method: method,
          url: url,
          header: header,
          body: body,
        );
      });
    } catch (e) {
      print('---ERROR---');
      _retryConnection(
        method: method,
        url: url,
        header: header,
        body: body,
      );
    }
    return _streamController!.stream;
  }

  static void _closeStream() {
    _streamController?.close();
    _streamController = null;
  }

  static void unsubscribeFromSSE() {
    _closeStream();
    _client.close();
  }
}
