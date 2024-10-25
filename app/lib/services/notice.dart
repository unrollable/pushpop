import 'package:local_notifier/local_notifier.dart';
import 'package:window_manager/window_manager.dart';

void showLocalNotification(msg) {
  LocalNotification notification = LocalNotification(
    title: msg.title,
    body: msg.content,
  );

  notification.onClick = () async{
    await windowManager.show();
    await windowManager.focus();
  };

  notification.show();
}
