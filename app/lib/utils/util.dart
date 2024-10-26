import 'dart:math';
import 'dart:convert';
import 'misc.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

String generateSHA1(String input) {
  var bytes = utf8.encode(input);
  var digest = sha1.convert(bytes);
  return digest.toString();
}

String getCurrentTimestamp() {
  return DateTime.now().toString();
}

String getCurrentDatetime() {
  String datetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  return datetime;
}

String genApiKey() {
  var random = Random();
  int randomInt = random.nextInt(100);
  String os = getOS();
  String osVersion = getOSVersion();
  String userName = getUserName();
  String input ="$os$osVersion$userName$getCurrentTimestamp()$randomInt";
  return generateSHA1(input);
}
