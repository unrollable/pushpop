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

  @HiveField(4)
  final bool customServer;

  @HiveField(5)
  final String serverHost;

  @HiveField(6)
  final String serverPort;

  @HiveField(7)
  final bool enableSSL;

  @HiveField(8)
  final String apiKey;

  Settings({
    this.language = 'English',
    this.autoStartup = true,
    this.hiddenStartup = true,
    this.quitToTray = true,
    this.customServer = false,
    this.serverHost = "127.0.0.1",
    this.serverPort = "8080",
    this.enableSSL = false,
    this.apiKey = "",

  });

  factory Settings.fromJson(Map<String, dynamic> settings) {
    return Settings(
      language: settings['language'] ?? 'English',
      autoStartup: settings['autoStartup'] ?? true,
      hiddenStartup: settings['hiddenStartup'] ?? true,
      quitToTray: settings['quitToTray'] ?? true,
      customServer: settings['customServer'] ?? false,
      serverHost: settings['serverHost'] ?? "127.0.0.1",
      serverPort: settings['serverPort'] ?? "8080",
      enableSSL: settings['enableSSL'] ?? false,
      apiKey: settings['apiKey'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': this.language,
      'autoStartup': this.autoStartup,
      'hiddenStartup': this.hiddenStartup,
      'quitToTray': this.quitToTray,
      'customServer': this.customServer,
      'serverHost': this.serverHost,
      'serverPort': this.serverPort,
      'enableSSL': this.enableSSL,
      'apiKey': this.apiKey,
    };
  }
}
