import 'package:hive/hive.dart';

part 'messages.g.dart';

@HiveType(typeId: 0)
class Message {
  @HiveField(0)
  final String type;
  @HiveField(1)
  final String time;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String content;

  Message({
    required this.type,
    required this.time,
    required this.title,
    required this.content,
  });
}