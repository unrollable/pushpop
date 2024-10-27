import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:pushpop/models/messages.dart';
import 'package:pushpop/models/settings.dart';

class HiveService {
  static Future<void> init() async {
    String exePath = Platform.resolvedExecutable;
    String installDir = File(exePath).parent.path;
    await Hive.initFlutter(installDir);
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(SettingsAdapter());
    await Hive.openBox<Message>('message');
    await Hive.openBox<Settings>('settings');
  }
}

List<Message> getMessages() {
  var box = Hive.box<Message>('message');
  return box.values.toList();
}

Settings getSettings() {
  var box = Hive.box<Settings>('settings');
  return box.get('appSettings', defaultValue: Settings())!;
}

Future<void> saveMessage(Message message) async {
  var messageBox = Hive.box<Message>('message');
  await messageBox.add(message);
}

Future<Settings> updateSetting(String key, dynamic value) async {
  Settings settings = getSettings();
  Map<String, dynamic> jsonSettings = settings.toJson();
  jsonSettings[key] = value;
  if (key == "customServer" && value == false) {
    restoreDefaultServer(jsonSettings);
  }
  Settings newSettings = Settings.fromJson(jsonSettings);
  await updateSettings(newSettings);
  print("----update $key to $value");
  return newSettings;
}

void restoreDefaultServer(jsonSettings) {
  Settings defaultSettings = Settings();
  jsonSettings['serverHost'] = defaultSettings.serverHost;
  jsonSettings['serverPort'] = defaultSettings.serverPort;
  jsonSettings['enableSSL'] = defaultSettings.enableSSL;
}

Future<void> updateSettings(Settings settings) async {
  var settingsBox = Hive.box<Settings>('settings');
  await settingsBox.put('appSettings', settings);
}
