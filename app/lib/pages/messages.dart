import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pushpop/services/msg_provider.dart';
import 'package:pushpop/services/client.dart';


// final container = ProviderContainer();

class MessagesPage extends ConsumerWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messageProvider);

    // createSSEConnection(ref);
    // createSSEConnection(ref).listen((message) {
    //   ref.read(messageProvider.notifier).addMessage(message);
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return Column(
                children: [
                  _buildMessage(
                    time: message.time,
                    title: message.title,
                    content: message.content,
                  ),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(
      {required String time, required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
              fontSize: 10, color: Color.fromARGB(255, 200, 200, 200)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Divider(),
                Text(
                  content,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}