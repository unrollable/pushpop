import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';
import 'package:pushpop/models/messages.dart';
import 'package:pushpop/models/settings.dart';
import 'package:win32/win32.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

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
  checkSettings(key, value, jsonSettings);
  Settings newSettings = Settings.fromJson(jsonSettings);
  await updateSettings(Settings.fromJson(jsonSettings));
  print("----update $key to $value");
  return newSettings;
}

Future<void> updateSettings(Settings settings) async {
  var settingsBox = Hive.box<Settings>('settings');
  await settingsBox.put('appSettings', settings);
}

void checkSettings(String key, dynamic value, Map jsonSettings) {
  if (key == "customServer" && value == false) {
    restoreDefaultServer(jsonSettings);
  }
  if (key == 'autoStartup') {
    setAutoStartup(value);
  }
}

void restoreDefaultServer(jsonSettings) {
  Settings defaultSettings = Settings();
  jsonSettings['serverHost'] = defaultSettings.serverHost;
  jsonSettings['serverPort'] = defaultSettings.serverPort;
  jsonSettings['enableSSL'] = defaultSettings.enableSSL;
}

void setAutoStartup(value) {
  final hkey = HKEY_CURRENT_USER;
  final startupPath =
      'Software\\Microsoft\\Windows\\CurrentVersion\\Run'.toNativeUtf16();
  final programNamePtr = 'PushPop'.toNativeUtf16();
  final appPath = Platform.resolvedExecutable;
  final appPathPtr = Platform.resolvedExecutable.toNativeUtf16();
  final phkResult = calloc<HKEY>();

  try {
    final result = RegOpenKeyEx(
      hkey,
      startupPath,
      0,
      REG_SAM_FLAGS.KEY_SET_VALUE,
      phkResult,
    );

    if (result == WIN32_ERROR.ERROR_SUCCESS) {
      if (value) {
        //enable autostartup
        RegSetValueEx(
          phkResult.value,
          programNamePtr,
          0,
          REG_VALUE_TYPE.REG_SZ,
          Pointer.fromAddress(appPathPtr.address),
          (appPath.length + 1) * 2,
        );
      } else {
        //disable autostartup
        RegDeleteValue(phkResult.value, programNamePtr);
      }
    } else {
      print("Failed to open registry key. Error code: $result");
    }
  } finally {
    if (phkResult.value != NULL) {
      RegCloseKey(phkResult.value);
    }
    free(phkResult);
    free(startupPath);
    free(programNamePtr);
    free(appPathPtr);
  }
}
