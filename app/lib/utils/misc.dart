import 'dart:io';

String getOS() {
  String os = Platform.operatingSystem;
  return os;
}

String getOSVersion() {
  String osVersion = Platform.operatingSystemVersion;
  return osVersion;
}

String getUserName() {
  String? username = Platform.environment['USERNAME'] ?? Platform.environment['USER'];
  return username ?? "username";
}