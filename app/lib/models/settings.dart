import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 1)
class Settings {
  @HiveField(0)
  final String language;

  @HiveField(1)
  final bool autoStartup;

  @HiveField(2)
  final bool hiddenStartup;

  @HiveField(3)
  final bool quitToTray;

  Settings({
    this.language = 'English',
    this.autoStartup = true,
    this.hiddenStartup = true,
    this.quitToTray = true,
  });

  factory Settings.fromJson(Map<String, dynamic> settings) {
    return Settings(
      language: settings['language'] ?? 'English',
      autoStartup: settings['autoStartup'] ?? true,
      hiddenStartup: settings['hiddenStartup'] ?? true,
      quitToTray: settings['quitToTray'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': this.language,
      'autoStartup': this.autoStartup,
      'hiddenStartup': this.hiddenStartup,
      'quitToTray': this.quitToTray,
    };
  }
}
